extends GutCollectionTest

func test_init__filled__variables_assigned():
	var shape : SimplePolygon2D

	shape = autoqfree(SimplePolygon2D.new(4, 5.0, 1, Color.RED, Vector2.ONE))

	assert_eq(shape.vertices_count, 4, "Property 'vertices_count'.")
	assert_eq(shape.size, 5.0, "Property 'size'.")
	assert_eq(shape.offset_rotation, 1.0, "Property 'offset_rotation'.")
	assert_eq(shape.color, Color.RED, "Property 'color'.")
	assert_eq(shape.offset_position, Vector2.ONE, "Property 'offset_position'.")
	shape.queue_free()

var param2 := [[2], [5], [8], [32], [100]]
func test_get_shape_vertices__various_vertices_counts__matches_output_size(p = use_parameters(param2)):
	var shape : PackedVector2Array

	shape = SimplePolygon2D.get_shape_vertices(p[0])

	assert_eq(shape.size(), p[0], "Size of returned array.")

func test_get_shape_vertices__straight_line__not_vertical():
	var line : PackedVector2Array

	line = SimplePolygon2D.get_shape_vertices(2)

	assert_almost_ne(line[0], Vector2.DOWN, Vector2.ONE * 0.01, "First element of the returned array.")
