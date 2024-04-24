class_name RegularGeometry2D

## Holds methods for creating and modifying shapes.

static func add_rounded_corners(points : PackedVector2Array, corner_size : float, corner_smoothness : int,
	start_index := 0, length := -1, original_array_size := 0) -> void:
	# argument prep 
	var corner_size_squared := corner_size ** 2
	var points_per_corner := corner_smoothness + 1
	var resize_array := false
	if original_array_size <= 0:
		resize_array = true
		original_array_size = points.size()
	if length < 0:
		length = original_array_size - start_index
	if corner_smoothness == 0:
		corner_smoothness = 32 / points.size()
	
	assert(points.size() >= 3, "param 'points' must have at least 3 points.")
	assert(corner_size >= 0, "param 'corner_size' must be 0 or greater.")
	assert(corner_smoothness >= 0, "param 'corner_smoothness' must be 0 or greater.")
	assert(start_index >= 0, "param 'start_index' must be 0 or greater.")
	assert(start_index + length <= original_array_size, "sum of param 'start_index' & param 'length' must not be greater than the original size of the array (param 'original_array_size', or if 0, size of param 'points').")

	# resizing and spacing
	var size_increase := SizeIncrease.add_rounded_corners(length, corner_smoothness)
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
	if start_index == 0 and length == original_array_size:
		point_after_final = points[start_index]
		previous_point = points[start_index - points_per_corner]
	else:
		point_after_final = points[start_index + length * points_per_corner - (original_array_size + size_increase)]
		previous_point = points[start_index - 1]
	
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
		if starting_slope.length_squared() / 4 < corner_size_squared:
			starting_point = current_point - starting_slope / 2.001
		else:
			starting_point = current_point - starting_slope.normalized() * corner_size
		
		if ending_slope.length_squared() / 4 < corner_size_squared:
			ending_point = current_point - ending_slope / 2.001
		else:
			ending_point = current_point - ending_slope.normalized() * corner_size

		points[start_index + i * points_per_corner] = starting_point
		points[start_index + i * points_per_corner + points_per_corner - 1] = ending_point
		# sub_i is initialized with a value of 1 as a corner_smoothness of 1 has no in-between points.
		var sub_i := 1
		while sub_i < corner_smoothness:
			var t_value := sub_i / (corner_smoothness as float)
			points[start_index + i * points_per_corner + sub_i] = _quadratic_bezier_interpolate(starting_point, current_point, ending_point, t_value)
			sub_i += 1
		
		# end, prep for next loop.
		previous_point = current_point
		current_point = next_point

static func _quadratic_bezier_interpolate(start : Vector2, control : Vector2, end : Vector2, t : float) -> Vector2:
	return control + (t - 1) ** 2 * (start - control) + t ** 2 * (end - control)

## sub class that designates how much each method expands the array.
class SizeIncrease:
	static func add_rounded_corners(length : int, corner_smoothness : int) -> int:
		assert(length >= 0, "param 'length' must be positive.")
		assert(corner_smoothness > 0, "param 'corner_smoothness' must be positive.")
		return length * (corner_smoothness + 1) - length