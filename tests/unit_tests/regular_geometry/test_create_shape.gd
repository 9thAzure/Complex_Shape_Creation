extends GutCollectionTest

func test_create_shape__various_inputs__expected_outputs(p=use_parameters([
	[5, [10], 0, Vector2.ZERO, 0, TAU, false, to_vector2s([0, -10, 9.51057, -3.09017, 5.87785, 8.09017, -5.87785, 8.09017, -9.51057, -3.09017])],
	[4, [1], PI / 2, Vector2.RIGHT, 0, TAU, false, [Vector2(2, 0), Vector2(1, 1), Vector2(0, 0), Vector2(1, -1)]],
	[4, [1], 0, Vector2.ZERO, PI / 2, 3 * PI / 2, false, [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]],
	[4, [1], 0, Vector2.RIGHT, -PI / 4, PI / 4, true, [Vector2(-1,-1) * 0.5 + Vector2.RIGHT, Vector2(1, -1), Vector2(1, -1) * 0.5 + Vector2.RIGHT, Vector2.RIGHT]],
	[4, [2, 1], 0, Vector2.ZERO, PI / 4, PI * 7 / 4, true, [Vector2(0.66667, -0.6667), Vector2.RIGHT, Vector2.DOWN * 2, Vector2.LEFT, Vector2(-0.66667, -0.6667), Vector2.ZERO]],
])) -> void:

	var vertices_count: int = p[0]
	var sizes: PackedFloat64Array = p[1]
	var offset_rotation : float = p[2]
	var offset_position : Vector2 = p[3]
	var arc_start : float = p[4]
	var arc_end : float = p[5]
	var add_central_point : bool = p[6]
	var expected_shape : PackedVector2Array = p[7]

	var actual_shape := SimpleGeometry2d.create_shape(vertices_count, sizes, offset_rotation, offset_position, arc_start, arc_end, add_central_point)

	assert_almost_eq_deep(actual_shape, expected_shape, Vector2.ONE * 0.01)
