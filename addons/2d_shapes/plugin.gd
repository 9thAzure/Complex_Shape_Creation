@tool
extends EditorPlugin

const regular_shape_2d_script : GDScript = preload("res://addons/2d_shapes/regular_shape_2d.gd")
# ! Replace with a preload("actual path") instead of null.
const regular_shape_2d_icon : Texture2D = null
const regular_shape_2d_name := "RegularShape2D"

func _enter_tree():
	add_custom_type(regular_shape_2d_name, "Node2D", regular_shape_2d_script, regular_shape_2d_icon)


func _exit_tree():
	remove_custom_type(regular_shape_2d_name)
