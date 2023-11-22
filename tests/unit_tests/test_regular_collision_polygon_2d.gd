extends GutTest

func test_init__filled_params__assigned_to_vars():
    var shape : RegularCollisionPolygon2D

    shape = RegularCollisionPolygon2D.new(5, 5.0, 1.0, 1.0, 1.0, 1.0, 1)

    assert_eq(shape.vertices_count, 5)
    assert_eq(shape.size, 5.0)
    assert_eq(shape.offset_rotation, 1.0)
    assert_eq(shape.width, 1.0)
    assert_eq(shape.drawn_arc, 1.0)
    assert_eq(shape.corner_size, 1.0)
    assert_eq(shape.corner_smoothness, 1)
