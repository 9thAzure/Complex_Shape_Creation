@tool
extends Node2D

# Todo: change the class description
# ## A node that simply draws a perfect shape
## A node that draws regular shapes, with some additional modifiers. 

## The number of vertices in the perfect shape
## a value of 1 creates a circle, a value of 2 creates a line
@export_range(1,8,1,"or_greater") var vertices_count : int = 1:
	set(value):
		if value < 1:
			value = 1
		vertices_count = value
		queue_redraw()

## The length of each corner to the center.
@export var size : float = 10:
	set(value):
		if value <= 0:
			value = 0.00000001
		size = value
		queue_redraw()

## The color of the shape
@export var color : Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

# unfortunately, negative values are not working for export range
## The offset rotation of the shape, in degrees.
@export_range(0, 360, 0.1, "or_greater", "or_less") var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotation)

## the offset rotation of the shape, in radians
var offset_rotation : float = 0:
	set(value):
		offset_rotation = value
		queue_redraw()

func _draw() -> void:
	if (vertices_count == 1):
		draw_circle(Vector2.ZERO, size, color)
	
	if (vertices_count == 2):
		if offset_rotation == 0:
			draw_line(Vector2.UP * size, Vector2.DOWN * size, color)
			return
		var point1 := Vector2(sin(offset_rotation), cos(offset_rotation)) * size
		draw_line(point1, -point1, color)
		return
	
	if (vertices_count == 4 && offset_rotation == 0):
		const sqrt_two_over_two := 0.707106781
		draw_rect(Rect2(-Vector2.ONE * sqrt_two_over_two * size, Vector2.ONE * sqrt_two_over_two * size * 2), color)
		return
		
	draw_colored_polygon(get_shape_vertices(vertices_count, size, offset_rotation), color)

# <section> helper functions for _draw()

static func get_shape_vertices(vertices_count : int, size : float = 1, offset_rotation : float = 0.0, offset_position : Vector2 = Vector2.ZERO) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.resize(vertices_count)
	var rotation_spacing := TAU / vertices_count
	var current_rotation := rotation_spacing / 2 + offset_rotation
	for i in vertices_count:
		points[i] = Vector2(-sin(current_rotation), cos(current_rotation)) * size + offset_position
		current_rotation += rotation_spacing

	return points

static func _get_vertices(rotation : float, size : float = 1, offset : Vector2 = Vector2.ZERO) -> Vector2:
	return Vector2(-sin(rotation), cos(rotation)) * size + offset
	