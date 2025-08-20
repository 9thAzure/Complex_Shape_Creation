@tool
extends EditorPlugin

const BaseHandler := preload("res://addons/basic_shape_creation/gui_handlers/base_handler.gd")
const SizeRotationHandler := preload("res://addons/basic_shape_creation/gui_handlers/size_rotation_handler.gd")
const ScaleSizeHandler := preload("res://addons/basic_shape_creation/gui_handlers/scale_size_handler.gd")

var _current_object : Node2D = null
var _handlers : Array[BaseHandler] = []
var _pressed_handler : BaseHandler = null
var _size_handler_count := 0
var _has_sent_not_found_button_warning := false

func _enable_plugin() -> void:
	var undoredo := get_undo_redo()
	undoredo.history_changed.connect(_on_version_change)
	undoredo.version_changed.connect(_on_version_change)

func _disable_plugin() -> void:
	remove_handlers()
	var undoredo := get_undo_redo()
	if undoredo.version_changed.is_connected(_on_version_change):
		undoredo.history_changed.disconnect(_on_version_change)
		undoredo.version_changed.disconnect(_on_version_change)

func _on_version_change() -> void:
	if _current_object == null:
		return

	if not _is_handled_node(_current_object):
		EditorInterface.edit_node(_current_object)
		return

	var _new_size_handler_count = _current_object.sizes.size()
	if _new_size_handler_count != _size_handler_count:
		_size_handler_count = _new_size_handler_count
		remove_handlers()
		create_handlers()

	for handler in _handlers:
		handler.version_change()
	update_overlays()

func _handles(object : Object) -> bool:
	return _is_handled_node(object)

func _is_handled_node(object : Object) -> bool:
	return (
		object is BasicPolygon2D or
		object is BasicCollisionPolygon2D
	) and object.get_class() != "EditorDebuggerRemoteObject"

func _edit(object : Object) -> void:
	update_overlays()
	if object == null:
		remove_handlers()
		_current_object = null
		return

	if not is_same(object, _current_object):
		remove_handlers()
		_current_object = object
		create_handlers()

	# just in case it get disconnected somehow, typically due to file edit while plugin is active.
	if not get_undo_redo().version_changed.is_connected(_on_version_change):
		get_undo_redo().version_changed.connect(_on_version_change)
		get_undo_redo().history_changed.connect(_on_version_change)

func create_handlers() -> void:
	assert(_current_object != null)

	_size_handler_count = _current_object.sizes.size()
	for i in _size_handler_count:
		_handlers.append(SizeRotationHandler.new(self, get_undo_redo(), i))
	if _size_handler_count > 1:
		_handlers.append(ScaleSizeHandler.new(self, get_undo_redo()))

	for handler in _handlers:
		handler.maintain_position()

func remove_handlers() -> void:
	_handlers.clear()

func _forward_canvas_gui_input(event) -> bool:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_MASK_LEFT:
			return false
		
		if event.pressed:
			if not _select_mode_button_selected():
				return false

			for handler in _handlers:
				var intercepts := handler.mouse_press(event.position)
				if intercepts:
					_pressed_handler = handler
					update_overlays()
					return true
			return false
		else:
			if _pressed_handler == null:
				return false
			var result := _pressed_handler.mouse_release()
			_pressed_handler = null
			update_overlays()
			return result

	elif event is InputEventMouseMotion:
		if _pressed_handler == null:
			return false

		_pressed_handler.mouse_dragged(event.position)
		for handler in _handlers:
			if handler != _pressed_handler:
				handler.maintain_position()
		update_overlays()


	return false

func to_canvas(points : PackedVector2Array)	-> PackedVector2Array:
	points = points.duplicate()
	var transform := _current_object.get_viewport_transform() * _current_object.get_global_transform()
	for i in points.size():
		points[i] = transform.basis_xform(points[i]) + transform.origin
	return points

func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	var instance : BasicPolygon2D = _current_object if _current_object is BasicPolygon2D else _current_object._basic_polygon_instance
	if instance._queue_status == BasicPolygon2D._QUEUE_REGENERATE:
		instance.regenerate()

	if _current_object.get_created_shape().size() > 0 and _current_object.get_created_shape_type() == BasicPolygon2D.ShapeType.POLYGON:
		var outline_color := Color(0.925, 0.38, 0.216)
		var line_width := 3.5
		match _current_object.get_created_shape_type():
			BasicPolygon2D.ShapeType.POLYGON:
				var shape : PackedVector2Array = to_canvas(_current_object.get_created_shape())
				viewport_control.draw_polyline(shape, outline_color, line_width)
				viewport_control.draw_line(shape[-1], shape[0], outline_color, line_width)

			BasicPolygon2D.ShapeType.POLYLINE:
				viewport_control.draw_polyline(to_canvas(_current_object.get_created_shape()), outline_color, line_width)

			BasicPolygon2D.ShapeType.MULTILINE:
				viewport_control.draw_multiline(to_canvas(_current_object.get_created_shape()), outline_color, line_width)

	for handler in _handlers:
		const margin := 1.0

		var shape := BasicGeometry2D.create_shape(5, [handler.size], Transform2D(0, handler.to_global(handler.position)))
		var color := Color.LIME_GREEN if _pressed_handler == handler else Color.WHITE
		viewport_control.draw_colored_polygon(shape, color)
		viewport_control.draw_polyline(shape, Color.BLACK, margin, true)
		viewport_control.draw_line(shape[-1], shape[0], Color.BLACK, margin, true)

var _select_mode_button : Button = null
func _select_mode_button_selected() -> bool:
	if _is_select_mode_button_invalid(_select_mode_button):
		_get_select_mode_button()
		if _is_select_mode_button_invalid(_select_mode_button):
			return true

	return _select_mode_button.button_pressed

func _is_select_mode_button_invalid(button : Button) -> bool:
	return button == null or not is_instance_valid(button) or not button.toggle_mode or button.icon == null

func _get_select_mode_button() -> void:
	var main_screen := EditorInterface.get_editor_main_screen()

	var found_node : Node = main_screen.get_node_or_null("@CanvasItemEditor@9465/@MarginContainer@9280/@HFlowContainer@9281/@HBoxContainer@9282/@Button@9329")
	if found_node != null and found_node is Button:
		_select_mode_button = found_node
		return

	found_node = main_screen
	for i in 5:
		if found_node == null:
			break
		found_node = found_node.get_child(0)

	if found_node != null and found_node is Button:
		_select_mode_button = found_node
		return

	if not _has_sent_not_found_button_warning:
		push_warning("(Simplified Shape Creation plugin) - Unable to find the select mode button. Handlers for the nodes provided by this plugin will always be selectable, even if other modes are selected")
		_has_sent_not_found_button_warning = true
