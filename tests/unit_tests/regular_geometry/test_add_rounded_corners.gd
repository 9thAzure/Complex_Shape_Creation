extends GutTest

func assert_almost_eq_deep(c1, c2, error_interval):
	if c1.size() != c2.size():
		_fail("collections are different sizes (%s | %s)" % [c1, c2])
		return
	
	var has_failed := false
	for i in c2.size():
		if not _is_almost_eq(c1[i], c2[i], error_interval):
			_fail("Elements at index [%s] is different (%s != %s)" % [i, c1[i], c2[i]])
			has_failed = true

	if not has_failed:
		_pass("%s approximately matches with %s with the error interval '%s'" % [c1, c2, error_interval])

var various_shapes_with_corner_smoothness := [
	[1, [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]],
	[3, [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]],
	[3, [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2(0.75, 1), Vector2(0.75, 1)]],
]
func test_add_rounded_corners__various_shapes_with_0_corner_size__expected_shape(p=use_parameters(various_shapes_with_corner_smoothness)):
	var corner_smoothness : int = p[0]
	var shape : PackedVector2Array = p[1]
	var original := PackedVector2Array(shape)
	var expected_size := shape.size() * (corner_smoothness + 1)

	RegularGeometry2D.add_rounded_corners(shape, 0, corner_smoothness)

	assert_eq(shape.size(), expected_size, "Size of modified array should be %s but was %s" % [expected_size, shape.size()])
	for i in original.size():
		for i2 in (corner_smoothness + 1):
			assert_almost_eq(shape[i * (corner_smoothness + 1) + i2], original[i], Vector2.ONE * 0.001)

func test_add_rounded_corners__oversized_corner_size__corner_size_limited():
	const sample_corner_smoothness := 2
	const oversized_corner_size := 32.432
	var shape : PackedVector2Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	const expected_shape : PackedVector2Array = [
		Vector2.RIGHT, Vector2(0.75, 0.75), Vector2.DOWN,
		Vector2.DOWN, Vector2(-0.75, 0.75), Vector2.LEFT,
		Vector2.LEFT, Vector2(-0.75, -0.75), Vector2.UP,
		Vector2.UP, Vector2(0.75, -0.75), Vector2.RIGHT
	]

	RegularGeometry2D.add_rounded_corners(shape, oversized_corner_size, sample_corner_smoothness)

	assert_almost_eq_deep(shape, expected_shape, Vector2.ONE * 0.01)

var shapes_with_various_starts_and_lengths := [
	[0, 4, [Vector2.RIGHT, Vector2(0.75, 0.75), Vector2.DOWN, Vector2.DOWN, Vector2(-0.75, 0.75), Vector2.LEFT, Vector2.LEFT, Vector2(-0.75, -0.75), Vector2.UP, Vector2.UP, Vector2(0.75, -0.75), Vector2.RIGHT]],
	[0, 1, [Vector2.RIGHT, Vector2(0.75, 0.75), Vector2.DOWN, Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]],
	[1, 2, [Vector2(1, 1), Vector2.DOWN, Vector2(-0.75, 0.75), Vector2.LEFT, Vector2.LEFT, Vector2(-0.75, -0.75), Vector2.UP, Vector2(1, -1)]],
	[2, -1, [Vector2(1, 1), Vector2(-1, 1), Vector2.LEFT, Vector2(-0.75, -0.75), Vector2.UP, Vector2.UP, Vector2(0.75, -0.75), Vector2.RIGHT]]
]
func test_add_rounded_corners___custom_start_and_length__expected_shape(p=use_parameters(shapes_with_various_starts_and_lengths)):
	const sample_corner_smoothness := 2
	const sample_corner_size := 1
	var sample_shape : PackedVector2Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	var start_index : int = p[0]
	var length : int = p[1]
	var expected_shape : PackedVector2Array = p[2]

	RegularGeometry2D.add_rounded_corners(sample_shape, sample_corner_size, sample_corner_smoothness, start_index, length)

	assert_almost_eq_deep(sample_shape, expected_shape, Vector2.ONE * 0.01)

func test_add_rounded_corners__full_shape_with_resizing__expected_shape():
	const sample_corner_smoothness := 2
	const sample_corner_size := 1
	const expected_shape : PackedVector2Array = [
		Vector2.RIGHT, Vector2(0.75, 0.75), Vector2.DOWN,
		Vector2.DOWN, Vector2(-0.75, 0.75), Vector2.LEFT,
		Vector2.LEFT, Vector2(-0.75, -0.75), Vector2.UP,
		Vector2.UP, Vector2(0.75, -0.75), Vector2.RIGHT
	]
	var sample_shape : PackedVector2Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	sample_shape.resize(expected_shape.size())

	RegularGeometry2D.add_rounded_corners(sample_shape, sample_corner_size, sample_corner_smoothness, 0, -1, true, 4)

	assert_almost_eq_deep(sample_shape, expected_shape, Vector2.ONE * 0.01)

func test_add_rounded_corners__partial_shape_with_resizing__expected_shape(p=use_parameters(shapes_with_various_starts_and_lengths)):
	const sample_corner_smoothness := 2
	const sample_corner_size := 1
	var sample_shape : PackedVector2Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	var start_index : int = p[0]
	var length : int = p[1]
	var expected_shape : PackedVector2Array = p[2]
	sample_shape.resize(expected_shape.size())

	RegularGeometry2D.add_rounded_corners(sample_shape, sample_corner_size, sample_corner_smoothness, start_index, length, true, 4)

	assert_almost_eq_deep(sample_shape, expected_shape, Vector2.ONE * 0.01)

func test_add_rounded_corners__partial_shape_with_resizing_and_extra_empties_expected_shape(p=use_parameters(shapes_with_various_starts_and_lengths)):
	const extra_empty_spaces_amount := 5
	const sample_corner_smoothness := 2
	const sample_corner_size := 1
	var sample_shape : PackedVector2Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	var start_index : int = p[0]
	var length : int = p[1]
	var expected_shape : PackedVector2Array = p[2]
	expected_shape.resize(expected_shape.size() + extra_empty_spaces_amount)
	sample_shape.resize(expected_shape.size())

	RegularGeometry2D.add_rounded_corners(sample_shape, sample_corner_size, sample_corner_smoothness, start_index, length, true, 4)

	assert_almost_eq_deep(sample_shape, expected_shape, Vector2.ONE * 0.01)

func test_add_rounded_corners__non_limited_ending_slopes__expected_result():
	const oversized_corner_size := 10
	const sample_corner_smoothness := 1
	const sample_start_index := 2
	const sample_length := 1
	var sample_shape : PackedVector2Array = [Vector2(1, 1), Vector2(-1, 1), Vector2.UP]
	var expected_shape : PackedVector2Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, 1), Vector2(1, 1)]

	RegularGeometry2D.add_rounded_corners(sample_shape, oversized_corner_size, sample_corner_smoothness, sample_start_index, sample_length, false)

	assert_almost_eq_deep(sample_shape, expected_shape, Vector2.ONE * 0.01)
