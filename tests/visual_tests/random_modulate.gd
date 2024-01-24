@tool
extends Node

@export
var node_path : NodePath:
	set(path):
		node_path = path
		if not has_node(path):
			return

		node = get_node(path)
		if node != null:
			pass

var node : Node

@export
var properties : Array[Array]:
	set(value):
		if value == null:
			return
		
		var size = value.size()
		for i in size:
			var array := value[i]
			if array == null:
				array = Array()
			if array.size() != 3:
				array.resize(3)
			
			var property = array[0]
			if typeof(property) != TYPE_STRING:
				array[0] = ""
			
			if array[1] != null and typeof(array[1]) != typeof(array[2]):
				array[2] = array[1]
		
		properties = value

@export_range(0, 10, 0.1, "or_greater")
var max_time := 2.0

@export
var is_on := false:
	set(value):
		if node == null:
			node = get_node(node_path)
			if node == null:
				return

		is_on = value
		if value:
			if tween != null and tween.is_running():
				return
			activate_tween_loop()
			return
		elif tween != null:
			tween.kill()

var tween : Tween

func activate_tween_loop() -> void:
	var size := properties.size()
	tween = get_tree().create_tween()
	var property := properties[randi() % size]
	var time : float = lerp(0.5, max_time, randf())

	var final_value = random_property(property[1], property[2])

	tween.tween_property(node, property[0], final_value, time)
	tween.finished.connect(activate_tween_loop)


func random_property(start, end):
	assert(typeof(start) == typeof(end))
	if randf() < 1.0 / 10.0:
		return start
	if randf() < 1.0 / 9.0:
		return end
	if typeof(start) in [TYPE_INT, TYPE_FLOAT] and start < 0 and end > 0 and randf() < 1.0 / 8.0:
		return 0
	if typeof(start) == TYPE_VECTOR2:
		return Vector2(random_property(start.x, end.x), random_property(start.y, end.y))
	if typeof(start) == TYPE_COLOR:
		return Color(random_property(start.r, end.r), random_property(start.g, end.g), random_property(start.b, end.b), random_property(start.a, end.a))
	return lerp(start, end, randf())
	
