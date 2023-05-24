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
		inner_size = value
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

func set_point_angle(angle : float) -> void:
	assert(0 < angle and angle < TAU)
	angle /= 2
	inner_size = size * sin(angle / (sin(PI - angle - TAU / point_count / 2)))

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

func _draw():
	if uses_polygon_member() or drawn_arc == 0:
		return

	var points := get_star_vertices(point_count, size, inner_size, offset_rotation, offset, drawn_arc)
	draw_colored_polygon(points, color);
	
func regenerate_polygon():
	polygon = StarPolygon2D.get_star_vertices(point_count, size, inner_size, offset_rotation, Vector2.ZERO, drawn_arc)
		
func uses_polygon_member() -> bool:
	return (
		width > 0
	)

static func get_star_vertices(point_count : int, size : float, inner_size : float, offset_rotation := 0.0, offset_position := Vector2.ZERO,
	drawn_arc := TAU, add_central_point := true) -> PackedVector2Array:
	assert(point_count > 2, "param 'point_count' must be greater than 2")
	assert(size > 0, "param 'size' must be greater than 0")
	assert(inner_size > 0, "param 'inner_size' must be greater than 0")
	assert(drawn_arc != 0, "param 'drawn_arc' cannot be 0")
	
	var points := PackedVector2Array()
	offset_rotation += PI
	if drawn_arc >= TAU or drawn_arc <= -TAU:
		var current_rotation := offset_rotation
		var rotation_spacing := TAU / point_count / 2
		for i in point_count:	
			points.append(Vector2(-sin(current_rotation), cos(current_rotation)) * size + offset_position)
			current_rotation += rotation_spacing
			points.append(Vector2(-sin(current_rotation), cos(current_rotation)) * inner_size + offset_position)
			current_rotation += rotation_spacing
		return points
	
	var sign := signf(drawn_arc)
	var rotation_spacing := TAU / point_count * sign
	var half_rotation_spacing := rotation_spacing / 2
	var original_vertices_count := floori(drawn_arc / half_rotation_spacing)
	var ends_on_vertex := is_equal_approx(drawn_arc, original_vertices_count * half_rotation_spacing)
	original_vertices_count += 1

	if add_central_point and is_zero_approx(sign * drawn_arc - PI):
		add_central_point = false

	# print(original_vertices_count)
	if add_central_point and not ends_on_vertex:
		# print("+2")
		points.resize(original_vertices_count + 2)
	elif add_central_point == ends_on_vertex:
		# print("+1")
		points.resize(original_vertices_count + 1)
	else:
		points.resize(original_vertices_count)

	var max_i := original_vertices_count / 2
	for i in max_i:
		var rotation := rotation_spacing * i + offset_rotation
		points[2 * i] = _get_vertices(rotation, size, offset_position)
		points[2 * i + 1] = _get_vertices(rotation + half_rotation_spacing, inner_size, offset_position)
	
	if original_vertices_count & 1 == 1:
		points[original_vertices_count - 1] = _get_vertices((original_vertices_count - 1) * half_rotation_spacing + offset_rotation, size, offset_position)
	
	if not ends_on_vertex:
		var last_point := points[original_vertices_count - 1]
		var next_point : Vector2
		if original_vertices_count & 1 == 0:
			next_point = _get_vertices(half_rotation_spacing * original_vertices_count + offset_rotation, size, offset_position)
		else:
			next_point = _get_vertices(half_rotation_spacing * original_vertices_count + offset_rotation, inner_size, offset_position)
		
		var edge_slope := next_point - last_point
		var ending_slope := _get_vertices(drawn_arc + offset_rotation)

		var scaler := RegularPolygon2D._find_intersection(last_point, edge_slope, offset_position, ending_slope)
		points[original_vertices_count] = last_point + edge_slope * scaler
	
	if add_central_point:
		points[-1] = offset_position
	return points
	
static func _get_vertices(rotation : float, size : float = 1, offset : Vector2 = Vector2.ZERO) -> Vector2:
	return Vector2(-sin(rotation), cos(rotation)) * size + offset
