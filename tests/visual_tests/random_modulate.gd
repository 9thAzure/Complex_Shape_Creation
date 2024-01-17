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
			if typeof(property) != TYPE_STRING and typeof(property) != TYPE_NODE_PATH:
				array[0] = ""
		
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
	var time := max_time * randf()
	var final_value = (property[2] - property[1]) * randf() + property[1]

	tween.tween_property(node, property[0], final_value, time)
	tween.finished.connect(activate_tween_loop)


