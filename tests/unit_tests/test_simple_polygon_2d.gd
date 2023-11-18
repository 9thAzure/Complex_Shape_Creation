extends GutTest

func test_init__filled__variables_assigned():
	var shape : SimplePolygon2D

	shape = autoqfree(SimplePolygon2D.new(4, 5.0, 1, Color.RED, Vector2.ONE))

	assert_eq(shape.vertices_count, 4)
	assert_eq(shape.size, 5.0)
	assert_eq(shape.offset_rotation, 1.0)
	assert_eq(shape.color, Color.RED)
	assert_eq(shape.offset_position, Vector2.ONE)
	shape.queue_free()

# var param1 := [[10.0, 0.0, Vector2.ZERO], [5.0, 0.0, Vector2.ZERO], [TAU, 0.0, Vector2.ZERO],
# 	[10.0, deg_to_rad(15), Vector2.ZERO], [10.0, -1.0, Vector2.ZERO],
# 	[10.0, 0.0, -Vector2.ONE], [10.0, 0.0, Vector2(100000, 100000)],
# 	[5.5, PI, Vector2.LEFT], [11.34, PI / 6, Vector2(-49234, 84032)]]
# func test_get_shape_vertices__various_circles__approx_32_equivalent(p = use_parameters(param1)):
# 	pass

# 	var circle := SimplePolygon2D.get_shape_vertices(1, p[0], p[1], p[2])

# 	var manual := SimplePolygon2D.get_shape_vertices(32, p[0], p[1], p[2])
# 	for i in 32:
# 		assert_true(circle[i].is_equal_approx(manual[i]))

var param2 := [[2], [5], [8], [32], [100]]
func test_get_shape_vertices__various_vertices_counts__matches_output_size(p = use_parameters(param2)):
	pass

	var shape = SimplePolygon2D.get_shape_vertices(p[0])

	assert_eq(shape.size(), p[0])

func test_get_shape_vertices__straight_line__not_vertical():
	pass

	var line = SimplePolygon2D.get_shape_vertices(2)

	assert_false(line[0].is_equal_approx(Vector2.DOWN))
