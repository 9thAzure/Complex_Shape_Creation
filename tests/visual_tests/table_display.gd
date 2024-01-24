@tool
extends Node2D

@export
var test_script : Script = null:
	set(value):
		test_script = value
		if value == null:
			return
		if not value.new() is Node2D:
			printerr("script does not have base class of or inherited from Node2D")

@export
var spacing := Vector2(30, 30)

@export
var max_time := 2.0

@export
var properties : Array[Array] = []:
	set(value):
		if value == null:
			properties = []
			return
		
		var size = value.size()
		for i in size:
			var array := value[i]
			if array == null:
				array = Array()
				value[i] = array
			if array.size() != 3:
				array.resize(3)
			
			var property = array[0]
			if typeof(property) != TYPE_STRING:
				array[0] = ""
			
			if array[1] != null and typeof(array[1]) != typeof(array[2]):
				array[2] = array[1]
		
		properties = value

@export
var defaults : Dictionary = {}:
	set(values):
		if VisualShaderNodeCustom == null:
			values = {}
		defaults = values

var tween : Tween

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	assert(test_script != null)
	var size := properties.size()

	for x in size:
		for y in size:
			if x <= y:
				continue
			
			var node : Node2D = test_script.new()
			node.position = Vector2(spacing.x * x, spacing.y * y)
			for key in defaults:
				node.set(key, defaults[key])
			add_child(node)
	
	modulate_properties()

func modulate_properties() -> void:
	tween = get_tree().create_tween()
	tween.set_parallel(true)

	var time : float = lerp(0.5, max_time, randf())
	var size := properties.size()
	var targets := Array()
	targets.resize(size)
	for i in size:
		targets[i] = random_property(properties[i][1], properties[i][2])

	var i := -1
	for x in size:
		for y in size:
			if x <= y:
				continue
			i += 1
			var node := get_child(i)
			tween.tween_property(node, properties[x][0], targets[x], time)
			tween.tween_property(node, properties[y][0], targets[y], time)
	
	tween.finished.connect(modulate_properties)
	tween.play()

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
