extends GutTest

var class_script := preload("res://addons/2d_regular_polygons/star_polygon_2d/star_polygon_2d.gd")
var sample_polygon := PackedVector2Array([Vector2.ONE, Vector2.RIGHT, Vector2.LEFT])

func before_each():
	ignore_method_when_doubling(class_script, "_init")
	ignore_method_when_doubling(class_script, "get_star_vertices")
	ignore_method_when_doubling(class_script, "_get_vertices")

func test_init__params_filled__assigned_to_vars():
	var star : StarPolygon2D

	star = autoqfree(StarPolygon2D.new(3, 5.0, 1.0, 1.0, Color.RED, Vector2.ONE, 1.0, 1.0, 1.0, 1))

	assert_eq(star.point_count, 3, "Property 'point_count'.")
	assert_eq(star.size, 5.0, "Property 'size'.")
	assert_eq(star.inner_size, 1.0, "Property 'inner_size'.")
	assert_eq(star.offset_rotation, 1.0, "Property 'offset_rotation'.")
	assert_eq(star.color, Color.RED, "Property 'color'.")
	assert_eq(star.offset, Vector2.ONE, "Property 'offset'.")
	assert_eq(star.width, 1.0, "Property 'width'.")
	assert_eq(star.drawn_arc, 1.0, "Property 'drawn_arc'.")
	assert_eq(star.corner_size, 1.0, "Property 'corner_size'.")
	assert_eq(star.corner_smoothness, 1, "Property 'corner_smoothness'.")

func test_enter_tree__polygon_filled__regenerate_not_called():
	var shape : StarPolygon2D = partial_double(class_script).new()
	stub(shape, "regenerate_polygon").to_do_nothing()
	shape.polygon = sample_polygon
	shape._is_queued = true

	shape._enter_tree()

	assert_not_called(shape, "regenerate_polygon") # does not accept a custom message.
	assert_false(shape._is_queued, "Variable '_is_queued' should be false.")

func test_pre_redraw__polygon_filled_outside_tree__polygon_empty():
	var star : StarPolygon2D = partial_double(class_script).new()
	stub(star, "uses_polygon_member").to_return(true)
	star.polygon = sample_polygon
	star._is_queued = false

	star._pre_redraw()

	assert_true(star.polygon.is_empty(), "Variable 'polygon' should be an empty array.")

func test_queue_regenerate__in_tree__delayed_shape_filled():
	var star : StarPolygon2D = partial_double(class_script).new()
	star.width = 10
	star._is_queued = false
	stub(star, "_enter_tree").to_do_nothing()
	add_child(star)

	star._pre_redraw()

	assert_true(star.polygon.is_empty(), "Variable 'polygon' should still be an empty array.")
	await wait_for_signal(get_tree().process_frame, 10)
	await wait_frames(2)
	assert_false(star.polygon.is_empty(), "Variable 'polygon' should be a filled array at this point.")

func test_get_star_vertices__drawn_arc_PI__no_central_point(p = use_parameters([[PI], [-PI]])):
	var star : PackedVector2Array

	star = StarPolygon2D.get_star_vertices(5, 10, 5, 0, Vector2.ZERO, p[0])

	assert_almost_ne(star[-1], Vector2.ZERO, Vector2.ONE * 0.01, "The last point of the returned array.")
	assert_eq(star.size(), 6, "Size of the returned array.")

func test_get_star_vertices__add_central_point_false__expected_size_and_not_ZERO():
	var star : PackedVector2Array

	star = StarPolygon2D.get_star_vertices(5, 10, 5, 0, Vector2.ZERO, PI * 3 / 2, false)

	assert_almost_ne(star[-1], Vector2.ZERO, Vector2.ONE * 0.01, "The last point in the returned array.")
	assert_eq(star.size(), 9, "Size of the returned array")
