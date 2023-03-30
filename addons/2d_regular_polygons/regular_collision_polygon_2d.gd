@tool
class_name RegularCollisionPolygon2D
extends CollisionShape2D

## The number of vertices in the regular shape.
## a value of 1 creates a circle, a value of 2 creates a line.
## [br]Values are clamped to a value greater than or equal to 1.
@export_range(1,8,1,"or_greater")
var vertices_count : int = 1:
	set(value):
		assert(value < 2000, "Large vertices counts should not be necessary.")
		vertices_count = value
		if value < 1:
			vertices_count = 1

		_queue_recreate()

## The length of each corner to the center.
## Values are clamped to a value greater than 0.
@export
var size : float = 10:
	set(value):
		size = value
		if value <= 0:
			size = 0.00000001
		
		_queue_recreate()

## The offset rotation of the shape, in degrees.
@export_range(-360, 360, 0.1, "or_greater", "or_less")
var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotation)

## The offset rotation of the shape, in radians.
var offset_rotation : float = 0:
	set(value):
		offset_rotation = value
		_queue_recreate()

@export_group("advanced")

## Determines the width of the shape. A value of 0 or a value greater than or equal to [member size] ignores this effect.
## [br][br]Note: If this node isn't in a tree, the setting of [member polygon] will be delayed to when it enters one.
@export 
var width : float = 0:
	set(value):
		width = value
		_queue_recreate()

## The arc of the drawn shape, in degrees, cutting off beyond that arc. 
## Values greater than [code]360[/code] or [code]-360[/code] draws a full shape. It starts in the middle of the base of the shapes. 
## [br]The direction of the arc is clockwise with positive values and counterclockwise with negative values.
## [br][br]A value of [code]0[/code] makes the node not draw anything.
@export_range(-360, 360) 
var drawn_arc_degrees : float = 360:
	set(value):
		drawn_arc = deg_to_rad(value)
	get:
		return rad_to_deg(drawn_arc)

## The arc of the drawn shape, in radians, cutting off beyond that arc. 
## Values greater than [constant @GDScript.TAU] or -[constant @GDScript.TAU] draws a full shape. It starts in the middle of the base of the shapes. 
## [br]The direction of the arc is clockwise with positive values and counterclockwise with negative values.
## [br][br]A value of [code]0[/code] makes the node not draw anything.
var drawn_arc : float = TAU:
	set(value):
		drawn_arc = value
		_queue_recreate()

var is_queued := false

func _queue_recreate() -> void:
	if is_queued:
		return
	
	is_queued = true
	if not is_inside_tree():
		return
	
	await get_tree().process_frame
	is_queued = false
	_create()

func _enter_tree():
	if is_queued and shape == null:
		_create()
	is_queued = false

func _create() -> void:
	if vertices_count == 2:
		var line := SegmentShape2D.new()
		line.a = size * (Vector2.UP if is_zero_approx(offset_rotation) else Vector2(sin(offset_rotation), -cos(offset_rotation)))
		line.b = -line.a
		shape = line
		return
	
	if drawn_arc == 0:
		return
	
	var uses_width := width > 0
	if (uses_width
		or -TAU < drawn_arc and drawn_arc < TAU
	):
		var polygon := ConvexPolygonShape2D.new()
		var points := ComplexPolygon2D.get_shape_vertices(vertices_count, size, offset_rotation, Vector2.ZERO, drawn_arc, not uses_width)
		if uses_width and width < size:
			ComplexPolygon2D.add_hole_to_points(points, 1 - width / size, not _uses_drawn_arc())
		
		polygon.points = points
		shape = polygon
		return
	
	if vertices_count == 1:
		var circle := CircleShape2D.new()
		circle.radius = size
		shape = circle
		return
	
	if vertices_count == 4 and is_zero_approx(offset_rotation):
		const sqrt_two_over_two := 0.707106781
		var square := RectangleShape2D.new()
		square.size = size / sqrt_two_over_two * Vector2.ONE
		shape = square
		return
	
	var polygon := ConvexPolygonShape2D.new()
	polygon.points = RegularPolygon2D.get_shape_vertices(vertices_count, size, offset_rotation)
	shape = polygon

func _uses_drawn_arc():
	return -TAU < drawn_arc and drawn_arc < TAU