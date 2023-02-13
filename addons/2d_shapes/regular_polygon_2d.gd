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
		if corner_size != 0:
			corner_size = corner_size
			return
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

## Determines the width of the shape. A value of 0 creates an outline of the shape, and a value smaller than 0 ignores this effect.
@export var width : float = -1:
	set(value):
		width = value
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
		corner_size = get_side_length(vertices_count) * size / 2
		if value < corner_size:
			corner_size = value
		pre_redraw()

# Todo: implement effects
@export_range(0, 8, 1, "or_greater") var corner_smoothness : int = 0:
	set(value):
		corner_smoothness = value
		pre_redraw()

# used to signal when _draw should be used.
var _use_draw := true

func _ready():
	pre_redraw()

## called when shape properties are updated, before "_draw".
func pre_redraw() -> void:
	if width <= 0 || vertices_count == 2:
		_use_draw = true
		polygon = PackedVector2Array()
		return

	# shape has hole here.
	_use_draw = false
	var points = get_shape_vertices(36 if vertices_count == 1 else vertices_count, size, offset_rotation)
	add_hole_to_points(points, 1 - width / size)
	polygon = points

func _draw():
	if not _use_draw:
		return
	
	# at this point, width <= 0
	# if there is no advanced features, check for other draw calls.
	if vertices_count == 1:
		draw_circle(Vector2.ZERO, size, color)
		return
	
	if vertices_count == 2:
		var point = Vector2(sin(-offset_rotation), cos (-offset_rotation)) * size
		draw_line(point, -point, color)
		return
		
	if vertices_count == 4 and is_zero_approx(offset_rotation) and not is_zero_approx(width) and is_zero_approx(corner_size):
		const sqrt_two_over_two := 0.707106781
		draw_rect(Rect2(-Vector2.ONE * sqrt_two_over_two * size, Vector2.ONE * sqrt_two_over_two * size * 2), color)
		return
		# no matches, using default drawing.

	var points = get_shape_vertices(vertices_count, size, offset_rotation)

	if not is_zero_approx(corner_size):
		points = get_rounded_corners(points, corner_size, corner_smoothness)

	if is_zero_approx(width):
		for i in vertices_count:
			draw_line(points[vertices_count - i - 1], points[vertices_count - i - 2], color)
		return
	
	draw_colored_polygon(points, color)

# <section> helper functions for _draw()

func _draw_shape_outline(points : PackedVector2Array) -> void:
	var size = points.size()
	for i in size:
		draw_line(points[size - i - 1], points[size - i - 2], color)

static func get_side_length(vertices_count : int):
	if vertices_count <= 1: return PI
	if vertices_count == 2: return 1
	return 2 * sin(TAU / vertices_count / 2)

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

static func get_rounded_corners(points : PackedVector2Array, corner_size : float, corner_smoothness : int) -> PackedVector2Array:
	if corner_smoothness == 0:
		corner_smoothness = 36 / points.size()
	var new_points := PackedVector2Array()
	var index_factor := corner_smoothness + 1
	new_points.resize(points.size() * index_factor)

	var last_point := points[-1]
	var current_point := points[0]
	var next_point : Vector2
	for i in points.size():
		next_point = points[(i + 1) % points.size()]
		
		# get starting & ending points of corner.
		var starting_slope := (current_point - last_point).normalized()
		var ending_slope := (current_point - next_point).normalized()
		var starting_point = current_point - starting_slope * corner_size
		var ending_point = current_point - ending_slope * corner_size

		new_points[i * index_factor] = starting_point
		new_points[i * index_factor + index_factor - 1] = ending_point

		# Quadratic Bezier curves are use because we have all three required points already. It isn't perfect though.
		# sub_i is initialized with a value of 1 as a corner_smoothness of 1 has no between points.
		var sub_i := 1
		while sub_i < corner_smoothness:
			var t_value := sub_i / (corner_smoothness as float)
			new_points[i * index_factor + sub_i] = quadratic_bezier_interpolate(starting_point, points[i], ending_point, t_value)
			sub_i += 1
		
		# end, prep for next loop.
		last_point = current_point
		current_point = next_point

	return new_points

static func quadratic_bezier_interpolate(start : Vector2, control : Vector2, end : Vector2, t : float) -> Vector2:
	return control + (t - 1) ** 2 * (start - control) + t ** 2 * (end - control)

## 
static func add_hole_to_points(points : PackedVector2Array, hole_scaler : float) -> void:
	points.append(points[0])
	var original_size := points.size()
	for i in original_size:
		points.append(points[original_size - i - 1] * hole_scaler)
