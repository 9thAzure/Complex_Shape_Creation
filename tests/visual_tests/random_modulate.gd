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
var max_time := 5.0

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

func activate_tween_loop():
	var size := properties.size()
	tween = get_tree().create_tween()
	var property := properties[randi() % size]
	var time := (max_time  - 0.5) * randf() + 0.5

	var chance := randf()
	var final_value
	if chance < 0.1:
		final_value = property[1]
	elif chance < 0.2:
		final_value = property[2]
	elif chance < 0.3 and typeof(property[1]) in [TYPE_INT, TYPE_FLOAT] and property[1] < 0 and property[2] > 0:
		final_value = 0
	else:
		final_value = (property[2] - property[1]) * randf() + property[1]

	tween.tween_property(node, property[0], final_value, time)
	tween.finished.connect(activate_tween_loop)


