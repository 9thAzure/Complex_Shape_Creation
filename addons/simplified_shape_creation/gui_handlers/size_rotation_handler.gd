@tool
extends "res://addons/simplified_shape_creation/gui_handlers/base_handler.gd"

var shape_type : int = 0

const _BASIC_POLYGON := 1
const _BASIC_COLLISION := 2

func _ready() -> void:
	shape_type = _get_shape_type(get_parent())
	super._ready()
	
func _get_shape_type(shape : Node2D) -> int:
	if shape is BasicPolygon2D:
		return _BASIC_POLYGON
	if shape is BasicCollisionPolygon2D:
		return _BASIC_COLLISION

	printerr("unrecognized shape given: %s" % shape)
	return 0

func _from_parent_properties() -> void:
	var offset_rotation : float = _parent.offset_rotation + get_rotation_offset()
	
	position = _origin + Vector2(sin(offset_rotation), -cos(offset_rotation)) * _parent.size

func _update_properties() -> void:
	var functional_position := position - _origin
	_parent.size = functional_position.length()
	_parent.offset_rotation = fmod(atan2(functional_position.y, functional_position.x) + PI / 2 - get_rotation_offset() + TAU, TAU)

func _mouse_released() -> void:
	_undo_redo_manager.create_action("Resizing and Rotating Shape")

	_undo_redo_manager.add_do_property(_parent, &"size", _parent.size)
	_undo_redo_manager.add_do_property(_parent, &"offset_rotation", _parent.offset_rotation)

	var old_functional_position := (_old_position - _origin)
	var old_size := old_functional_position.length()
	var old_rotation := fmod(atan2(old_functional_position.y, old_functional_position.x) + PI / 2 - get_rotation_offset() + TAU, TAU)
	_undo_redo_manager.add_undo_property(_parent, &"size", old_size)
	_undo_redo_manager.add_undo_property(_parent, &"offset_rotation", old_rotation)

	_undo_redo_manager.commit_action()

func get_rotation_offset() -> float:
	var offset := 0.0
#	if not is_parent_star_shape():
#		offset += PI
#		if _parent.vertices_count != 2:
#			offset += TAU / _parent.vertices_count / 2
	return offset
