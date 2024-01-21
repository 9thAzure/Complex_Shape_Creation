@tool
extends Node

const modulator_script := preload("res://tests/visual_tests/random_modulate.gd")

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
					child.advance(-child.current_animation_position)
					child.play(animation)
				else:
					child.pause()
				continue
			
			if child.get_script() == modulator_script:
				child.is_on = value
				continue
			
			print(child, "was an unexpected node.")
