@tool
extends Polygon2D
class_name StarPolygon2D

@export_range(3, 2000)
var point_count : int = 5:
	set(value):
		assert(value > 0, "property 'point_count' must be greater than 0")
		point_count = value
		_pre_redraw()
		
@export_range(0.000001, 10, 0.001, "or_greater", "hide_slider")
var size : float = 10.0:
	set(value):
		assert(value > 0, "property 'size' must be greater than 0");
		size = value
		_pre_redraw()

@export_range(0.000001, 10, 0.001, "or_greater", "hide_slider")
var inner_size : float = 5.0:
	set(value):
		assert(value > 0, "property 'inner_size' must be greater than 0");
		size = value
		_pre_redraw()

## The offset rotation of the shape, in degrees.
var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotation)

## the offset rotation of the shape, in radians.
@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians") 
var offset_rotation : float = 0:
	set(value):
		offset_rotation = value
		_pre_redraw()

@export_group("complex")

# The default value is -0.001 so that dragging it into positive values is quick.
## Determines the width of the shape. A value of [code]0[/code] outlines the shape with lines, and a value smaller than [code]0[/code] ignores this effect.
## Values greater than [code]0[/code] will have [member Polygon2D.polygon] used,
## and value greater than [member size] also ignores this effect while still using [member Polygon2D.polygon].
@export_range(-0.001, 10, 0.001, "or_greater", "hide_slider")
var width : float = -0.001:
	set(value):
		if Engine.is_editor_hint() and value > 0 and value < 0.01:
			value = 0
		
		if width > 0 and value <= 0:
			width = value
			polygon = PackedVector2Array()
			return

		width = value
		_pre_redraw()

## The arc of the drawn shape, in degrees, cutting off beyond that arc. 
## Values greater than [code]360[/code] or [code]-360[/code] draws a full shape. It starts in the middle of the base of the shapes. 
## The direction of the arc is clockwise with positive values and counterclockwise with negative values.
## [br][br]A value of [code]0[/code] makes the node not draw anything.
var drawn_arc_degrees : float = 360:
	set(value):
		drawn_arc = deg_to_rad(value)
	get:
		return rad_to_deg(drawn_arc)

## The arc of the drawn shape, in radians, cutting off beyond that arc. 
## Values greater than [constant @GDScript.TAU] or -[constant @GDScript.TAU] draws a full shape. It starts in the middle of the base of the shapes. 
## The direction of the arc is clockwise with positive values and counterclockwise with negative values.
## [br][br]A value of [code]0[/code] makes the node not draw anything.
@export_range(-360, 360, 0.01, "radians") 
var drawn_arc : float = TAU:
	set(value):
		drawn_arc = value
		_pre_redraw()

## The distance from each vertex along the edge to the point where the rounded corner starts.
## If this value is over half of the edge length, the mid-point of the edge is used instead.
@export_range(0.0, 5, 0.001, "or_greater", "hide_slider") 
var corner_size : float = 0.0:
	set(value):
		assert(value >= 0, "property 'corner_size' must be greater than or equal to 0")
		corner_size = value
		_pre_redraw()

## How many lines make up each corner. A value of [code]0[/code] will use a value of [code]32[/code] divided by [member vertices_count].
@export_range(0, 8, 1, "or_greater") 
var corner_smoothness : int = 0:
	set(value):
		assert(value >= 0, "property 'corner_smoothness' must be greater than or equal to 0")
		corner_smoothness = value

# @export_range(0, 90, 0.001, "radians")
# var point_angle := 0.0:
# 	set(value):
# 		# var a := (PI - TAU / point_count) / 2
# 		var a := TAU / point_count / 2
# 		var step := sin(PI - value - a)
# 		inner_size = size * sin(value) / step
# 		point_angle = value
# 		print(rad_to_deg(a))
# 		print(rad_to_deg(asin(step)))
# 		queue_redraw()
# 		regenerate_polygon(

var _is_queued = true

func _pre_redraw() -> void:
	if not uses_polygon_member():
		# the setting the 'polygon' property already calls queue_redraw
		queue_redraw()
		return
	
	if _is_queued:
		return
	
	_is_queued = true
	if not is_inside_tree():
		polygon = PackedVector2Array()
		return

	await get_tree().process_frame
	_is_queued = false
	if not uses_polygon_member():
		return
	regenerate_polygon()

func _enter_tree() -> void:
	if _is_queued and uses_polygon_member() and polygon.is_empty():
		regenerate_polygon()
	_is_queued = false

func uses_polygon_member() -> bool:
	return (
		width > 0
	)

# func _draw():
# 	var scaler1 := Vector2(sin(PI - point_angle), -cos(PI - point_angle))
# 	var scaler2 := Vector2(sin(TAU / point_count / 2), -cos(TAU / point_count / 2))
# 	# print(point_angle)
# 	# print(scaler1)
# 	# print(scaler2)
# 	draw_line(Vector2.UP * size, Vector2.UP * size + scaler1 * size, Color.GREEN)
# 	draw_line(Vector2.ZERO, scaler2 * size, Color.BLUE)


func regenerate_polygon():
	polygon = StarPolygon2D.create_star_shape(point_count, size, inner_size)


static func create_star_shape(point_count : int, size : float, inner_size : float ) -> PackedVector2Array:
	var points = PackedVector2Array()
	var current_rotation := PI
	var rotation_spacing := TAU / point_count / 2
	for i in point_count:	
		points.append(Vector2(-sin(current_rotation), cos(current_rotation)) * size)
		current_rotation += rotation_spacing
		points.append(Vector2(-sin(current_rotation), cos(current_rotation)) * inner_size)
		current_rotation += rotation_spacing
	return points
