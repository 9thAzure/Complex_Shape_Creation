@tool
@icon("res://addons/2d_regular_polygons/simple_polygon_2d.svg")
class_name SimplePolygon2D
extends Node2D

## Node that draws regular shapes.
##
## A node that draws a regular shape, using methods like [method CanvasItem.draw_colored_polygon] and [method CanvasItem.draw_circle]. 
## If more complex features are needed, use [RegularPolygon2D].


## The number of vertices in the perfect shape. A value of [code]1[/code] creates a circle, and a value of [code]2[/code] creates a line.
## Values are clamped to a value greater than or equal to [code]1[/code].
@export_range(1, 8, , "or_greater")
var vertices_count : int = 1:
	set(value):
		assert(value < 2000, "Large vertices counts should not be necessary.")
		vertices_count = value
		if value < 1:
			vertices_count = 1

		queue_redraw()

## The length from each corner to the center. Values are clamped to a value greater than [code]0[/code].
@export_range(0.000001, 10, , "or_greater", "hide_slider")
var size : float = 10:
	set(value):
		size = value
		assert(value > 0, "property 'size' must be greater than 0.");
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

## The color of the shape.
@export
var color : Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

## The offset position of the shape.
@export
var offset_position : Vector2 = Vector2.ZERO:
	set(value):
		offset_position = value
		queue_redraw()

func _draw() -> void:
	if (vertices_count == 1):
		draw_circle(Vector2.ZERO, size, color)
		return
	
	if (vertices_count == 2):
		if offset_rotation == 0:
			draw_line(Vector2.UP * size, Vector2.DOWN * size, color)
			return
		
		var point1 := Vector2(sin(offset_rotation), -cos(offset_rotation)) * size
		draw_line(point1, -point1, color)
		return
	
	if (vertices_count == 4 && offset_rotation == 0):
		const sqrt_two_over_two := 0.707106781
		draw_rect(Rect2(-Vector2.ONE * sqrt_two_over_two * size, Vector2.ONE * sqrt_two_over_two * size * 2), color)
		return
		
	draw_colored_polygon(get_shape_vertices(vertices_count, size, offset_rotation, offset_position), color)

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
		self.offset_position = offset_position

## Returns a [PackedVector2Array] with the points for the shape with the specified [param vertices_count].
## [br][br]If [param vertices_count] is [code]1[/code], a value of [code]32[/code] is used instead.
static func get_shape_vertices(vertices_count : int, size : float = 1, offset_rotation : float = 0.0, offset_position : Vector2 = Vector2.ZERO) -> PackedVector2Array:
	assert(vertices_count >= 1, "param 'vertices_count' must be 1 or greater.")
	assert(size > 0, "param 'size' must be positive.")
	
	if vertices_count == 1:
		vertices_count = 32

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
	