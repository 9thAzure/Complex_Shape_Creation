@tool
extends Node2D 

var _shift_clamps : Array[Callable] = [clamp_straight_line, clamp_circle_radius]

var _plugin : EditorPlugin
var _undo_redo_manager : EditorUndoRedoManager
var _parent : Node2D = null
var _origin := Vector2.ZERO
var size := 1.0

var _being_dragged := false
var _old_position := Vector2.ZERO


func _init(plugin : EditorPlugin, undo_redo_manager : EditorUndoRedoManager, handler_size := 1.0) -> void:
	_plugin = plugin
	_undo_redo_manager = undo_redo_manager
	_undo_redo_manager.version_changed.connect(maintain_shape)
	_undo_redo_manager.history_changed.connect(maintain_shape)
	size = handler_size

func _ready() -> void:
	assert(Engine.is_editor_hint())

	_parent = get_parent()

	maintain_shape()
	_from_parent_properties()

func mouse_press(point : Vector2) -> bool:
	if _manhattan_distance(point - global_position) <= 7 * size / get_viewport_transform().get_scale().x:
		_old_position = position
		_being_dragged = true
		if _old_position == Vector2.ZERO:
			_old_position = Vector2.RIGHT
		return true
	return false

func mouse_release() -> bool:
	if _being_dragged:
		_being_dragged = false
		_mouse_released()
		return true
	return false

func _from_parent_properties() -> void:
	printerr("'_from_parent_properties' is abstract")

func _update_properties() -> void:
	printerr("'_update_properties' is abstract")

func _mouse_released() -> void:
	printerr("'_mouse_released' is abstract")

func _draw() -> void:
	const margin := 2
	var box := StyleBoxFlat.new()
	box.bg_color = Color.WHITE
	box.border_width_bottom = margin
	box.border_width_top = margin
	box.border_width_left = margin
	box.border_width_right = margin
	box.border_color = Color.BLACK

	box.draw(get_canvas_item(), Rect2(-5 * size, -5 * size, 10 * size, 10 * size))

var previous_editor_scale := 1.0
func _process(_delta) -> void:
	var editor_scale := get_viewport_transform().get_scale().x
	if not is_equal_approx(editor_scale, previous_editor_scale):
		maintain_shape()
		previous_editor_scale = editor_scale

	if not _being_dragged:
		return

	global_position = get_global_mouse_position()
	if Input.is_key_pressed(KEY_SHIFT):
		_clamp_position()
	_update_properties()
	
func maintain_shape() -> void:
	if not _parent is CollisionShape2D:
		_origin = _parent.offset
	_from_parent_properties()
	global_transform = Transform2D(PI / 4, Vector2.ONE / get_viewport_transform().get_scale().x, 0, global_position)

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
	_origin = Vector2.ZERO
	var allowed_line := _old_position - _origin
	var inverse_line := Vector2(-allowed_line.y, allowed_line.x)
	var a := RegularGeometry2D._find_intersection(position, inverse_line, _origin, allowed_line)
	return position + inverse_line * a

func clamp_circle_radius() -> Vector2:
	var radius := (_old_position - _origin).length()
	return _origin + (position - _origin).normalized() * radius

func _manhattan_distance(point : Vector2) -> float:
	return abs(point.x) + abs(point.y)
