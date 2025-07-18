@tool
@icon("res://addons/simplified_shape_creation/simple_polygon_2d/simple_polygon_2d.svg")
class_name SimplePolygon2D
extends Node2D

## Node that draws regular shapes.
##
## A node that draws a regular shape, using methods like [method CanvasItem.draw_colored_polygon] and [method CanvasItem.draw_circle]. 
## If more complex features are needed, use [RegularPolygon2D].


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

## Transforms [member CollisionShape2D.shape], rotating it by [param rotation] radians and scaling it by a factor of [param scaler].
func apply_transformation(rotation : float, scale : float) -> void:
	assert(scale > 0, "param 'scale' should be positive.")
	offset_rotation += rotation
	size *= scale

## see [member offset]
## @deprecated
@export
var offset_position := Vector2.ZERO:
	set(value):
		offset = value
	get:
		return offset

## The offset position of the shape.
var offset : Vector2 = Vector2.ZERO:
	set(value):
		offset = value
		queue_regenerate()

@export_range(0, 1, 0.001, "or_less")
var ring_ratio : float = 1.0:
	set(value):
		ring_ratio = value
		queue_regenerate()

@export_range(0, 360, 0.1, "or_greater", "or_less", "radians")
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

## Strategies for closing an open shape.
enum ClosingStrategy {
	## Shape is closed with two lines between the ends and the center of the shape.
	SLICE,
	## Shape is closed by connected the 2 ends together directly.
	CHORD,
	## Shape is left open. This only has an effect for lines, and is otherwise equivalent to [constant ClosingStrategy.CHORD].
	ARC,
}

@export
var closing_strategy : ClosingStrategy = ClosingStrategy.SLICE:
	set(value):
		closing_strategy = value
		queue_regenerate()

@export
var round_arc_ends : bool = false:
	set(value):
		round_arc_ends = value
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

@export_group("usage")

@export
var draw_shape := true:
	set(value):
		draw_shape = value
		queue_redraw()

## The color of the shape.
@export
var color : Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

@export_flags("Editor:1", "Run Time:2")
var export_behaviour : int = ExportBehaviour.DISABLED

enum ExportBehaviour {
	DISABLED = 0,
	EDITOR = 1,
	RUN_TIME = 2,
}

@export
var export_as_decomposed_hulls := false

@export
var targets : Array[NodePath] = []:
	set(value):
		if value == null:
			return
		targets = value
		update_configuration_warnings()

@export
var auto_free := false

signal shape_updated(shape : Variant)

var _created_shape : PackedVector2Array = []:
	set(value):
		_created_shape = value
		queue_disperse()
		queue_redraw()
#		if not is_inside_tree(): _queue_status = _QUEUE_PROPAGATION

var _decomposed_created_shape : Array[PackedVector2Array] = []:
	set(value):
		_decomposed_created_shape = value
		queue_disperse()
		queue_redraw()
#		if not is_inside_tree(): _queue_status = _QUEUE_PROPAGATION

# "_BLOCK_QUEUE" is used by _init to prevent regeneration of the shape when it is already set by PackedScene.instantiate().
const _NOT_QUEUED     := 0
const _IS_QUEUED      := 1
const _QUEUE_DISPERSE := 2

var _queue_status : int = _NOT_QUEUED

## A method for consistency across other nodes. [b]Equivalent to [method CanvasItem.queue_redraw].[/b]
func queue_regenerate() -> void:
	if _queue_status == _IS_QUEUED:
		return

	_queue_status = _IS_QUEUED
	if not is_inside_tree():
		return

	await get_tree().process_frame
	if _queue_status != _IS_QUEUED:
		return

	regenerate()

func _enter_tree() -> void:
	if _queue_status == _IS_QUEUED:
		regenerate()
	if _queue_status == _QUEUE_DISPERSE:
		_queue_status = _NOT_QUEUED
		queue_disperse()

## A method for consistency across other nodes, and does not even regenerate the shape immediately. [b]Equivalent to [method CanvasItem.queue_redraw].[/b]
func regenerate() -> void:
	_queue_status = _NOT_QUEUED

	var shape : PackedVector2Array
	var is_outline := is_zero_approx(ring_ratio)
	var is_ring_shape :=  not is_outline and ring_ratio < 1
	var arc_rotation := arc_end - arc_start
	var uses_arc := not is_equal_approx(arc_rotation, TAU)
	var rounded_corners := not is_zero_approx(corner_size)
	var true_corner_smoothness := corner_smoothness if corner_smoothness != 0 else maxi(1, 32 / vertices_count)

	var add_central_point := closing_strategy == ClosingStrategy.SLICE or closing_strategy == ClosingStrategy.ARC and is_equal_approx(ring_ratio, 1)
	shape = SimpleGeometry2d.create_shape(vertices_count, sizes, offset_rotation, offset_position, arc_start, arc_end, add_central_point)

	if rounded_corners:
		if not uses_arc:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness)
		elif not round_arc_ends or round_arc_ends and closing_strategy == ClosingStrategy.ARC and is_outline:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, 1, shape.size() - (3 if add_central_point else 2))
		elif closing_strategy == ClosingStrategy.SLICE:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, 0, shape.size() - 1)
		elif closing_strategy == ClosingStrategy.CHORD:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness)
		elif closing_strategy == ClosingStrategy.ARC and is_equal_approx(ring_ratio, 1):
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, 0, shape.size() - 1)

	if is_ring_shape:
		if not uses_arc or closing_strategy != ClosingStrategy.SLICE:
			SimpleGeometry2d.add_ring(shape, ring_ratio, offset_position, not uses_arc or closing_strategy == ClosingStrategy.CHORD)
		else: # uses_arc and closing_strategy == ClosingStrategy.SLICE
			var inner_arc_start := arc_start + TAU * ring_ratio / 2 / vertices_count
			var inner_arc_end := arc_end - TAU * ring_ratio / 2 / vertices_count
			if inner_arc_start < inner_arc_end:
				var inner_ring := SimpleGeometry2d.create_shape(vertices_count, sizes, offset_rotation, offset_position, inner_arc_start, inner_arc_end)

				shape.resize(shape.size() + inner_ring.size() + 1)
				shape[-1] = offset_position
				for i in inner_ring.size():
					shape[-i - 2] = inner_ring[i].lerp(offset_position, ring_ratio)

				if rounded_corners:
					var inner_corner_size := lerpf(corner_size, 0, ring_ratio)
					var inner_start := shape.size() - inner_ring.size()
					var inner_length := inner_ring.size() - 1
					if not round_arc_ends:
						inner_start += 1
						inner_length -= 2

					SimpleGeometry2d.add_rounded_corners(shape, inner_corner_size, true_corner_smoothness, inner_start, inner_length, false)

	if rounded_corners and uses_arc and closing_strategy == ClosingStrategy.ARC and round_arc_ends and is_ring_shape:
		var inner_corner_size := lerpf(corner_size, 0, ring_ratio)
		var original_size := shape.size()

		SimpleGeometry2d.add_rounded_corners(shape, inner_corner_size, true_corner_smoothness, original_size / 2, original_size / 2)
		SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, 0, original_size / 2, false)

	_created_shape = shape
	_decomposed_created_shape = Geometry2D.decompose_polygon_in_convex(shape)
	queue_redraw()

func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary] = []
	properties.append({
		name = "_created_shape",
		type = TYPE_PACKED_VECTOR2_ARRAY,
		usage = PROPERTY_USAGE_STORAGE
	})
	properties.append({
		name = "_decomposed_created_shape",
		type = TYPE_ARRAY,
		usage = PROPERTY_USAGE_STORAGE
	})

	return properties

func queue_disperse() -> void:
	if _queue_status == _QUEUE_DISPERSE:
		return

	_queue_status = _QUEUE_DISPERSE
	if not is_inside_tree():
		return

	await get_tree().process_frame
	if _queue_status != _QUEUE_DISPERSE:
		return

	disperse()

func disperse() -> void:
	_queue_status = _NOT_QUEUED

	var in_editor := Engine.is_editor_hint()
	if in_editor and (export_behaviour & ExportBehaviour.EDITOR) > 0 or not in_editor and (export_behaviour & ExportBehaviour.RUN_TIME) > 0:
		var exported_objects : Variant = _decomposed_created_shape if export_as_decomposed_hulls else _created_shape
		shape_updated.emit(exported_objects)
		for path in targets:
			var node := self if path.get_name_count() == 0 else get_node(NodePath(String(path.get_concatenated_names())))
			assert(node != null)
			node.set_indexed(NodePath(String(path.get_concatenated_subnames())), exported_objects)

	if not in_editor and auto_free:
		queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if is_equal_approx(arc_start, arc_end):
		warnings.push_back("The arc of the shape is 0º, so nothing will be created")

	for i in targets.size():
		var path := targets[i]
		print("\nprocessing %s" % i)
		print(path, " | ", path == null)
		if path.is_empty():
			warnings.push_back("The export path at index %s is unassigned." % i)
			continue

		var node_path := NodePath(String(path.get_concatenated_names()))
		print("n: ", node_path)
		var node := get_node_or_null(node_path)
		if node == null:
			warnings.push_back("The export path at index %s points to a non existant node" % i)
			continue

		print("p: ", path.get_concatenated_subnames())
		if path.get_subname_count() == 0:
			warnings.push_back("The export path at index %s does not reference a property" % i)
			continue

		var previous_object : Variant = node
		var failure := false
		for i2 in path.get_subname_count() - 1:
			var property := path.get_subname(i2)
			if not (property in previous_object):
				warnings.push_back("The export path at index %s has a non-existant property reference at subname #%s (%s)" % [i, i2, property])
				failure = true
				break

			previous_object = previous_object.get(property)
			if typeof(previous_object) != TYPE_OBJECT or previous_object == null:
				warnings.push_back("The export path at index %s has a property reference which is null or isn't of type Object at subname #%s (type: %s)" % [i, i2, "null" if previous_object == null else type_string(typeof(previous_object))])
				failure = true
				break

		if failure:
			continue

		var last_i = path.get_subname_count() - 1
		var property := path.get_subname(last_i)
		if not (property in previous_object):
			warnings.push_back("The export path at index %s points to a non-existant property (%s)" % [i, path.get_concatenated_subnames()])
			continue

		var type := typeof(previous_object.get(property))
		if type != TYPE_PACKED_VECTOR2_ARRAY and type != TYPE_ARRAY:
			warnings.push_back("The export path at index %s points to a property that is either currently null or not an Array or PackedVector2Array (type: %s)" % [i, type_string(type)])
			continue

	return warnings

func _draw() -> void:
#	if (vertices_count == 1):
#		draw_circle(offset, size, color)
#		return
#
#	if (vertices_count == 2):
#		if offset_rotation == 0:
#			draw_line(Vector2.UP * size + offset, Vector2.DOWN * size + offset, color)
#			return
#
#		var point1 := Vector2(sin(offset_rotation), -cos(offset_rotation)) * size
#		draw_line(point1 + offset, -point1 + offset, color)
#		return
#
#	if (vertices_count == 4 && offset_rotation == 0):
#		const sqrt_two_over_two := 0.707106781
#		draw_rect(Rect2(offset - Vector2.ONE * sqrt_two_over_two * size, Vector2.ONE * sqrt_two_over_two * size * 2), color)
#		return
	if not draw_shape:
		return

	if is_zero_approx(ring_ratio):
		draw_polyline(_created_shape, color)
		if closing_strategy != ClosingStrategy.ARC:
			draw_line(_created_shape[-1], _created_shape[0], color)
		return

	#	draw_polyline(shape, Color.RED)
	#	draw_line(shape[-1], shape[0], Color.RED)

	for hull in _decomposed_created_shape:
		draw_colored_polygon(hull, color)
	#		draw_polyline(hull, Color.BLUE)
	#		draw_line(hull[-1], hull[0], Color.BLUE)

	#	draw_polyline(shape, Color.RED)
	#	draw_line(shape[-1], shape[0], Color.RED)

func _init(vertices_count : int = 1, size := 10.0, offset_rotation := 0.0, color := Color.WHITE, offset_position := Vector2.ZERO):
	if vertices_count != 1:
		self.vertices_count = vertices_count
	if size != 10.0:
		self.size = size
	if offset_rotation != 0.0:
		self.offset_rotation = offset_rotation
	if color != Color.WHITE:
		self.color = color
	if offset_position != Vector2.ZERO:
		self.offset = offset_position

static var _circle := get_shape_vertices(32)

## Returns a [PackedVector2Array] with the points for the shape with the specified [param vertices_count].
## [br][br]If [param vertices_count] is [code]1[/code], a value of [code]32[/code] is used instead.
static func get_shape_vertices(vertices_count : int, size : float = 1, offset_rotation : float = 0.0, offset_position : Vector2 = Vector2.ZERO) -> PackedVector2Array:
	assert(vertices_count >= 1, "param 'vertices_count' must be 1 or greater.")
	assert(size > 0, "param 'size' must be positive.")
	
	if vertices_count == 1:
		return _circle * Transform2D(-offset_rotation, Vector2.ONE * size, 0, offset_position)

	var points := PackedVector2Array()
	points.resize(vertices_count)
	var rotation_spacing := TAU / vertices_count
	var current_rotation := -rotation_spacing / 2 + offset_rotation
	for i in vertices_count:
		points[i] = Vector2(-sin(current_rotation), cos(current_rotation)) * size + offset_position
		current_rotation += rotation_spacing

	return points

static func _get_vertices(rotation : float, size : float = 1, offset : Vector2 = Vector2.ZERO) -> Vector2:
	return Vector2(-sin(rotation), cos(rotation)) * size + offset
