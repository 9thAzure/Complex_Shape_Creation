extends GutTest

var class_script := preload("res://addons/2d_regular_polygons/regular_collision_polygon_2d/regular_collision_polygon_2d.gd")

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

func test_enter_tree__shape_filled__regenerate_not_called():
    var shape = partial_double(class_script)
    stub(shape, "regenerate").to_do_nothing()
    shape.shape = RectangleShape2D.new()
    shape.queue_redraw = true

    shape._enter_tree()

    assert_not_called(shape, "regenerate")
    assert_false(shape.queue_redraw)

func test_queue_regenerate__shape_filled__shape_null():
    var shape = RegularCollisionPolygon2D.new()
    shape.shape = RectangleShape2D.new()

    shape.queue_regenerate()

    assert_null(shape.shape)
