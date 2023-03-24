@tool
extends EditorPlugin

const regular_polygon_2d_name := "RegularPolygon2D"
const complex_polygon_2d_name := "ComplexPolygon2D"

func _enable_plugin():
	add_custom_type(regular_polygon_2d_name, "Node2D", 
		preload("res://addons/2d_shapes/regular_polygon_2d.gd"), 
		preload("res://addons/2d_shapes/regular_shape_2d.svg")
	)
	add_custom_type(complex_polygon_2d_name, "Polygon2D",
		preload("res://addons/2d_shapes/complex_polygon_2d.gd"),
		preload("res://addons/2d_shapes/complex_shape_2d.svg"),
	)

func _disable_plugin():
	remove_custom_type(regular_polygon_2d_name)
	remove_custom_type(complex_polygon_2d_name)
