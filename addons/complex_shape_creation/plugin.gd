@tool
@static_unload
extends EditorPlugin
func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_MASK_LEFT:
			return
		
		if event.pressed:
			var viewport := EditorInterface.get_editor_viewport_2d()
			var transform := viewport.get_final_transform()
			var size := viewport.size
			var lower_bound := -transform.get_origin()
			lower_bound = Vector2(lower_bound.x / transform.get_scale().x, lower_bound.y / transform.get_scale().y)
			var upper_bound := lower_bound + Vector2(size.x / transform.get_scale().x, size.y / transform.get_scale().y)

			var mouse_position = viewport.get_mouse_position()
			if (lower_bound.x <= mouse_position.x and mouse_position.x <= upper_bound.x and
				lower_bound.y <= mouse_position.y and mouse_position.y <= upper_bound.y):
				pass
		else:
			pass

func _handles(object : Object) -> bool:
	var result = _temp(object)
	print("handles ", object, "? ", result)
	return result

func _temp(object) -> bool:
	# if object.get_class() == "MultiNodeEdit":
	# 	for node in EditorInterface.get_selection().get_selected_nodes():
	# 		if _is_handled_node(node):
	# 			return true
	# 	return false
	return _is_handled_node(object)

func _is_handled_node(object : Object) -> bool:
	return (
		object is SimplePolygon2D or
		object is RegularPolygon2D or
		object is RegularCollisionPolygon2D or
		object is StarPolygon2D
	)

# var edited_objects : Array[Node2D] = []
func _edit(object : Object) -> void:
	print("edit- ", object)
	var parent := _size_rotation_handler.get_parent()
	if object == null:
		if parent != null:
			parent.remove_child(_size_rotation_handler)
		return

	if not is_same(object, parent):
		if parent != null:
			parent.remove_child(_size_rotation_handler)
		_size_rotation_handler.request_ready()
		object.add_child(_size_rotation_handler, false, INTERNAL_MODE_FRONT)

	
	# if edited_objects.size() >= 1:
	# 	edited_objects[0] = object
	# 	edited_objects.resize(1)

	# edited_objects = [object] as Array[Node2D]

const BaseHandler := preload("res://addons/complex_shape_creation/gui_handlers/base_handler.gd")
const SizeRotationHandler := preload("res://addons/complex_shape_creation/gui_handlers/size_rotation_handler.gd")
var _size_rotation_handler : SizeRotationHandler
func _make_visible(visible) -> void:
	print(visible)
	if visible:
		_size_rotation_handler = SizeRotationHandler.new(self, get_undo_redo())
	else:
		_remove(_size_rotation_handler)

func _remove(node : Node) -> void:
	var parent := node.get_parent()
	if parent != null:
		parent.remove_child(node)
	node.queue_free()

func _forward_canvas_gui_input(event) -> bool:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_MASK_LEFT:
			return false
		
		if event.pressed:
			var viewport := EditorInterface.get_editor_viewport_2d()
			var transform := viewport.get_final_transform()
			var size := viewport.size
			var lower_bound := -transform.get_origin()
			lower_bound = Vector2(lower_bound.x / transform.get_scale().x, lower_bound.y / transform.get_scale().y)
			var upper_bound := lower_bound + Vector2(size.x / transform.get_scale().x, size.y / transform.get_scale().y)

			var mouse_position = viewport.get_mouse_position()
			if (lower_bound.x <= mouse_position.x and mouse_position.x <= upper_bound.x and
				lower_bound.y <= mouse_position.y and mouse_position.y <= upper_bound.y):
				return _size_rotation_handler.mouse_press(mouse_position)
		else:
			return _size_rotation_handler.mouse_release()
	
	return false
