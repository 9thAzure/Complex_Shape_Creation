@tool
extends Node2D 

var _parent : Node2D

var _origin := Vector2.ZERO

var _shift_clamps : Array[Callable] = [clamp_straight_line, clamp_circle_radius]

func _init(parent : Node2D) -> void:
	_parent = parent
	if parent == null:
		printerr("%s initialized without parent" % self)
	else:
		print("proper initialization")

func _ready():
	assert(Engine.is_editor_hint())
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)

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
		set_process(true)
		visible = true 
	else:
		maintain_shape()
		if not _being_dragged:
			set_process(false)
			visible = false
			return

		EditorInterface.edit_node(_parent)

func _draw() -> void:
	const margin := 2
	var box := StyleBoxFlat.new()
	box.bg_color = Color.WHITE
	box.border_width_bottom = margin
	box.border_width_top = margin
	box.border_width_left = margin
	box.border_width_right = margin
	box.border_color = Color.BLACK

	box.draw(get_canvas_item(), Rect2(-5, -5, 10, 10))

func _process(_delta):
	if is_inside_tree():
		maintain_shape()
	
var _is_echo := false
var _being_dragged := false
var _old_position := Vector2.ZERO

func maintain_shape():
	var editor_scale := get_viewport_transform().get_scale().x
	var cache_global_position = global_position

	var mouse_position := get_global_mouse_position()
	var mouse_pressed := Input.is_mouse_button_pressed(1)
	if mouse_pressed:
		if not _is_echo:
			_is_echo = true
			if _manhattan_distance(mouse_position - cache_global_position) <= 7 / editor_scale:
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
