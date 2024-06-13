@tool
extends "res://addons/complex_shape_creation/gui_handlers/base_handler.gd"

var shape_type : int = 0

const _SHAPE_SIMPLE := 1
const _SHAPE_REGULAR := 2
const _SHAPE_STAR := 3
const _SHAPE_COLLISION := 4


func _ready() -> void:
	super._ready()
	shape_type = _get_shape_type(_parent)
	
func _get_shape_type(shape : Node2D) -> int:
	if shape is SimplePolygon2D:
		return _SHAPE_SIMPLE
	if shape is RegularPolygon2D:
		return _SHAPE_REGULAR
	if shape is StarPolygon2D:
		return _SHAPE_STAR
	if shape is RegularCollisionPolygon2D:
		return _SHAPE_COLLISION
			
	printerr("unrecognized shape given: %s" % shape)
	return 0


func _from_parent_properties() -> void:
	var offset_rotation : float = _parent.offset_rotation + get_rotation_offset()
	
	position = _origin + Vector2(sin(offset_rotation), -cos(offset_rotation)) * _parent.size

func _update_properties() -> void:
	var functional_position := position - _origin
	_parent.size = functional_position.length()
	_parent.offset_rotation = atan2(functional_position.y, functional_position.x) + PI / 2 - get_rotation_offset()

func get_rotation_offset() -> float:
	var offset := 0.0
	if not is_parent_star_shape():
		offset += PI
		if _parent.vertices_count != 2:
			offset += TAU / _parent.vertices_count / 2
	return offset

func is_parent_star_shape() -> bool:
	return shape_type == _SHAPE_STAR or shape_type == _SHAPE_COLLISION and _parent.inner_size > 0
