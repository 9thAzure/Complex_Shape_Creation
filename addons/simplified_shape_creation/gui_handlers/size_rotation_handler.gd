@tool
extends "res://addons/simplified_shape_creation/gui_handlers/base_handler.gd"

var _size_index := -1
var _old_size : PackedFloat64Array
var _old_rotation : float

func _init(plugin : EditorPlugin, undo_redo_manager : EditorUndoRedoManager, size_index : int = 0, handler_size := 9.0) -> void:
	super(plugin, undo_redo_manager, handler_size)
	_size_index = size_index

func _from_parent_properties() -> void:
	var offset_rotation : float = _shape.offset_rotation + get_rotation_offset()
	
	position = Vector2(sin(offset_rotation), -cos(offset_rotation)) * _shape.sizes[_size_index]

func _update_properties() -> void:
	_shape.sizes[_size_index] = position.length()
	_shape.offset_rotation = fmod(atan2(position.y, position.x) + PI / 2 - get_rotation_offset() + TAU, TAU)

func _mouse_pressed() -> void:
	_old_size = _shape.sizes.duplicate()
	_old_rotation = _shape.offset_rotation

func _mouse_released() -> void:
	_undo_redo_manager.create_action("Resizing and Rotating Shape")

	_undo_redo_manager.add_do_property(_shape, &"sizes", _shape.sizes)
	_undo_redo_manager.add_do_property(_shape, &"offset_rotation", _shape.offset_rotation)

	_undo_redo_manager.add_undo_property(_shape, &"sizes", _old_size)
	_undo_redo_manager.add_undo_property(_shape, &"offset_rotation", _old_rotation)

	_undo_redo_manager.commit_action(false)
	_shape.notify_property_list_changed()

func get_rotation_offset() -> float:
	var vertices_count : int = _shape.vertices_count
	if vertices_count == 1:
		vertices_count = 32
	elif vertices_count == 2:
		vertices_count = maxi(2, _shape.sizes.size())
	return _size_index * TAU / vertices_count
