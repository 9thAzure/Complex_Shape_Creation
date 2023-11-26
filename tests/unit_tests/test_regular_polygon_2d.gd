extends GutTest

var class_script := preload("res://addons/2d_regular_polygons/regular_polygon_2d/regular_polygon_2d.gd")

func before_each():
	# Gut cannot handle static methods when doubling.
	ignore_method_when_doubling(class_script, "get_shape_vertices")
	ignore_method_when_doubling(class_script, "_get_vertices")
	ignore_method_when_doubling(class_script, "_find_intersection")
	ignore_method_when_doubling(class_script, "add_rounded_corners")
	ignore_method_when_doubling(class_script, "quadratic_bezier_interpolate")
	ignore_method_when_doubling(class_script, "add_hole_to_points")
	ignore_method_when_doubling(class_script, "_add_rounded_corners_result")
	ignore_method_when_doubling(class_script, "_add_hole_to_points_result")

func test_init__filled__variables_assigned():
	var shape : RegularPolygon2D

	shape = autoqfree(RegularPolygon2D.new(5, 5.0, 1.0, Color.RED, Vector2.ONE, 0.0, 2.0, 1.0, 1))

	assert_eq(shape.vertices_count, 5)
	assert_eq(shape.size, 5.0)
	assert_eq(shape.offset_rotation, 1.0)
	assert_eq(shape.color, Color.RED)
	assert_eq(shape.offset, Vector2.ONE)
	assert_eq(shape.width, 0.0)
	assert_eq(shape.drawn_arc, 2.0)
	assert_eq(shape.corner_size, 1.0)
	assert_eq(shape.corner_smoothness, 1)

func test_enter_tree__regenerate_requested_with_polygon_not_empty__polygon_not_regenerated():
	var shape = partial_double(class_script)
	stub(shape, "uses_polygon_member").to_return(true)
	stub(shape, "regenerate_polygon").to_do_nothing()
	shape._is_queued = true
	shape.polygon = shape.polygon.resize(10)

	shape._enter_tree()

	assert_not_called(shape, "regenerate_polygon")

func test_get_shape_vertices__drawn_arc_PI__no_central_point(p = use_parameters([[PI], [-PI]])):
	var shape : PackedVector2Array

	shape = RegularPolygon2D.get_shape_vertices(4, 10, 0, Vector2.ZERO, p[0])

	assert_almost_ne(shape[-1], Vector2.ZERO, Vector2.ONE * 0.01)
	assert_eq(shape.size(), 4, "size of array should be 4.")

func test_get_shape_vertices__false_central_point_when_drawn_arc_is_TAU_or_PI__no_difference(p = [[TAU], [PI], [-PI]]):
	var shape_control : PackedVector2Array
	var shape_test : PackedVector2Array

	shape_control = RegularPolygon2D.get_shape_vertices(4, 1, 0, Vector2.ZERO, p[0], true)
	shape_test = RegularPolygon2D.get_shape_vertices(4, 1, 0, Vector2.ZERO, p[0], false)

	for i in 4:
		if not shape_control[i].is_equal_approx(shape_test[i]):
			fail_test("difference between %s and %s at index %s" % [shape_control[i], shape_test[i], i])
	pass_test("control and test match")

func test_get_shape_vertices__false_central_point__last_point_not_ZERO():
	var shape : PackedVector2Array

	shape = RegularPolygon2D.get_shape_vertices(4, 1, 0, Vector2.ZERO, 1, false)

	assert_false(shape[-1].is_equal_approx(Vector2.ZERO), "%s should not equal Vector2.ZERO (0, 0)" % shape[-1])

func test_add_rounded_corners__various_corner_smoothness__array_size_increases_by_that_percentage(p = use_parameters([[1], [2], [3], [10]])):
	var shape := SimplePolygon2D.get_shape_vertices(3)
	var previous_size := shape.size()
	
	RegularPolygon2D.add_rounded_corners(shape, 1, p[0])
	var new_size := shape.size()

	assert_eq(new_size, previous_size + previous_size * p[0])

func test_add_rounded_corners__very_small_corner_size__approximately_equal_vectors():
	var shape := SimplePolygon2D.get_shape_vertices(3)
	
	RegularPolygon2D.add_rounded_corners(shape, 0.01, 2)

	for i in 3:
		var index := i * 3
		assert_almost_eq(shape[index + 1], shape[index], Vector2.ONE * 0.1)
		assert_almost_eq(shape[index + 2], shape[index], Vector2.ONE * 0.1)

func test_add_hole_to_points__do_not_close_shape__array_size_doubles():
	var shape := PackedVector2Array([Vector2.ZERO, Vector2.ONE, Vector2.RIGHT])
	var previous_size := shape.size()

	RegularPolygon2D.add_hole_to_points(shape, 1, false)
	var new_size := shape.size()

	assert_eq(new_size, 2 * previous_size)
	
func test_add_hole_to_points__do_close_shape__array_size_doubles_plus_2():
	var shape := PackedVector2Array([Vector2.ZERO, Vector2.ONE, Vector2.RIGHT])
	var previous_size := shape.size()

	RegularPolygon2D.add_hole_to_points(shape, 1, true)
	var new_size := shape.size()

	assert_eq(new_size, 2 * previous_size + 2)

# more so integration tests. Move them there when created.
# func test_regenerate_polygon__create_rounded_closed_holed_shape__properly_closed():
# 	var shape := RegularPolygon2D.new()
# 	shape.vertices_count = 4
# 	shape.width = 5

# 	shape.regenerate_polygon()

# 	# to properly close a holed shape, 2 points must be added: the first points of the outer and inner ring.
# 	assert_eq(shape.polygon.size(), 10)

# func test_regenerate_polygon__create_rounded_open_holed_shape__left_open():
# 	var shape := RegularPolygon2D.new()
# 	shape.vertices_count = 4
# 	shape.width = 5
# 	shape.drawn_arc -= 0.1

# 	shape.regenerate_polygon()

# 	# 2 points are added because of drawn_arc. 2 additional points should not be added, as the shape is not closed.
# 	assert_eq(shape.polygon.size(), 10)
