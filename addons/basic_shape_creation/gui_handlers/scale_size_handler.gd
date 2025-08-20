@tool
extends "res://addons/basic_shape_creation/gui_handlers/base_handler.gd"

var _old_sizes : PackedFloat64Array = []
var _old_max_size := -1.0
var _old_rotation := 0.0
var _was_flipped := false

func _init(plugin : EditorPlugin, undo_redo_manager : EditorUndoRedoManager, handler_size := 9.0) -> void:
	super(plugin, undo_redo_manager, handler_size)
	_shift_clamps = [clamp_straight_line]
	always_clamp = true
	_old_rotation = shape().offset_rotation

func get_max_size() -> float:
	var max_size := -0.0
	for size in shape().sizes: max_size = maxf(max_size, size)
	if shape().ring_ratio < 0:
		max_size = lerpf(max_size, 0, shape().ring_ratio)
	return max_size

func _from_parent_properties() -> void:
	position = Vector2(1, -1) * get_max_size()

func _update_properties() -> void:
	var new_size := clamp_straight_line().x
	shape().offset_rotation = _old_rotation + (0 if new_size >= 0 != _was_flipped else (-PI if _was_flipped else PI))
	var scale := absf(new_size / _old_max_size)
	for i in _old_sizes.size():
		shape().sizes[i] = _old_sizes[i] * scale

func _mouse_pressed() -> void:
	_old_sizes = shape().sizes.duplicate()
	_old_max_size = get_max_size()
	_old_rotation = shape().offset_rotation
	_was_flipped = position.x < 0

func _mouse_released() -> void:
	_undo_redo_manager.create_action("Scale sizes")

	_undo_redo_manager.add_do_property(shape(), &"sizes", shape().sizes)
	_undo_redo_manager.add_undo_property(shape(), &"sizes", _old_sizes)

	if not is_equal_approx(_old_rotation, shape().offset_rotation):
		_undo_redo_manager.add_do_method(shape(), &"offset_rotation", shape().offset_rotation)
		_undo_redo_manager.add_undo_property(shape(), &"offset_rotation", _old_rotation)

	_undo_redo_manager.commit_action(false)
	shape().notify_property_list_changed()
