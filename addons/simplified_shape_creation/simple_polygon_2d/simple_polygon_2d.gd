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
		queue_redraw()

## The length from each corner to the center of the shape.
#@export_range(0.000001, 10, 0.001, "or_greater", "hide_slider")
var size : float = 10:
	get:
		return sizes[0]
	set(value):
		sizes[0] = value
		queue_redraw()

@export
var sizes : PackedFloat64Array = PackedFloat64Array([10]):
	set(value):
		if value.size() == 0:
			return

		for i in value.size():
			if value[i] < 0.001:
				value[i] = 0.001 if i >= sizes.size() else sizes[i]


		sizes = value
		queue_redraw()

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
		queue_redraw()

## Transforms [member CollisionShape2D.shape], rotating it by [param rotation] radians and scaling it by a factor of [param scaler].
func apply_transformation(rotation : float, scale : float) -> void:
	assert(scale > 0, "param 'scale' should be positive.")
	offset_rotation += rotation
	size *= scale

## The color of the shape.
@export
var color : Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

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
		queue_redraw()

@export_range(0, 1, 0.001, "or_less")
var ring_ratio : float = 1.0:
	set(value):
		ring_ratio = value
		queue_redraw()

@export_range(0, 360, 0.1, "or_greater", "or_less", "radians")
var arc_start : float = 0.0:
	set(value):
		arc_start = value
		update_configuration_warnings()
		queue_redraw()

@export_range(0, 360, 0.1, "or_greater", "or_less", "radians")
var arc_end : float = TAU:
	set(value):
		arc_end = value
		update_configuration_warnings()
		queue_redraw()

var arc_start_degrees : float = 0.0:
	get:
		return rad_to_deg(arc_start)
	set(value):
		arc_start = deg_to_rad(value)

var arc_end_degrees : float = TAU:
	get:
		return rad_to_deg(arc_end)
	set(value):
		arc_end = deg_to_rad(value)

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
		queue_redraw()

@export
var round_arc_ends : bool = false:
	set(value):
		round_arc_ends = value
		queue_redraw()

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

## A method for consistency across other nodes. [b]Equivalent to [method CanvasItem.queue_redraw].[/b]
func queue_regenerate() -> void:
	queue_redraw()

## A method for consistency across other nodes, and does not even regenerate the shape immediately. [b]Equivalent to [method CanvasItem.queue_redraw].[/b]
func regenerate() -> void:
	queue_redraw()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if is_equal_approx(arc_start, arc_end):
		warnings.push_back("the arc of the shape is 0º, so nothing will be created")

	return warnings

func _draw() -> void:
	var shape : PackedVector2Array
	var is_outline := is_zero_approx(ring_ratio)
	var is_ring_shape :=  not is_outline and ring_ratio < 1
	var arc_rotation := arc_end - arc_start
	var uses_arc := not is_equal_approx(arc_rotation, TAU)
	var rounded_corners := not is_zero_approx(corner_size)
	var true_corner_smoothness := corner_smoothness if corner_smoothness != 0 else maxi(1, 32 / vertices_count)
	if (vertices_count == 1):
		draw_circle(offset, size, color)
		return
	
	if (vertices_count == 2):
		if offset_rotation == 0:
			draw_line(Vector2.UP * size + offset, Vector2.DOWN * size + offset, color)
			return
		
		var point1 := Vector2(sin(offset_rotation), -cos(offset_rotation)) * size
		draw_line(point1 + offset, -point1 + offset, color)
		return
	
	if (vertices_count == 4 && offset_rotation == 0):
		const sqrt_two_over_two := 0.707106781
		draw_rect(Rect2(offset - Vector2.ONE * sqrt_two_over_two * size, Vector2.ONE * sqrt_two_over_two * size * 2), color)
		return

	shape = SimpleGeometry2d.create_shape(vertices_count, sizes, offset_rotation, offset_position, arc_start, arc_end, closing_strategy == ClosingStrategy.SLICE)

	if rounded_corners:
		if not uses_arc:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness)
		elif not round_arc_ends or closing_strategy == ClosingStrategy.ARC:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, 1, shape.size() - (3 if closing_strategy == ClosingStrategy.SLICE else 2))
		elif closing_strategy == ClosingStrategy.CHORD:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness)
		elif closing_strategy == ClosingStrategy.SLICE:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, 0, shape.size() - 1)

	if is_ring_shape:
		if not uses_arc or closing_strategy != ClosingStrategy.SLICE:
			SimpleGeometry2d.add_ring(shape, ring_ratio, offset_position, not uses_arc or closing_strategy == ClosingStrategy.CHORD)
		else:
			var inner_arc_start := arc_start + TAU * ring_ratio / 2 / vertices_count
			var inner_arc_end := arc_end - TAU * ring_ratio / 2 / vertices_count
			if inner_arc_start < inner_arc_end:
				var inner_ring := SimpleGeometry2d.create_shape(vertices_count, sizes, offset_rotation, offset_position, inner_arc_start, inner_arc_end)

				shape.resize(shape.size() + inner_ring.size() + 1)
				shape[-1] = offset_position
				for i in inner_ring.size():
					shape[-i - 2] = inner_ring[i].lerp(offset_position, ring_ratio)

	if rounded_corners:
		if uses_arc and round_arc_ends and closing_strategy == ClosingStrategy.ARC:
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, shape.size() / 2 - 1, 2, true)
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, 0, 1, true)
			SimpleGeometry2d.add_rounded_corners(shape, corner_size, true_corner_smoothness, shape.size() - 1, 1, true)

	if is_outline:
		draw_polyline(shape, color)
		if closing_strategy != ClosingStrategy.ARC:
			draw_line(shape[-1], shape[0], color)
		return

#	draw_polyline(shape, Color.RED)
#	draw_line(shape[-1], shape[0], Color.RED)

	var hulls := Geometry2D.decompose_polygon_in_convex(shape)
	for hull in hulls:
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
