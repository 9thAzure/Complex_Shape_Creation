extends GutTest

var class_script := preload("res://addons/2d_regular_polygons/regular_collision_polygon_2d/regular_collision_polygon_2d.gd")

func before_each():
	ignore_method_when_doubling(class_script, "_init")
	ignore_method_when_doubling(class_script, "widen_polyline")
	ignore_method_when_doubling(class_script, "widen_multiline")
	ignore_method_when_doubling(class_script, "_widen_polyline_result")
	ignore_method_when_doubling(class_script, "_widen_multiline_result")
	ignore_method_when_doubling(class_script, "convert_to_line_segments")

func test_init__filled_params__assigned_to_vars():
	var shape : RegularCollisionPolygon2D

	shape = autoqfree(RegularCollisionPolygon2D.new(5, 5.0, 1.0, 1.0, 1.0, 1.0, 1))

	assert_eq(shape.vertices_count, 5, "Property 'vertices_count'.")
	assert_eq(shape.size, 5.0, "Property 'size'.")
	assert_eq(shape.offset_rotation, 1.0, "Property 'offset_rotation'.")
	assert_eq(shape.width, 1.0, "Property 'width'.")
	assert_eq(shape.drawn_arc, 1.0, "Property 'drawn_arc'.")
	assert_eq(shape.corner_size, 1.0, "Property 'corner_size'.")
	assert_eq(shape.corner_smoothness, 1, "Property 'corner_smoothness'.")

func test_enter_tree__queue_blocked__regenerate_not_called_not_queued():
	var shape : RegularCollisionPolygon2D = partial_double(class_script).new() 
	stub(shape, "regenerate").to_do_nothing()
	shape.shape = RectangleShape2D.new()
	shape._queue_status = RegularCollisionPolygon2D._BLOCK_QUEUE

	shape._enter_tree()

	assert_not_called(shape, "regenerate")
	assert_eq(shape._queue_status, RegularCollisionPolygon2D._NOT_QUEUED, "Property '_queue_status' should be '_NOT_QUEUED' (0).")

func test_queue_regenerate__not_queued__is_queued():
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.shape = RectangleShape2D.new()

	shape.queue_regenerate()

	assert_eq(shape._queue_status, RegularCollisionPolygon2D._IS_QUEUED, "Property '_queue_status' should be '_IS_QUEUED' (1).")

func test_queue_regenerate__in_tree__delayed_shape_filled():
	var shape : RegularCollisionPolygon2D = partial_double(class_script).new()
	stub(shape, "_enter_tree").to_do_nothing()
	shape._queue_status = RegularCollisionPolygon2D._NOT_QUEUED
	add_child(shape)

	shape.queue_regenerate()

	assert_null(shape.shape, "Property 'shape'.")
	await wait_for_signal(get_tree().process_frame, 10)
	await wait_frames(2)
	assert_not_null(shape.shape, "Property 'shape'.")
	assert_eq(shape._queue_status, RegularCollisionPolygon2D._NOT_QUEUED, "Property '_queue_status' should be '_NOT_QUEUED' (0).")

func test_regenerate__vertices_count_2__shape_segment_shape():
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.vertices_count = 2

	shape.regenerate()

	assert_true(shape.shape is SegmentShape2D, "Property 'shape' should be type SegmentShape2D.")

func test_regenerate__line_with_width_offset_rotation_multiples_of_PI__shape_rectangle_taller_than_wide(p = use_parameters([0, PI, -PI, TAU])):
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.vertices_count = 2
	shape.width = 5
	shape.offset_rotation = p

	shape.regenerate()

	assert_true(shape.shape is RectangleShape2D, "Property 'shape' should be type RectangleShape2D.")
	if is_failing(): 
		return
	assert_gt(shape.shape.size.y, shape.shape.size.x, "Property 'shape' should be taller than wide")

func test_regenerate__line_with_width_offset_rotation_multiples_of_PI_plus_PI_over_2__shape_rectangle_wider_than_tall(p = use_parameters([PI / 2, -PI * 3 / 2, PI * 5 / 2])):
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.vertices_count = 2
	shape.width = 5
	shape.offset_rotation = p

	shape.regenerate()

	assert_true(shape.shape is RectangleShape2D, "Property 'shape' should be type RectangleShape2D.")
	if is_failing(): 
		return
	assert_gt(shape.shape.size.x, shape.shape.size.y, "Property 'shape' should be wider than tall")

func test_regnerate__line_with_width_offset_rotation_not_multiple_of_PI_over_2__shape_4_point_convex_shape(p = use_parameters([1, -3, 5])):
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.vertices_count = 2
	shape.width = 5
	shape.offset_rotation = p

	shape.regenerate()

	assert_true(shape.shape is ConvexPolygonShape2D, "Property 'shape' should be type ConvexPolygonShape2D")
	if is_failing(): 
		return
	assert_eq(shape.shape.points.size(), 4, "Property 'shape.points' should have 4 points")

func test_regnerate__line_with_width_uses_drawn_arc__shape_16_point_concave_shape(p = use_parameters([2, PI, -1])):
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.vertices_count = 2
	shape.width = 5
	shape.drawn_arc = p

	shape.regenerate()

	assert_true(shape.shape is ConcavePolygonShape2D, "Property 'shape' should be type ConcavePolygonShape2D")
	if is_failing(): 
		return
	assert_eq(shape.shape.segments.size(), 16, "Property 'shape.segments' should have 16 points")

func test_regenerate__line_with_width_uses_drawn_arc_and_corner_size__shape_76_point_concave_shape():
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.vertices_count = 2
	shape.width = 5
	shape.drawn_arc = PI * 3 / 2
	shape.corner_size = 5

	shape.regenerate()

	assert_true(shape.shape is ConcavePolygonShape2D, "Property 'shape' should be type ConcavePolygonShape2D")
	if is_failing(): 
		return
	assert_eq(shape.shape.segments.size(), 76, "Property 'shape.segments' should have 76 points")

func test_regenerate__line_with_width_drawn_arc_PI_uses_corner_size__shape_8_point_concave_shape():
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.vertices_count = 2
	shape.width = 5
	shape.drawn_arc = PI
	shape.corner_size = 5

	shape.regenerate()

	assert_true(shape.shape is ConcavePolygonShape2D, "Property 'shape' should be type ConcavePolygonShape2D")
	if is_failing(): 
		return
	assert_eq(shape.shape.segments.size(), 8, "Property 'shape.segments' should have 8 points")

func test_regenerate__uses_width__shape_concave_shape():
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.width = 5

	shape.regenerate()

	assert_true(shape.shape is ConcavePolygonShape2D, "Property 'shape' should be type ConcavePolygonShape2D.")

func test_regenerate__vertices_count_4__shape_rectangle_shape():
	var shape : RegularCollisionPolygon2D = autoqfree(RegularCollisionPolygon2D.new())
	shape.vertices_count = 4

	shape.regenerate()

	assert_true(shape.shape is RectangleShape2D, "Property 'shape' should be type RectangleShape2D.")
