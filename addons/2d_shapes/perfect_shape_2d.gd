@tool
extends Node2D

## A node that simply draws a perfect shape

## The number of vertices in the perfect shape
## a value of 1 creates a circle, a value of 2 creates a line
@export_range(1,8,1,"or_greater") var vertice_count : int = 1:
	set(value):
		assert(vertice_count >= 1)
		vertice_count = value
		queue_redraw()

## The length of each corner to the center.
@export var size : float = 10:
	set(value):
		assert(size >= 0)
		size = value
		queue_redraw()

## The color of the shape
@export var color : Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

# unfortunately, negative values are not working for export range
## The offset rotation of the shape, in degrees.
@export_range(0, 360, 0.1, "or_greater", "or_less") var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotatation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotatation)

## the offset rotation of the shape, in radians
var offset_rotatation : float = 0:
	set(value):
		offset_rotatation = value
		queue_redraw()

func _draw() -> void:
	print(size)
	if (vertice_count == 1):
		draw_circle(Vector2.ZERO, size, color)
		return
	if (vertice_count == 2):
		#! need to add functionality of offset_rotation.
		draw_line(Vector2.UP, Vector2.DOWN, color, size)
		return
	
	if (vertice_count == 4 && offset_rotatation == 0):
		const sqrt_two_over_two := 0.707106781
		draw_rect(Rect2(-Vector2.ONE * sqrt_two_over_two * size, Vector2.ONE * sqrt_two_over_two * size * 2), color)
		return
	
	var points := PackedVector2Array()
	var rotation_spacing := TAU / vertice_count
	# rotation is initalized pointing down and offset to the left so that the bottem is flat
	var current_rotation := rotation_spacing / 2 + offset_rotatation
	print(current_rotation)
	for i in vertice_count:
		points.append(Vector2(sin(current_rotation), cos(current_rotation)) * size) 
		current_rotation += rotation_spacing
	draw_colored_polygon(points, color)




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
