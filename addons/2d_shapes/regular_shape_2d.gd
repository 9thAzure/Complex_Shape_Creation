@tool
extends Node2D

# Todo: change the class description
## A node that simply draws a perfect shape

## The number of vertices in the perfect shape
## a value of 1 creates a circle, a value of 2 creates a line
@export_range(1,8,1,"or_greater") var vertices_count : int = 1:
	set(value):
		assert(vertices_count >= 1)
		vertices_count = value
		queue_redraw()

## The length of each corner to the center.
@export var size : float = 10:
	set(value):
		assert(size >= 0)
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

# ? not sure if this is a good name, may be changed.
@export_category("advanced")

# ? not sure if this is the correct term for it or if it is a good name for it.
# Todo: implement effects
## Creates a hole in the center of the shape, in the same shape. If "size" is set to 1 (circle), a 32 sized shape in its place.
## Produces a warning if it is set to a value smaller than 0 or greater than "size".
@export var hole_size : float = 0:
	set(value):
		if (value < 0):
			value = 0
			push_warning("attempted to set variable \"hole_size\" to a value smaller than 0, value is set to 0")
		if (value > size):
			value = size
			push_warning("attempted to set variable \"hole_size\" to a value greater than the variable \"size\", value set to \"size\": %s." % size)
		hole_size = value
		queue_redraw()

# Todo:
# this variable would cut out edges (eg: draw only have a hexagon, a trapezoid). To be implemented. Name is temporary.
# Exact implementation/way of working TBD.
# @export var shape_cut : int = 0

func _draw() -> void:
	if (vertices_count == 1):
		draw_circle(Vector2.ZERO, size, color)
		return
	
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
	
	var points := PackedVector2Array()
	var rotation_spacing := TAU / vertices_count
	# rotation is initialized pointing down and offset to the left so that the bottom is flat
	var current_rotation := rotation_spacing / 2 - offset_rotation
	for i in vertices_count:
		points.append(Vector2(sin(current_rotation), cos(current_rotation)) * size) 
		current_rotation += rotation_spacing
	# ! draw_colored_polygon doesn't take into account holes unlike Polygon2D, so this will have to be redone.
	if !is_zero_approx(hole_size):
		add_hole_to_points(points, hole_size / size)
	draw_colored_polygon(points, color)

# <section> helper functions for _draw()

## Returns a PackedVector2Array with the points needed for a regular shape with [b]vertices_count[/b] vertices.
## [b]size[/b] determines the distance the points are from the center of the shapes,
## and [b]offset_rotation[/b] offsets the points in radians.
static func get_shape_vertices(vertices_count : int, size : int = 1, offset_rotation : float = 0.0) -> PackedVector2Array:
	assert(vertices_count > 0)

	var points := PackedVector2Array()
	var rotation_spacing := TAU / vertices_count
	# rotation is initialized pointing down and offset to the left so that the bottom is flat
	var current_rotation := rotation_spacing / 2 - offset_rotation
	for i in vertices_count:
		points.append(Vector2(sin(current_rotation), cos(current_rotation)) * size) 
		current_rotation += rotation_spacing
	return points

## 
static func add_hole_to_points(points : PackedVector2Array, hole_scaler : float) -> void:
	points.append(points[0])
	var original_size := points.size()
	for i in original_size:
		points.append(points[i] * hole_scaler)
