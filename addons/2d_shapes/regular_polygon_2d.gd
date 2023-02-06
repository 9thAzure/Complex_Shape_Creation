@tool
extends Polygon2D

# Todo: change the class description
## A node that simply draws a perfect shape

## The number of vertices in the perfect shape
## a value of 1 creates a circle, a value of 2 creates a line
@export_range(1,8,1,"or_greater") var vertices_count : int = 1:
	set(value):
		assert(vertices_count >= 1)
		vertices_count = value
		pre_redraw()

## The length from each corner to the center.
@export var size : float = 10:
	set(value):
		assert(size >= 0)
		size = value
		pre_redraw()

# negative values are not working for export range
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
		pre_redraw()

# ? not sure if this is a good name for it and many of the properties under it, they may need changing.
@export_category("advanced")

# Todo: implement effects, convert to "width"
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
		pre_redraw()

# Todo: implement effects
# this variable would cut out edges (eg: draw only have a hexagon, a trapezoid). To be implemented. Name is temporary.
# Exact implementation/way of working TBD.
## Cuts out vertices of the shape, as a percentage. Cuts are only made at the corners.
@export_range(0, 1, 0.0001) var shape_cut_percentage : float = 0.0:
	set(value):
		shape_cut_percentage = value
		self.queue_redraw()
		pre_redraw()

# Todo: implement check, effects
@export_range(0, 5, 0.01, "or_greater") var corner_size : float = 0.0:
	set(value):
		corner_size = value
		pre_redraw()

# Todo: implement effects
@export_range(1, 8, 1, "or_greater") var corner_smoothness : int = 1:
	set(value):
		corner_smoothness = value
		pre_redraw()

func _ready():
	pre_redraw()

# Todo: _draw will have to be changed as "polygon" is drawn before _draw() is called.
func pre_redraw() -> void:
	pass
	# var points = get_shape_vertices(vertices_count, size, offset_rotation)
	# if !is_zero_approx(hole_size):
	# 	add_hole_to_points(points, hole_size / size)

	# polygon = points
	# super.queue_redraw()

func _draw():
	var points = get_shape_vertices(vertices_count, size, offset_rotation)
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
		points.append(points[original_size - i - 1] * hole_scaler)
