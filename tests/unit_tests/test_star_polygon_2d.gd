extends GutTest

func test_init__params_filled__assigned_to_vars():
    var star : StarPolygon2D

    star = StarPolygon2D.new(3, 5.0, 1.0, 1.0, Color.RED, Vector2.ONE, 1.0, 1.0, 1.0, 1)

    assert_eq(star.point_count, 3)
    assert_eq(star.size, 5.0)
    assert_eq(star.inner_size, 1.0)
    assert_eq(star.offset_rotation, 1.0)
    assert_eq(star.color, Color.RED)
    assert_eq(star.offset, Vector2.ONE)
    assert_eq(star.width, 1.0)
    assert_eq(star.drawn_arc, 1.0)
    assert_eq(star.corner_size, 1.0)
    assert_eq(star.corner_smoothness, 1)
