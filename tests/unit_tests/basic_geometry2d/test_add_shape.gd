extends GutCollectionTest

func test_add_shape__sample_params__expected_output() -> void:
	var initial_shape : PackedVector2Array = [Vector2.ZERO, Vector2.ZERO]
	var start := 1
	var vertices_count := 4
	var sizes := PackedFloat64Array([1.0])
	var expected_shape := PackedVector2Array([Vector2.ZERO, Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT,Vector2.ZERO])

	var received_shape := BasicGeometry2D.add_shape(initial_shape, start, vertices_count, sizes)

	assert_same(received_shape, initial_shape)
	assert_almost_eq_deep(received_shape, expected_shape, Vector2.ONE * 0.00001)
