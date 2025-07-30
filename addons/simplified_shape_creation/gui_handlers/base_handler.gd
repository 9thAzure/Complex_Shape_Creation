@tool
extends Node2D

const Plugin := preload("res://addons/simplified_shape_creation/plugin.gd")

var always_clamp := false
var _shift_clamps : Array[Callable] = [clamp_straight_line, clamp_circle_radius, clamp_compass_lines]

var _plugin : Plugin
var _undo_redo_manager : EditorUndoRedoManager
var _shape : Node2D =  null
var _origin         := Vector2.ZERO
var size := 1.0

var _being_dragged := false
var _old_position := Vector2.ZERO


func _init(plugin : Plugin, undo_redo_manager : EditorUndoRedoManager, handler_size := 9.0) -> void:
	_plugin = plugin
	_shape = plugin._current_object
	_undo_redo_manager = undo_redo_manager
	size = handler_size
	z_as_relative = false
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX


func _ready() -> void:
	assert(Engine.is_editor_hint())

	maintain_editor_scale()
	maintain_position()

func mouse_press(point : Vector2) -> bool:
	const extra_margin := 2.0
	if (point - global_position).length_squared() <= ((size + extra_margin) / get_viewport_transform().get_scale().x) ** 2:
		_old_position = position
		_being_dragged = true
		if _old_position == Vector2.ZERO:
			_old_position = Vector2.RIGHT
		_mouse_pressed()
		modulate = Color.LIME_GREEN
		return true
	return false

var suppress_from_parent_call := false
func mouse_release() -> bool:
	if _being_dragged:
		_being_dragged = false
		suppress_from_parent_call = true
		_mouse_released()
		modulate = Color.WHITE
		return true
	return false

func version_change() -> void:
	maintain_editor_scale()
	maintain_position()

func _from_parent_properties() -> void:
	printerr("'_from_parent_properties' is abstract")

func _update_properties() -> void:
	printerr("'_update_properties' is abstract")

func _mouse_pressed() -> void:
	printerr("'_mouse_pressed' is abstract")

func _mouse_released() -> void:
	printerr("'_mouse_released' is abstract")

func _draw() -> void:
	const margin := 1

	var shape := BasicGeometry2D.create_shape(5, [size])
	draw_colored_polygon(shape, Color.WHITE)
	draw_polyline(shape, Color.BLACK, margin, true)
	draw_line(shape[-1], shape[0], Color.BLACK, margin, true)

var previous_editor_scale := 1.0
func _process(_delta) -> void:
	var editor_scale := get_viewport_transform().get_scale().x
	if not is_equal_approx(editor_scale, previous_editor_scale):
		maintain_editor_scale()
		previous_editor_scale = editor_scale

	if _plugin._pressed_handler != null:
		maintain_position()

	if not _being_dragged:
		return

	global_position = get_global_mouse_position()
	if always_clamp or Input.is_key_pressed(KEY_SHIFT):
		_clamp_position()
	_update_properties()
	
func maintain_position() -> void:
	if suppress_from_parent_call:
		suppress_from_parent_call = false
		return

	_origin = Vector2.ZERO
	if not _shape is CollisionShape2D:
		_origin = _shape.offset_position
	_from_parent_properties()

func maintain_editor_scale() -> void:
	global_transform = Transform2D(0, Vector2.ONE / get_viewport_transform().get_scale().x, 0, global_position)

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
	var allowed_line := _old_position - _origin
	var inverse_line := Vector2(-allowed_line.y, allowed_line.x)
	var a :=            BasicGeometry2D._find_intersection(position, inverse_line, _origin, allowed_line)
	return position + inverse_line * a

func clamp_circle_radius() -> Vector2:
	var radius := (_old_position - _origin).length()
	return _origin + (position - _origin).normalized() * radius

func clamp_compass_lines() -> Vector2:
	var functional_position := position - _origin
	var angle := atan2(functional_position.y, functional_position.x)
	var multiplier := floor((angle + TAU / 16) / (TAU / 8))

	angle = multiplier * TAU / 8
	var slope := Vector2(cos(angle), sin(angle))
	return Geometry2D.get_closest_point_to_segment_uncapped(position, _origin, _origin + slope)
