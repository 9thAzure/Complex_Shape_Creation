@tool
@static_unload
extends Node2D 

static var _select_button_query := SelectModeQuery.new()
var _shift_clamps : Array[Callable] = [clamp_straight_line, clamp_circle_radius]

var _parent : Node2D
var _origin := Vector2.ZERO
var size := 1.0

var _select_button_enabled := true
var _is_echo := false
var _being_dragged := false
var _old_position := Vector2.ZERO


func _init(parent : Node2D, handler_size := 1.0) -> void:
	_parent = parent
	size = handler_size
	if parent == null:
		printerr("%s initialized without parent" % self)
	else:
		print("proper initialization")

func _ready():
	assert(Engine.is_editor_hint())
	_parent.draw.connect(_on_parent_draw)
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)
	var button := _select_button_query.get_button()
	if SelectModeQuery.valid_button_instance(button):
		button.toggled.connect(_on_select_toggled)

func _on_parent_draw() -> void:
	_origin = _parent.offset
	_from_parent_properties()

func _from_parent_properties() -> void:
	printerr("'_from_parent_properties' is abstract")

func _update_properties() -> void:
	printerr("'_update_properties' is abstract")

func _on_selection_changed():
	if not is_inside_tree():
		set_process(false)
		visible = false
		return

	if _parent == null:
		var parent := get_parent()
		if parent == null or not parent is Node2D:
			printerr("%s without parent" % self)
			return
		printerr("initialized without parent, setting to tree parent: %s" % parent)
		_parent = parent
	
	var nodes := EditorInterface.get_selection().get_selected_nodes()
	if _parent in nodes:
		set_process(_select_button_enabled)
		visible = true 
	else:
		maintain_shape()
		if not _being_dragged:
			set_process(false)
			visible = false
			return

		EditorInterface.edit_node(_parent)

func _on_select_toggled(toggled : bool) -> void:
	_select_button_enabled = toggled
	if not visible:
		return
	
	set_process(toggled)

func _draw() -> void:
	const margin := 2
	var box := StyleBoxFlat.new()
	box.bg_color = Color.WHITE
	box.border_width_bottom = margin
	box.border_width_top = margin
	box.border_width_left = margin
	box.border_width_right = margin
	box.border_color = Color.BLACK

	box.draw(get_canvas_item(), Rect2(-5 * size, -5 * size, 10 * size, 10 * size))

func _process(_delta):
	if is_inside_tree():
		maintain_shape()
	

func maintain_shape():
	var editor_scale := get_viewport_transform().get_scale().x
	var cache_global_position = global_position

	var mouse_position := get_global_mouse_position()
	var mouse_pressed := Input.is_mouse_button_pressed(1)
	if mouse_pressed:
		if not _is_echo:
			_is_echo = true
			if _manhattan_distance(mouse_position - cache_global_position) <= 7 * size / editor_scale:
				_old_position = position
				_being_dragged = true
				if _old_position == Vector2.ZERO:
					_old_position = Vector2.RIGHT
		if _being_dragged:
			cache_global_position = mouse_position
	else:
		_is_echo = false
		_being_dragged = false
	
	global_transform = Transform2D(PI / 4, Vector2.ONE / editor_scale, 0, cache_global_position)
	if _being_dragged and Input.is_key_pressed(KEY_SHIFT):
		_clamp_position()
	if _being_dragged:
		_update_properties()

func _clamp_position() -> void:
	if _shift_clamps.size() == 0:
		return
	
	var best_position := position
	var best_distance := INF
	for i in _shift_clamps.size():
		# positions[i] = _shift_clamps[i].call()
		var point = _shift_clamps[i].call()
		if typeof(point) != TYPE_VECTOR2:
			printerr("method %s did not returned a %s, not a vector2." % [_shift_clamps[i], typeof(point)])		
			continue
		
		var distance : float = (point - position).length_squared()
		if distance < best_distance:
			best_distance = distance
			best_position = point
	
	position = best_position

func clamp_straight_line() -> Vector2:
	_origin = Vector2.ZERO
	var allowed_line := _old_position - _origin
	var inverse_line := Vector2(-allowed_line.y, allowed_line.x)
	var a := RegularGeometry2D._find_intersection(position, inverse_line, _origin, allowed_line)
	return position + inverse_line * a

func clamp_circle_radius() -> Vector2:
	var radius := (_old_position - _origin).length()
	return _origin + (position - _origin).normalized() * radius

func _manhattan_distance(point : Vector2) -> float:
	return abs(point.x) + abs(point.y)

class SelectModeQuery:
	extends RefCounted

	var _select_button : Button

	func get_button() -> Button:
		if not valid_button_instance(_select_button):
			retrieve_button()
		return _select_button

	static func valid_button_instance(button : Node = null) -> bool:
		if button == null:
			return false
		
		if button.is_queued_for_deletion():
			return false

		if not button is Button:
			return false

		return button.toggle_mode and button.icon != null

	func retrieve_button(forced := false) -> bool:
		if not forced and valid_button_instance(_select_button):
			printerr("_select_button is already set.")
			return true

		var main_screen := EditorInterface.get_editor_main_screen()
		var button1 := main_screen.get_node("@CanvasItemEditor@9465/@MarginContainer@9280/@HFlowContainer@9281/@HBoxContainer@9282/@Button@9329")
		var button2 := main_screen.get_child(0).get_child(0).get_child(0).get_child(0).get_child(0)
		var button3 := EditorInterface.get_editor_viewport_2d()\
			.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()\
			.get_child(0).get_child(0).get_child(0).get_child(0).get_child(0)

		var buttons = [button1, button2, button3]

		for button in buttons:
			if valid_button_instance(button):
				_select_button = button
				return true

		printerr("Cannot find selection button.")
		return false
	
	func check_signals() -> void:
		if not valid_button_instance(_select_button):
			return

	func _init() -> void:
		retrieve_button()
