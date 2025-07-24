extends GutCollectionTest

func test_add_ring__various_inputs__expected_outputs(p=use_parameters([
	[[Vector2.UP], 0.5, Vector2.DOWN, false, [Vector2.UP, Vector2.ZERO]],
	[[Vector2.UP * 5, Vector2.UP * 3, Vector2.UP], 0.5, Vector2.DOWN, true, [Vector2.UP * 5, Vector2.UP * 3, Vector2.UP, Vector2.UP * 5, Vector2.UP * 2, Vector2.ZERO, Vector2.UP * 1, Vector2.UP * 2]]
])) -> void:
	var shape : PackedVector2Array = p[0]
	var length_proportion: float = p[1]
	var shape_center : Vector2 = p[2]
	var close_ring : bool = p[3]
	var expected_shape : PackedVector2Array = p[4]

	var actual_shape := BasicGeometry2D.add_ring(shape, length_proportion, shape_center, close_ring)

	assert_almost_eq_deep(actual_shape, expected_shape, Vector2.ONE * 0.001)
