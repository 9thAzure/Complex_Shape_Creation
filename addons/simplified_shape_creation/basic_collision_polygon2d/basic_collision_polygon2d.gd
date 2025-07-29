extends Node2D
class_name BasicCollisionPolygon2D

@export
var disabled := false

@export
var one_way_collision := false

@export_range(0, 128, 0.1, "suffix:px")
var one_way_collision_margin := 1.0

@export_group("Generation")
## The number of vertices in the regular shape. A value of [code]1[/code] creates a circle, and a value of [code]2[/code] creates a line.
@export_range(1, 1000)
var vertices_count : int = 1:
	set(value):
		assert(value > 0, "property 'vertices_count' must be greater than 0")
		vertices_count = value
		queue_regenerate()

## The length from each corner to the center of the shape.
#@export_range(0.000001, 10, 0.001, "or_greater", "hide_slider")
var size : float = 10:
	get:
		return sizes[0]
	set(value):
		sizes[0] = value
		queue_regenerate()

@export
var sizes : PackedFloat64Array = PackedFloat64Array([10]):
	set(value):
		if value.size() == 0:
			return

		for i in value.size():
			if value[i] < 0.001:
				value[i] = 0.001 if i >= sizes.size() else sizes[i]


		sizes = value
		queue_regenerate()

## The offset rotation of the shape, in degrees.
var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotation)

## The offset rotation of the shape, in radians.
@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians")
var offset_rotation : float = 0:
	set(value):
		offset_rotation = value
		queue_regenerate()

## see [member offset]
@export
var offset_position := Vector2.ZERO:
	set(value):
		offset = value
	get:
		return offset

@export_range(0, 1, 0.001, "or_less")
var ring_ratio : float = 1.0:
	set(value):
		ring_ratio = value
		update_configuration_warnings()
		queue_regenerate()

@export_range(0.0, 10, 0.001, "or_greater", "hide_slider")
var corner_size : float = 0.0:
	set(value):
		assert(value >= 0, "property 'corner_size' must be greater than or equal to 0")
		corner_size = value
		queue_regenerate()

## How many lines make up each corner. A value of [code]0[/code] will use a value of [code]32[/code] divided by [member vertices_count].
## This only has an effect if [member corner_size] is used.
@export_range(0, 50)
var corner_smoothness : int = 0:
	set(value):
		assert(value >= 0, "property 'corner_smoothness' must be greater than or equal to 0")
		corner_smoothness = value
		queue_regenerate()

@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians")
var arc_start : float = 0.0:
	set(value):
		arc_start = value
		update_configuration_warnings()
		queue_regenerate()

@export_range(0, 360, 0.1, "or_greater", "or_less", "radians")
var arc_angle : float = TAU:
	set(value):
		arc_angle = value
		update_configuration_warnings()
		queue_regenerate()

var arc_end : float = TAU:
	get: return arc_start + arc_angle
	set(value): arc_angle = value - arc_start

var arc_start_degrees : float:
	get: return rad_to_deg(arc_start)
	set(value): arc_start = deg_to_rad(value)

var arc_angle_degrees : float:
	get: return rad_to_deg(arc_angle)
	set(value): arc_angle = deg_to_rad(value)

var arc_end_degrees : float:
	get: return rad_to_deg(arc_end)
	set(value): arc_end = deg_to_rad(value)

@export
var closing_method : BasicPolygon2D.ClosingMethod = BasicPolygon2D.ClosingMethod.SLICE:
	set(value):
		closing_method = value
		update_configuration_warnings()
		queue_regenerate()

@export
var round_arc_ends : bool = false:
	set(value):
		round_arc_ends = value
		queue_regenerate()

var _collision_shapes : Array[CollisionObject2D] = []

func _get_property_list() -> Array[Dictionary]:
	return [{
		name = "_collision_shapes",
		type = TYPE_ARRAY,
		usage = PROPERTY_USAGE_STORAGE
	}]

const _UNQUEUED         := 0
const _QUEUE_DISPERSE   := 1
const _QUEUE_REGENERATE := 2

var _queue_status : int = _UNQUEUED

func queue_regenerate() -> void:
	if _queue_status >= _QUEUE_REGENERATE:
		return

	_queue_status = _QUEUE_REGENERATE
	if not is_inside_tree():
		return

	await get_tree().process_frame
	if _queue_status != _QUEUE_REGENERATE:
		return

	regenerate()

func regenerate() -> void:
	pass
