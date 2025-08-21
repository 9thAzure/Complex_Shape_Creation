@tool
extends RefCounted

const Plugin := preload("res://addons/basic_shape_creation/plugin.gd")

var always_clamp := false
var _shift_clamps : Array[Callable] = [clamp_straight_line, clamp_circle_radius, clamp_compass_lines]

var _plugin : Plugin
var _undo_redo_manager : EditorUndoRedoManager
var size := 1.0

func shape() -> Node2D:
	return _plugin._current_object

var _old_position := Vector2.ZERO

var position := Vector2.ZERO:
	set(value):
		position = value
		_plugin.update_overlays()

func get_global_transform() -> Transform2D: return  shape().get_viewport_transform() * shape().global_transform * shape().offset_transform.rotated_local(-shape().offset_transform.get_rotation())

func to_local(point : Vector2) -> Vector2:
	var transform := get_global_transform()
	point -= transform.origin

	return transform.affine_inverse().basis_xform(point)

func to_global(point : Vector2) -> Vector2:
	var transform := get_global_transform()
	return transform.basis_xform(point) + transform.origin

func _init(plugin : Plugin, undo_redo_manager : EditorUndoRedoManager, handler_size := 9.0) -> void:
	_plugin = plugin
	_undo_redo_manager = undo_redo_manager
	size = handler_size

func mouse_press(point : Vector2) -> bool:
	const extra_margin := 2.0
	if (point - to_global(position)).length_squared() <= (size + extra_margin) ** 2:
		_old_position = position
		if _old_position == Vector2.ZERO:
			_old_position = Vector2.RIGHT
		_mouse_pressed()
		return true
	return false

var suppress_from_parent_call := false
func mouse_release() -> bool:
	if _plugin._pressed_handler == self:
		suppress_from_parent_call = true
		_mouse_released()
		return true
	return false

func mouse_dragged(mouse_position: Vector2) -> void:
	position = to_local(mouse_position)
	if always_clamp or Input.is_key_pressed(KEY_SHIFT):
		_clamp_position()
	_mouse_dragged(mouse_position)
	_update_properties()

func version_change() -> void:
	maintain_position()

func _from_parent_properties() -> void:
	printerr("'_from_parent_properties' is abstract")

func _update_properties() -> void:
	printerr("'_update_properties' is abstract")

func _mouse_pressed() -> void:
	printerr("'_mouse_pressed' is abstract")

func _mouse_released() -> void:
	printerr("'_mouse_released' is abstract")

func _mouse_dragged(position: Vector2) -> void:
	pass

func maintain_position() -> void:
	if suppress_from_parent_call:
		suppress_from_parent_call = false
		return

	_from_parent_properties()

func _clamp_position() -> void:
	if _shift_clamps.size() == 0:
		return
	
	var best_position := position
	var best_distance := INF
	for i in _shift_clamps.size():
		var point = _shift_clamps[i].call()
		if typeof(point) != TYPE_VECTOR2:
			printerr("method %s did not returned a %s, not a vector2." % [_shift_clamps[i], typeof(point)])		
			continue
		
		var distance : float = (point - position).length_squared()
		if distance < best_distance:
			best_distance = distance
			best_position = point
	
	position = best_position

func clamp_straight_line() -> Vector2:
	var allowed_line := _old_position
	var inverse_line := Vector2(-allowed_line.y, allowed_line.x)
	var a :=            BasicGeometry2D._find_intersection(position, inverse_line, Vector2.ZERO, allowed_line)
	return position + inverse_line * a

func clamp_circle_radius() -> Vector2:
	var radius := _old_position.length()
	return position.normalized() * radius

func clamp_compass_lines() -> Vector2:
	var functional_position := position
	var angle := atan2(functional_position.y, functional_position.x)
	var multiplier := floor((angle + TAU / 16) / (TAU / 8))

	angle = multiplier * TAU / 8
	var slope := Vector2(cos(angle), sin(angle))
	return Geometry2D.get_closest_point_to_segment_uncapped(position, Vector2.ZERO, slope)
