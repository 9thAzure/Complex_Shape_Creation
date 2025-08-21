extends Object
class_name BasicGeometry2D

## Holds methods for creating and modifying shapes.



# gets the point on a unit circle for the specified rotation.
static func _circle_point(rotation : float) -> Vector2:
	return Vector2(sin(rotation), -cos(rotation))

# finds the intersection between 2 points and their slopes. The value returned is not the point itself, but a scaler
# where the point of intersection is [c] point1 + return_value * slope1 [/c]
static func _find_intersection(point1 : Vector2, slope1 : Vector2, point2: Vector2, slope2: Vector2) -> float:
	var numerator := slope2.y * (point2.x - point1.x) - slope2.x * (point2.y - point1.y)
	var devisor := (slope1.x * slope2.y) - (slope1.y * slope2.x)
	assert(devisor != 0, "one or both slopes are 0, or are parallel")
	return numerator / devisor

## Creates and returns a [PackedVector2Array] describing the shape specified by the parameters.
## [br][br]
## [param vertices_count] determines the number of points on the base shape. If a value of [code]1[/code] is used,
## A value of [code]32[/code] is used instead.
## [param sizes] determines the length of each point from the center of the base shape, being repeatedly iterated through
## to get the length for each vertex.
## [param offset_transform] is the transform applied after creation.
## [param arc_start] and [param arc_end] determine the arc out of that base shape that is cut out and returned, in radians.
## [param add_central_point] determines whether a central point is added to the shape. It is automatically set to [code]false[/code]
## if the arc of the shape is a complete circle.
static func create_shape(vertices_count: int, sizes: PackedFloat64Array, offset_transform = Transform2D.IDENTITY,
	arc_start := 0.0, arc_end := TAU, add_central_point := true) -> PackedVector2Array:
	return add_shape([], 0, vertices_count, sizes, offset_transform, arc_start, arc_end, add_central_point)

## Creates and inserts the shape specified by the parameters into [param points] at [param start] index.
## [br][br]
## [param vertices_count] determines the number of points on the base shape. If a value of [code]1[/code] is used,
## A value of [code]32[/code] is used instead.
## [param sizes] determines the length of each point from the center of the base shape, being repeatedly iterated through
## to get the length for each vertex.
## [param offset_transform] is the transform applied after creation.
## [param arc_start] and [param arc_end] determine the arc out of that base shape that is cut out and returned, in radians.
## [param add_central_point] determines whether a central point is added to the shape. It is automatically set to [code]false[/code]
## if the arc of the shape is a complete circle.
static func add_shape(points : PackedVector2Array, start : int, vertices_count: int, sizes: PackedFloat64Array, offset_transform = Transform2D.IDENTITY,
	arc_start := 0.0, arc_end := TAU, add_central_point := true) -> PackedVector2Array:
	assert(vertices_count >= 1, "param 'vertices_count' must be 1 or greater.")
	assert(sizes.size() != 0, "param 'sizes' must have at least one element")
	assert(arc_end > arc_start, "param 'arc_end' must be larger than 'arc_start'")

	if vertices_count == 1:
		vertices_count = 32

	var arc_angle := TAU / vertices_count

	var is_full_arc := false
	# checks if it is approximately a multiple of TAU.
	if is_zero_approx(sin((arc_end - arc_start) * PI / TAU)):
		is_full_arc = true
		add_central_point = false

	var starting_vertex_index : int = floorf(arc_start / arc_angle)
	var ending_vertex_index : int = ceilf(arc_end / arc_angle)
	var true_vertices_count := ending_vertex_index - starting_vertex_index + (1 if not is_full_arc else 0)
	var size_increase := true_vertices_count + (1 if add_central_point else 0)
	var original_size := points.size()
	points.resize(points.size() + size_increase)
	for i in original_size - start:
		var index := original_size - i - 1
		points[index + size_increase] = points[index]

	for i in true_vertices_count:
		var index := i + starting_vertex_index
		points[start + i] = _circle_point(index * arc_angle) * sizes[index % sizes.size()]

	if not is_equal_approx(starting_vertex_index, arc_start / arc_angle):
		var slope1 := _circle_point(arc_start)
		var scaler := _find_intersection(Vector2.ZERO, slope1, points[start], points[start + 1] - points[start])
		points[start] = slope1 * scaler

	if not is_equal_approx(ending_vertex_index, arc_end / arc_angle) and not is_full_arc:
		var last_i := start + true_vertices_count - 1
		var slope1 := _circle_point(arc_end)
		var scaler := _find_intersection(Vector2.ZERO, slope1, points[last_i], points[last_i - 1] - points[last_i])
		points[last_i] = slope1 * scaler

	if add_central_point:
		points[start + size_increase - 1] = Vector2.ZERO

	for i in points.size():
		points[i] = offset_transform.basis_xform(points[i]) + offset_transform.get_origin()

	return points

## Modifies and returns [param shape], adding a duplicate ring of points
## at a distance that is [param length_proportion] percent of the original point's distance to [param shape_center].
## [br][br]
## if [param close_ring] is true, the first point is also appended to the end before adding the ring.
static func add_ring(shape: PackedVector2Array, length_proportion: float, shape_center := Vector2.ZERO, close_ring := true) -> PackedVector2Array:
	var original_size := shape.size() + (1 if close_ring else 0)

	shape.resize(original_size * 2)
	if close_ring:
		shape[original_size - 1] = shape[0]

	for i in original_size:
		shape[-i - 1] = shape[i].lerp(shape_center, length_proportion)

	return shape

## Modifies [param points] so that the shape it represents has rounded corners. The method uses quadratic Bézier curves for the corners.
## [br][br][param corner_size] determines how long each corner is, from the original point to at most half the side length.
## [param corner_detail] determines how many [b]lines[/b] are in each corner.
## [br][br][param start_index] & [param length] can be used to specify only part of the shape should be rounded.
## [param limit_ending_slopes] determines whether the first and last corner should be limited to half the side distance or not. No effect if the entire shape is being rounded.
## [param original_array_size], when used, indicates that the array has already been resized, so the method should add points into the empty space.
## This parameter specifies the part of the array that is currently used.
static func add_rounded_corners(points : PackedVector2Array, corner_size : float, corner_detail : int,
	start_index := 0, length := -1, limit_ending_slopes := true, original_array_size := 0) -> PackedVector2Array:
	# argument prep 
	var corner_size_squared := corner_size ** 2
	var resize_array := false
	if original_array_size <= 0:
		resize_array = true
		original_array_size = points.size()
	if length < 0:
		length = original_array_size - start_index
	if corner_detail == 0:
		corner_detail = 32 / points.size()
	var points_per_corner := corner_detail + 1
	
	if not limit_ending_slopes and length == original_array_size:
		limit_ending_slopes = true

	assert(points.size() >= 3, "param 'points' must have at least 3 points.")
	assert(corner_size >= 0, "param 'corner_size' must be 0 or greater.")
	assert(corner_detail >= 0, "param 'corner_detail' must be 0 or greater.")
	assert(start_index >= 0, "param 'start_index' must be 0 or greater.")
	assert(start_index + length <= original_array_size, "sum of param 'start_index' & param 'length' must not be greater than the original size of the array (param 'original_array_size', or if 0, size of param 'points').")
	assert(limit_ending_slopes || length != original_array_size, "param 'limit_ending_slopes' was set to false, but the entire shape is being rounded so there are no \"ending\" slopes.")

	# resizing and spacing
	var size_increase := length * (corner_detail + 1) - length
	if resize_array:
		points.resize(original_array_size + size_increase)
		for i in (original_array_size - start_index - length):
			points[-i - 1] = points[-i - 1 - size_increase]
	else:
		assert(original_array_size + size_increase <= points.size(), "The function is set to use the empty space in param 'points' but it is too small.")
		for i in (original_array_size - start_index - length):
			points[original_array_size - i - 1 + size_increase]= points[original_array_size - i - 1]

	for i in length:
		var index := length - i - 1
		points[start_index + index * points_per_corner] = points[index + start_index]

	# pre-loop prep and looping
	var current_point := points[start_index]
	var next_point : Vector2
	var point_after_final : Vector2
	var previous_point : Vector2
	if start_index == 0:
		if length == original_array_size:
			previous_point = points[original_array_size + size_increase - points_per_corner]
		else:
			previous_point = points[original_array_size + size_increase - 1]
	else:
		previous_point = points[start_index - 1]

	if start_index + length == original_array_size:
		point_after_final = points[0]
	else:
		point_after_final = points[start_index + length * points_per_corner - points.size()]
	
	for i in length:
		if i + 1 == length:
			next_point = point_after_final
		else:
			next_point = points[start_index + (i + 1) * points_per_corner]
		
		# creating corner
		var starting_slope := (current_point - previous_point)
		var ending_slope := (current_point - next_point)
		var starting_point : Vector2
		var ending_point : Vector2

		var slope_limit_value := 1 if not limit_ending_slopes and i == 0 else 2
		if starting_slope.length_squared() / (slope_limit_value * slope_limit_value) < corner_size_squared:
			starting_point = current_point - starting_slope / (slope_limit_value + 0.001)
		else:
			starting_point = current_point - starting_slope.normalized() * corner_size
		
		slope_limit_value = 1 if not limit_ending_slopes and i + 1 == length else 2
		if ending_slope.length_squared() / (slope_limit_value * slope_limit_value) < corner_size_squared:
			ending_point = current_point - ending_slope / (slope_limit_value + 0.001)
		else:
			ending_point = current_point - ending_slope.normalized() * corner_size

		points[start_index + i * points_per_corner] = starting_point
		points[start_index + i * points_per_corner + points_per_corner - 1] = ending_point
		# sub_i is initialized with a value of 1 as a corner_detail of 1 has no in-between points.
		var sub_i := 1
		while sub_i < corner_detail:
			var t_value := sub_i / (corner_detail as float)
			points[start_index + i * points_per_corner + sub_i] = _quadratic_bezier_interpolate(starting_point, current_point, ending_point, t_value)
			sub_i += 1
		
		# end, prep for next loop.
		previous_point = current_point
		current_point = next_point

	return points

static func _quadratic_bezier_interpolate(start : Vector2, control : Vector2, end : Vector2, t : float) -> Vector2:
	return control + (t - 1) ** 2 * (start - control) + t ** 2 * (end - control)
