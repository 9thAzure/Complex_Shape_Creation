@tool
extends Node

const modulator_script := preload("res://tests/visual_tests/random_modulate.gd")
const table_script := preload("res://tests/visual_tests/table_display.gd")

@export
var enable_all := false:
	set(value):
		enable_all = value
		for child in get_children():
			if child is AnimationPlayer:
				var animations := (child as AnimationPlayer).get_animation_list()
				var animation := ""
				for animation_name in animations:
					if animation_name == "" or animation_name == "RESET":
						continue
					animation = animation_name
				
				if value:
					child.play(animation)
				else:
					child.pause()
				continue
			
			if child.get_script() == modulator_script:
				if child.is_on != value:
					child.is_on = value
				continue
			
			if child.get_script() == table_script:
				continue
			
			print(child, "was an unexpected node.")

@export
var reset := false:
	get:
		return false
	set(_ignored):
		for child in get_children():
			if child is AnimationPlayer:
				var animation_player := child as AnimationPlayer
				animation_player.advance(-animation_player.current_animation_position)
				continue
			
			if child is modulator_script:
				var modulator := child as modulator_script
				if modulator.node_path == null:
					continue
				
				var node := modulator.get_node(modulator.node_path)
				var script = node.get_script()
				
				for property in modulator.properties:
					var property_name : String = property[0]

					if script == null:
						node.set(property_name, 0)
					else:
						var value = script.get_property_default_value(property_name)
						if typeof(value) == typeof(property[1]):
							node.set(property_name, value)
						elif typeof(property[1]) == TYPE_COLOR:
							node.set(property_name, Color.WHITE)
						else:
							node.set(property_name, property[1])
				continue

@export
var auto_start := true

func _ready() -> void:
	if auto_start:
		enable_all = true
		
