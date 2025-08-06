@tool
@icon("res://addons/simplified_shape_creation/basic_collision_polygon2d/basic_collision_polygon2d.svg")
extends Node2D
class_name BasicCollisionPolygon2D

@export
var disabled := false:
	set(value):
		disabled = value
		queue_redraw()
		if _collision_object_parent != null:
			_collision_object_parent.shape_owner_set_disabled(_owner_id, value)

@export
var one_way_collision := false:
	set(value):
		one_way_collision = value
		queue_redraw()
		update_configuration_warnings()
		if _collision_object_parent != null:
			_collision_object_parent.shape_owner_set_one_way_collision(_owner_id, value)

@export_range(0, 128, 0.1, "suffix:px")
var one_way_collision_margin := 1.0:
	set(value):
		one_way_collision_margin = value
		if _collision_object_parent != null:
			_collision_object_parent.shape_owner_set_one_way_collision_margin(_owner_id, value)

@export_group("Generation")

## The number of vertices in the regular shape. A value of [code]1[/code] creates a circle, and a value of [code]2[/code] creates a line.
@export_range(1, 1000)
var vertices_count : int = 1:
	get: return _basic_polygon_instance.vertices_count
	set(value): _basic_polygon_instance.vertices_count = value

@export
var sizes : PackedFloat64Array = PackedFloat64Array([10]):
	get: return _basic_polygon_instance.sizes
	set(value): _basic_polygon_instance.sizes = value



@export_range(0, 1, 0.001, "or_less")
var ring_ratio : float = 1.0:
	get: return _basic_polygon_instance.ring_ratio
	set(value): _basic_polygon_instance.ring_ratio = value

@export_range(0.0, 10, 0.001, "or_greater", "hide_slider")
var corner_size : float = 0.0:
	get: return _basic_polygon_instance.corner_size
	set(value): _basic_polygon_instance.corner_size = value

## How many lines make up each corner. A value of [code]0[/code] will use a value of [code]32[/code] divided by [member vertices_count].
## This only has an effect if [member corner_size] is used.
@export_range(0, 50)
var corner_smoothness : int = 0:
	get: return _basic_polygon_instance.corner_smoothness
	set(value): _basic_polygon_instance.corner_smoothness = value

@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians")
var arc_start : float = 0.0:
	get: return _basic_polygon_instance.arc_start
	set(value): _basic_polygon_instance.arc_start = value

@export_range(0, 360, 0.1, "or_greater", "or_less", "radians")
var arc_angle : float = TAU:
	get: return _basic_polygon_instance.arc_angle
	set(value): _basic_polygon_instance.arc_angle = value

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
	get: return _basic_polygon_instance.closing_method
	set(value): _basic_polygon_instance.closing_method = value

@export
var round_arc_ends : bool = false:
	get: return _basic_polygon_instance.round_arc_ends
	set(value): _basic_polygon_instance.round_arc_ends = value

@export_subgroup("Offset Transform", "offset")

@export
var offset_position := Vector2.ZERO:
	get: return _basic_polygon_instance.offset_position
	set(value): _basic_polygon_instance.offset_position = value

## The offset rotation of the shape, in degrees.
var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotation)

## The offset rotation of the shape, in radians.
@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians")
var offset_rotation : float = 0:
	get: return _basic_polygon_instance.offset_rotation
	set(value): _basic_polygon_instance.offset_rotation = value

@export
var offset_scale := Vector2.ONE:
	get: return _basic_polygon_instance.offset_scale
	set(value): _basic_polygon_instance.offset_scale = value

@export_range(-89.9, 89.9, 0.1, "radians")
var offset_skew := 0.0:
	get: return _basic_polygon_instance.offset_skew
	set(value): _basic_polygon_instance.offset_skew = value

var offset_transform := Transform2D.IDENTITY:
	get: return _basic_polygon_instance.offset_transform
	set(value): _basic_polygon_instance.offset_transform = value

var _created_shape : PackedVector2Array:
	get: return _basic_polygon_instance._created_shape
	set(value): _basic_polygon_instance._created_shape = value

var _decomposed_created_shape : Array[PackedVector2Array]:
	get: return _basic_polygon_instance._decomposed_created_shape
	set(value): _basic_polygon_instance._decomposed_created_shape = value

var _collision_shapes : Array[Shape2D] = []:
	set(value):
		assert(value != null)

		for shape in _collision_shapes:
			shape.changed.disconnect(queue_redraw)

		_collision_shapes = value
		_basic_polygon_instance._queue_status = BasicPolygon2D._UNQUEUED

		queue_redraw()
		for shape in _collision_shapes:
			shape.changed.connect(queue_redraw)

		if _collision_object_parent == null:
			return

		_collision_object_parent.shape_owner_clear_shapes(_owner_id)
		for shape in value:
			_collision_object_parent.shape_owner_add_shape(_owner_id, shape)

		_update_shape_owner()


func _get_property_list() -> Array[Dictionary]:
	return [{
		name = "_decomposed_created_shape",
		type = TYPE_ARRAY,
		usage = PROPERTY_USAGE_STORAGE
	},
	{
		name = "_created_shape",
		type = TYPE_PACKED_VECTOR2_ARRAY,
		usage = PROPERTY_USAGE_STORAGE
	},
	{
		name = "_collision_shapes",
		type = TYPE_ARRAY,
		usage = PROPERTY_USAGE_STORAGE
	}]

var _collision_object_parent : CollisionObject2D = null
var _owner_id := -1

var _basic_polygon_instance : BasicPolygon2D

func get_created_shape() -> PackedVector2Array: return _created_shape
func get_created_shape_decomposed() -> Array[PackedVector2Array]: return _decomposed_created_shape
func get_created_shape_type() -> BasicPolygon2D.ShapeType: return _basic_polygon_instance.get_created_shape_type()

func _init() -> void:
	_basic_polygon_instance = BasicPolygon2D.new()
	_basic_polygon_instance.draw_shape = false
	_basic_polygon_instance.export_behaviour = BasicPolygon2D.ExportBehaviour.EDITOR | BasicPolygon2D.ExportBehaviour.RUN_TIME
	_basic_polygon_instance.shape_created.connect(_on_shape_created)
	add_child(_basic_polygon_instance, false, INTERNAL_MODE_FRONT)

func _on_shape_created(shape : PackedVector2Array, decomposed : Array[PackedVector2Array], type : BasicPolygon2D.ShapeType) -> void:
	match type:
		BasicPolygon2D.ShapeType.POLYGON:
			var shapes : Array[Shape2D] = []
			shapes.resize(decomposed.size())
			for i in decomposed.size():
				var convex_shape := ConvexPolygonShape2D.new()
				convex_shape.points = decomposed[i]
				shapes[i] = convex_shape
			_collision_shapes = shapes

		BasicPolygon2D.ShapeType.POLYLINE:
			var polyline := shape.duplicate()
			polyline.resize(polyline.size() * 2 - 2)
			for i in shape.size() - 1:
				var index := shape.size() - i - 1
				polyline[-i * 2 - 1] = polyline[index]
				polyline[-i * 2 - 2] = polyline[index - 1]

			var concave_shape := ConcavePolygonShape2D.new()
			concave_shape.segments = polyline
			_collision_shapes = [concave_shape]

		BasicPolygon2D.ShapeType.MULTILINE:
			var concave_shape := ConcavePolygonShape2D.new()
			concave_shape.segments = shape
			_collision_shapes = [concave_shape]


func _update_shape_owner() -> void:
	assert(_collision_object_parent != null)

	_collision_object_parent.shape_owner_set_transform(_owner_id, transform)
	_collision_object_parent.shape_owner_set_disabled(_owner_id, disabled)
	_collision_object_parent.shape_owner_set_one_way_collision(_owner_id, one_way_collision)
	_collision_object_parent.shape_owner_set_one_way_collision_margin(_owner_id, one_way_collision_margin)

func _enter_tree() -> void:
	if _collision_object_parent != null:
		_update_shape_owner()

func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_PARENTED:
			_collision_object_parent = get_parent() as CollisionObject2D
			if _collision_object_parent == null:
				return

			_owner_id = _collision_object_parent.create_shape_owner(self)
			for shape in _collision_shapes:
				_collision_object_parent.shape_owner_add_shape(_owner_id, shape)
			_update_shape_owner()
		NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
			if _collision_object_parent != null:
				_collision_object_parent.shape_owner_set_transform(_owner_id, transform)
		NOTIFICATION_UNPARENTED:
			if _collision_object_parent == null:
				return

			_collision_object_parent.remove_shape_owner(_owner_id)
			_collision_object_parent = null
			_owner_id = -1

func _draw() -> void:
	if not Engine.is_editor_hint() and (not is_inside_tree() or not get_tree().debug_collisions_hint):
		return

	if _collision_shapes.is_empty():
		return

	var debug_color : Color = ProjectSettings.get_setting("debug/shapes/collision/shape_color", Color("0099b36b"))
	var rid := get_canvas_item()
	var color := debug_color
	for shape in _collision_shapes:
		var color_actual := color
		if disabled:
			var gray := color.v
			color_actual = Color(gray, gray, gray, 0.25)
		shape.draw(rid, color_actual)
		color.h = fmod(color.h + 0.738, 1)

	if not one_way_collision:
		return

	color = debug_color.inverted()
	if disabled:
		color = color.darkened(0.25)

	var target := Vector2(0, 20)
	var size := 8
	var offset := Vector2(0.7071 * size, 0)
	draw_line(Vector2.ZERO, target, color, 2)
	draw_colored_polygon([target + Vector2(0, size), target + offset, target - offset], color)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := _basic_polygon_instance._get_configuration_warnings()

	if _collision_object_parent == null:
		warnings.push_back("BasicCollisionPolygon2D only serves to provide a collision shape to a CollisionObject2D derived node.\nPlease only use it as a child of Area2D, StaticBody2D, RigidBody2D, CharacterBody2D, etc. to give them a shape.")
	if one_way_collision and _collision_object_parent is Area2D:
		warnings.push_back("The One Way Collision property will be ignored when the collision object is an Area2D.")

	return warnings

func shape_count() -> int: return _collision_shapes.size()

func get_shape(index : int) -> Shape2D: return _collision_shapes[index]

func get_basic_polygon() -> BasicPolygon2D: return _basic_polygon_instance
