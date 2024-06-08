@tool
extends "res://addons/complex_shape_creation/gui_handlers/base_handler.gd"

var is_star_shape := false

func _ready() -> void:
	super._ready()
	is_star_shape = _parent is StarPolygon2D

func _from_parent_properties() -> void:
	var offset_rotation : float = _parent.offset_rotation + get_rotation_offset()
	
	position = _origin + Vector2(sin(offset_rotation), -cos(offset_rotation)) * _parent.size

func _update_properties() -> void:
	var functional_position := position - _origin
	_parent.size = functional_position.length()
	_parent.offset_rotation = atan2(functional_position.y, functional_position.x) + PI / 2 - get_rotation_offset()

func get_rotation_offset() -> float:
	var offset := 0.0
	if not is_star_shape:
		offset += PI
		if _parent.vertices_count != 2:
			offset += TAU / _parent.vertices_count / 2
	return offset
