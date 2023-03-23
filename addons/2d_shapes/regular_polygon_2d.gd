@tool
extends Polygon2D

## A node that draws regular shapes, with some advanced properties. 
##
## A node that draws regular shapes, with some advanced properties.
## It mainly uses draw_* methods, but may use the [member polygon] property when using [member width].
## Some properties don't affect circles and lines, and some properties will have a 32-sided shape used instead of a circle.

## The number of vertices in the perfect shape. A value of 1 creates a circle, and a value of 2 creates a line.
## [br]Values are clamped to a value greater than or equal to 1.
## [br][br]Note: Some properties don't affect circles and lines, and some properties will have a 32-sided shape used instead of a circle.
@export_range(1,8,1,"or_greater") 
var vertices_count : int = 1:
	set(value):
		assert(value < 2000, "Large vertices counts should not be necessary.")
		vertices_count = value
		if value < 1:
			vertices_count = 1
		
		if corner_size != 0:
			corner_size = corner_size
			return
		
		_pre_redraw()

## The length from each corner to the center.
## [br]Values are clamped to a value greater than 0.
@export 
var size : float = 10:
	set(value):
		size = value
		if value <= 0:
			size = 0.000001	
		
		_pre_redraw()

## The offset rotation of the shape, in degrees.
@export_range(-360, 360, 0.1, "or_greater", "or_less") 
var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotation)

## the offset rotation of the shape, in radians.
var offset_rotation : float = 0:
	set(value):
		offset_rotation = value
		_pre_redraw()

# ? not sure if this is a good name for it and many of the properties under it, they may need changing.
@export_group("advanced")

# The default value is -0.001 so that dragging it into positive values is quick.
## Determines the width of the shape. A value of 0 outlines the shape with lines, and a value smaller than 0 ignores this effect.
## Values greater than 0 will have [member polygon] used,
## and value greater than [member size] also ignores this effect still while using [member polygon].
## [br][br]Note: A value between 0 and 0.01 is converted to 0, to make it easier to select it in the editor.
@export 
var width : float = -0.001:
	set(value):
		width = value
		if width > 0 and width < 0.01:
			width = 0
		
		_pre_redraw()

## The arc of the drawn shape, in degrees, cutting off beyond that arc. 
## Values greater than [code]360[/code] or [code]-360[/code] draws a full shape. It starts in the middle of the base of the shapes. 
## [br]The direction of the arc is clockwise with positive values and counterclockwise with negative values.
## [br][br]Note: a value of [code]0[/code] makes the node not draw anything.
@export_range(-360, 360) 
var drawn_arc_degrees : float = 360:
	set(value):
		drawn_arc = deg_to_rad(value)
	get:
		return rad_to_deg(drawn_arc)

## The arc of the drawn shape, in radians, cutting off beyond that arc. 
## Values greater than [constant @GDScript.TAU] or -[constant @GDScript.TAU] draws a full shape. It starts in the middle of the base of the shapes. 
## [br]The direction of the arc is clockwise with positive values and counterclockwise with negative values.
## [br][br]Note: a value of [code]0[/code] makes the node not draw anything.
var drawn_arc : float = TAU:
	set(value):
		drawn_arc = value
		_pre_redraw()

## The distance from each vertex to the point where the rounded corner starts. Values are clamped to 0 and half of the side length.
## If this value is over half of the edge length, the mid-point of the edge is used instead.
## [br]Values are clamped to a value of [code]0[/code] or greater.
@export 
var corner_size : float = 0.0:
	set(value):
		corner_size = get_side_length(vertices_count) * size / 2
		if value < corner_size:
			corner_size = value
			if value < 0:
				corner_size = 0
		
		_pre_redraw()

## How many lines make up the corner. A value of 0 will use a value of 32 divided by [member vertices_count].
## [br]Values are clamped to a value of [code]0[/code] or greater.
@export_range(0, 8, 1, "or_greater") 
var corner_smoothness : int = 0:
	set(value):
		corner_smoothness = value
		if value < 0:
			corner_smoothness = 0
		
		_pre_redraw()


# Because the default values don't use the 'polygon' member, calling it in _ready is not needed.
# Changing the properties to use the polygon member will have _pre_redraw called anyways.

var _is_queued := false

# Called when shape properties are updated, before [method _draw]/[method queue_redraw]. Calls [method queue_redraw] automatically.
# queue-like functionality - pauses, and only 1 call.
func _pre_redraw() -> void:
	if _is_queued:
		return
	_is_queued = true
	call_deferred("_pre_redraw_deferred")

func _pre_redraw_deferred():
	_is_queued = false
	if not _uses_polygon_member():
		# the setting the 'polygon' property already calls queue_redraw
		polygon = PackedVector2Array()
		return
	
	_draw_using_polygon()

# ? I've got a basic testing uv working, not sure if it is fool proof.
func _draw():
	if _uses_polygon_member() or drawn_arc == 0:
		return
	
	# at this point, width <= 0
	# if there is no advanced features, check for other draw calls.
	if vertices_count == 1:
		if drawn_arc < TAU or drawn_arc > -TAU:
			draw_colored_polygon(get_shape_vertices(32, size, offset_rotation, offset, drawn_arc), color)
			return
		draw_circle(offset, size, color)
		return
	
	if vertices_count == 2:
		var point = Vector2(sin(-offset_rotation), cos (-offset_rotation)) * size
		draw_line(point + offset, -point + offset, color, -1.0, antialiased)
		return
		
	if (vertices_count == 4 
		and is_zero_approx(offset_rotation)
		# and not is_zero_approx(width)
		and is_zero_approx(corner_size)
		and (drawn_arc >= TAU or drawn_arc <= -TAU)
		and texture == null
	):
		const sqrt_two_over_two := 0.707106781
		var rect = Rect2(-Vector2.ONE * sqrt_two_over_two * size + offset, Vector2.ONE * sqrt_two_over_two * size * 2)
		if is_zero_approx(width):
			draw_rect(rect, color, false)
			return
		# Using the width param would require having all the checks here also be in the pre_redraw function as well.
		draw_rect(rect, color)
		return
		# no matches, using default drawing.

	var points = get_shape_vertices(vertices_count, size, offset_rotation, offset, drawn_arc)
	if not is_zero_approx(corner_size):
		points = get_rounded_corners(points, corner_size, corner_smoothness if corner_smoothness != 0 else 32 / vertices_count)

	if is_zero_approx(width):
		points.append(points[0])
		# antialiased is used here because it only works when width > 0
		draw_polyline(points, color)
		return
	
	if texture != null:
		var uv_points := uv
		if uv_points.size() != points.size():
			uv_points = points.duplicate()
		
		var uv_scale_x := 1.0 / texture.get_width()
		var uv_scale_y := 1.0 / texture.get_height()
		# The scale doesn't need to be reversed, for some reason.
		var transform := Transform2D(-texture_rotation, texture_scale, 0, -texture_offset)
		uv_points *= transform
		for i in uv_points.size():
			var uv_point := uv_points[i]
			uv_point.x *= uv_scale_x
			uv_point.y *= uv_scale_y
			uv_points[i] = uv_point
		
		draw_colored_polygon(points, color, uv_points, texture)
		return
	
	draw_colored_polygon(points, color)

func _draw_using_polygon():
	if drawn_arc == 0:
		polygon = PackedVector2Array()
		return
	
	var points = get_shape_vertices(vertices_count, size, offset_rotation, Vector2.ZERO, drawn_arc)
	var uses_width := width < size
	var uses_drawn_arc := _uses_drawn_arc()
	if uses_width and uses_drawn_arc:
		points.remove_at(points.size() - 1)
		add_hole_to_points(points, 1 - width / size, not _uses_drawn_arc())

	if not is_zero_approx(corner_size):
		points = get_rounded_corners(points, corner_size, corner_smoothness if corner_smoothness != 0 else 32 / vertices_count)

	if uses_width and not uses_drawn_arc:
		add_hole_to_points(points, 1 - width / size, not _uses_drawn_arc())
	
	polygon = points

func _uses_polygon_member() -> bool:
	return (
		width > 0
		and vertices_count != 2
	)

func _uses_drawn_arc() -> bool:
	return -TAU < drawn_arc and drawn_arc < TAU

# <section> helper functions for _draw()

## Gets the side length of a shape with the specified vertices amount, each being a distance of 1 away from the center.
## If [param vertices_count] is 1, PI is returned. If it is 2, 1 is returned.
static func get_side_length(vertices_count : int):
	assert(vertices_count >= 1)
	if vertices_count == 1: return PI
	if vertices_count == 2: return 1
	return 2 * sin(TAU / vertices_count / 2)

## Returns a [PackedVector2Array] with the points for drawing the shape with [method CanvasItem.draw_colored_polygon].
## [br][br]If [param vertices_count] is 1, a value of 32 is used instead.
## [br][param drawn_arc] only returns the vertices up to the specified angle, in radians, and includes a central point. 
## It starts in the middle of the base of the shape. Positive values go clockwise, negative values go counterclockwise
static func get_shape_vertices(vertices_count : int, size : float = 1, offset_rotation : float = 0.0, offset_position : Vector2 = Vector2.ZERO, drawn_arc : float = TAU) -> PackedVector2Array:
	assert(vertices_count >= 1, "param 'vertices_count' must be 1 or greater.")
	assert(size > 0, "param 'size' must be positive.")
	assert(drawn_arc != 0, "param 'drawn_arc' cannot be 0")

	if vertices_count == 1:
		vertices_count = 32
	
	var points := PackedVector2Array()
	var sign := signf(drawn_arc)
	var rotation_spacing := TAU / vertices_count * sign
	
	# If drawing a full shape
	if drawn_arc >= TAU or drawn_arc <= -TAU:
		# rotation is initialized pointing down and offset to the left so that the bottom is flat
		var current_rotation := rotation_spacing / 2 + offset_rotation
		for i in vertices_count:
			points.append(_get_vertices(current_rotation, size, offset_position))
			current_rotation += rotation_spacing
		return points
			
	# Drawing a partial shape.
	var current_rotation := -rotation_spacing / 2 + offset_rotation
	var limit := sign * (drawn_arc + offset_rotation)
	var fail_safe := 0
	# print(limit)
	while sign * current_rotation < limit:
		fail_safe += 1
		assert(fail_safe < vertices_count + 5, "fail_safe: infinite loop!")
		var point := _get_vertices(current_rotation, size, offset_position)
		points.append(point)
		current_rotation += rotation_spacing
	
	# Setting center point.
	var first_point := points[0]
	var vector_to_second := (points[1] if points.size() != 1 else _get_vertices(current_rotation, size, offset_position)) - first_point
	points[0] = first_point + vector_to_second / 2

	if is_equal_approx(current_rotation, drawn_arc):
		points.append(_get_vertices(current_rotation, size, offset_position)) 
	else:
		# variable names in formula: P, _, Q, R
		var last_point := points[-1]
		var next_point := _get_vertices(current_rotation, size, offset_position)
		var edge_slope := next_point - last_point 
		var ending_slope := _get_vertices(drawn_arc + offset_rotation)
		# formula variables: P, Q, S, R
		var scaler := _find_intersection(last_point, edge_slope, offset_position, ending_slope)
		var edge_point := last_point + scaler * edge_slope
		points.append(edge_point)
	
	if not is_equal_approx(drawn_arc, PI):
		points.append(offset_position)
			
	return points

# gets the vertices for a particular rotation and size, with a positional offset.
static func _get_vertices(rotation : float, size : float = 1, offset : Vector2 = Vector2.ZERO) -> Vector2:
	return Vector2(-sin(rotation), cos(rotation)) * size + offset

# finds the intersection between 2 points and their slopes. The value returned is not the point itself, but a scaler.
# The point would be obtained by (where a = returned value of function): point1 + a * slope1
static func _find_intersection(point1 : Vector2, slope1 : Vector2, point2: Vector2, slope2: Vector2) -> float:
	var numerator := slope2.y * (point2.x - point1.x) - slope2.x * (point2.y - point1.y)
	var devisor := (slope1.x * slope2.y) - (slope1.y * slope2.x)
	assert(devisor != 0, "one or both slopes are 0, or are parallel")
	return numerator / devisor 
	
# Todo: change implementation to do the changes in array. This makes it more consistent with other static methods.
## Returns a new [PackedVector2Array] with the points for drawing the rounded shape with [method CanvasItem.draw_colored_polygon], using quadratic Bézier curves. 
## [br][br][param corner_size] is the distance from a vertex to the point where the rounded corner starts. 
## If the this distance is over half the edge length, the halfway point of the edge is used instead.
## [br][param corner_smoothness] dictates the amount of lines used to draw the corner. 
## A value of 0 will instead use a value of [code]32[/code] divided by the size of [param points].
static func get_rounded_corners(points : PackedVector2Array, corner_size : float, corner_smoothness : int) -> PackedVector2Array:
	assert(points.size() >= 3, "param 'points' must have at least 3 points")
	assert(corner_size >= 0, "param 'corner_size' must be 0 or greater")
	assert(corner_smoothness >= 0, "param 'corner_smoothness' must be 0 or greater")
	
	var corner_size_squared = corner_size ** 2
	var array_size := points.size()
	var new_points := PackedVector2Array()
	if corner_smoothness == 0:
		corner_smoothness = 32 / points.size()

	# Rename to corner_index_size
	var corner_index_size := corner_smoothness + 1
	
	# resize the current one instead.
	new_points.resize(array_size * corner_index_size)
	# spread the old points throughout the array. They would be at the start of each "corner".

	# -corner_index_size
	var last_point := points[-1]
	var current_point := points[0]
	var next_point : Vector2
	for i in array_size:
		# (i + 1) * corner_index_size % points.size()
		next_point = points[(i + 1) % points.size()]
		# get starting & ending points of corner.
		var starting_slope := (current_point - last_point)
		var ending_slope := (current_point - next_point)
		var starting_point : Vector2
		var ending_point : Vector2
		if starting_slope.length_squared() / 4 < corner_size_squared:
			starting_point = current_point - starting_slope / 2
		else:
			starting_point = current_point - starting_slope.normalized() * corner_size
		
		if ending_slope.length_squared() / 4 < corner_size_squared:
			ending_point = current_point - ending_slope / 2
		else:
			ending_point = current_point - ending_slope.normalized() * corner_size

		# Done in array 'points'.
		new_points[i * corner_index_size] = starting_point
		new_points[i * corner_index_size + corner_index_size - 1] = ending_point
		# Quadratic Bezier curves are use because we have all three required points already. It isn't a perfect circle, but good enough.
		# sub_i is initialized with a value of 1 as a corner_smoothness of 1 has no between points.
		var sub_i := 1
		while sub_i < corner_smoothness:
			var t_value := sub_i / (corner_smoothness as float)
			new_points[i * corner_index_size + sub_i] = quadratic_bezier_interpolate(starting_point, points[i], ending_point, t_value)
			sub_i += 1
		
		# end, prep for next loop.
		last_point = current_point
		current_point = next_point

	return new_points

## Returns the point at the given [param t] on the Bézier curve with the given [param start], [param end], and single [param control] point.
static func quadratic_bezier_interpolate(start : Vector2, control : Vector2, end : Vector2, t : float) -> Vector2:
	return control + (t - 1) ** 2 * (start - control) + t ** 2 * (end - control)

# Todo: investigate performance of doing this.
# Todo: change method to instead create a new array instead.
## [b]Appends[/b] points, which are [param hole_scaler] of the original points, on [param points] to give it a hole for [member Polygon2D.polygon].
## [param close_shape] adds the first point to the end before adding the other points.
static func add_hole_to_points(points : PackedVector2Array, hole_scaler : float, close_shape : bool = true) -> void:
	if close_shape:
		points.append(points[0])

	var original_size := points.size()
	for i in original_size:
		points.append(points[original_size - i - 1] * hole_scaler)
