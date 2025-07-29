@tool
@icon("res://addons/simplified_shape_creation/simple_polygon_2d/simple_polygon_2d.svg")
class_name BasicPolygon2D
extends Node2D

## Node that draws regular shapes.
##
## A node that draws a regular shape, using methods like [method CanvasItem.draw_colored_polygon] and [method CanvasItem.draw_circle]. 
## If more complex features are needed, use [RegularPolygon2D].


## The number of vertices in the regular shape. A value of [code]1[/code] creates a circle, and a value of [code]2[/code] creates a line.
@export_range(1, 1000)
var vertices_count : int = 1:
	set(value):
		assert(value > 0, "property 'vertices_count' must be greater than 0")
		vertices_count = value
		queue_regenerate()

## The length from each corner to the center of the shape.
#@export_range(0.000001, 10, 0.001, "or_greater", "hide_slider")
var size : float = 10:
	get:
		return sizes[0]
	set(value):
		sizes[0] = value
		queue_regenerate()

@export
var sizes : PackedFloat64Array = PackedFloat64Array([10]):
	set(value):
		if value.size() == 0:
			return

		for i in value.size():
			if value[i] < 0.001:
				value[i] = 0.001 if i >= sizes.size() else sizes[i]


		sizes = value
		queue_regenerate()

## The offset rotation of the shape, in degrees.
var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotation)

## The offset rotation of the shape, in radians.
@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians")
var offset_rotation : float = 0:
	set(value):
		offset_rotation = value
		queue_regenerate()

## Transforms [member CollisionShape2D.shape], rotating it by [param rotation] radians and scaling it by a factor of [param scaler].
func apply_transformation(rotation : float, scale : float) -> void:
	assert(scale > 0, "param 'scale' should be positive.")
	offset_rotation += rotation
	size *= scale

## see [member offset]
## @deprecated
@export
var offset_position := Vector2.ZERO:
	set(value):
		offset = value
	get:
		return offset

## The offset position of the shape.
var offset : Vector2 = Vector2.ZERO:
	set(value):
		offset = value
		queue_regenerate()

@export_range(0, 1, 0.001, "or_less")
var ring_ratio : float = 1.0:
	set(value):
		ring_ratio = value
		update_configuration_warnings()
		queue_regenerate()

@export_range(0.0, 10, 0.001, "or_greater", "hide_slider")
var corner_size : float = 0.0:
	set(value):
		assert(value >= 0, "property 'corner_size' must be greater than or equal to 0")
		corner_size = value
		queue_regenerate()

## How many lines make up each corner. A value of [code]0[/code] will use a value of [code]32[/code] divided by [member vertices_count].
## This only has an effect if [member corner_size] is used.
@export_range(0, 50)
var corner_smoothness : int = 0:
	set(value):
		assert(value >= 0, "property 'corner_smoothness' must be greater than or equal to 0")
		corner_smoothness = value
		queue_regenerate()

@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians")
var arc_start : float = 0.0:
	set(value):
		arc_start = value
		update_configuration_warnings()
		queue_regenerate()

@export_range(0, 360, 0.1, "or_greater", "or_less", "radians")
var arc_angle : float = TAU:
	set(value):
		arc_angle = value
		update_configuration_warnings()
		queue_regenerate()

var arc_end : float = TAU:
	get: return arc_start + arc_angle
	set(value): arc_angle = value - arc_start

var arc_start_degrees : float:
	get: return rad_to_deg(arc_start)
	set(value): arc_start = deg_to_rad(value)

var arc_angle_degrees : float:
	get: return rad_to_deg(arc_angle)
	set(value): arc_angle = deg_to_rad(value)

var arc_end_degrees : float:
	get: return rad_to_deg(arc_end)
	set(value): arc_end = deg_to_rad(value)

## Strategies for closing an open shape.
enum ClosingMethod {
	## Shape is closed with two lines between the ends and the center of the shape.
	SLICE,
	## Shape is closed by connected the 2 ends together directly.
	CHORD,
	## Shape is left open. This only has an effect for lines, and is otherwise equivalent to [constant ClosingStrategy.CHORD].
	ARC,
}

@export
var closing_method : ClosingMethod = ClosingMethod.SLICE:
	set(value):
		closing_method = value
		update_configuration_warnings()
		queue_regenerate()

@export
var round_arc_ends : bool = false:
	set(value):
		round_arc_ends = value
		queue_regenerate()

@export_group("Drawing")

@export
var draw_shape := true:
	set(value):
		draw_shape = value
		update_configuration_warnings()
		queue_redraw()

@export_range(0, 10, 0.001, "or_greater", "hide_slider")
var line_width : float = 0.0:
	set(value):
		line_width = value
		queue_regenerate()

## The color of the shape.
@export
var color : Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

@export_group("Exporting")

@export_flags("Editor:1", "Run Time:2")
var export_behaviour : int = ExportBehaviour.DISABLED:
	set(value):
		var was_exporting := is_exporting()
		export_behaviour = value
		if not was_exporting and is_exporting():
			queue_export()

enum ExportBehaviour {
	DISABLED = 0,
	EDITOR = 1,
	RUN_TIME = 2,
}

@export
var export_as_decomposed_hulls := false

@export
var auto_free := false

@export_group("Exporting", "export")

@export
var export_targets : Array[NodePath] = []:
	set(value):
		if value == null:
			return
		export_targets = value
		update_configuration_warnings()

signal shape_created(shape : PackedVector2Array, decomposed_shape : Array[PackedVector2Array], shape_type : ShapeType)

var _created_shape : PackedVector2Array = []:
	set(value):
		_created_shape = value
		if _queue_status != _QUEUE_DISPERSE:
			_queue_status = _UNQUEUED
			queue_export()
		queue_redraw()

var _decomposed_created_shape : Array[PackedVector2Array] = []:
	set(value):
		_decomposed_created_shape = value
		if _queue_status != _QUEUE_DISPERSE:
			_queue_status = _UNQUEUED
			queue_export()
		queue_redraw()

func is_exporting() -> bool:
	var in_editor := Engine.is_editor_hint()
	return in_editor and (export_behaviour & ExportBehaviour.EDITOR) > 0 or not in_editor and (export_behaviour & ExportBehaviour.RUN_TIME) > 0

func get_created_shape() -> PackedVector2Array: return _created_shape
func get_created_shape_decomposed() -> Array[PackedVector2Array]: return _decomposed_created_shape

enum ShapeType {
	POLYGON,
	POLYLINE,
	MULTILINE,
}

func get_created_shape_type() -> ShapeType:
	if vertices_count == 2: return ShapeType.MULTILINE
	if is_zero_approx(ring_ratio): return ShapeType.POLYLINE
	return ShapeType.POLYGON

const _UNQUEUED         := 0
const _QUEUE_DISPERSE   := 1
const _QUEUE_REGENERATE := 2

var _queue_status : int = _UNQUEUED

func _enter_tree() -> void:
	if _queue_status == _QUEUE_REGENERATE:
		regenerate()
	if _queue_status == _QUEUE_DISPERSE:
		_queue_status = _UNQUEUED
		queue_export()

## A method for consistency across other nodes. [b]Equivalent to [method CanvasItem.queue_redraw].[/b]
func queue_regenerate() -> void:
	if _queue_status >= _QUEUE_REGENERATE:
		return

	_queue_status = _QUEUE_REGENERATE
	if not is_inside_tree():
		return

	await get_tree().process_frame
	if _queue_status != _QUEUE_REGENERATE:
		return

	regenerate()

## A method for consistency across other nodes, and does not even regenerate the shape immediately. [b]Equivalent to [method CanvasItem.queue_redraw].[/b]
func regenerate() -> void:
	_queue_status = _UNQUEUED

	var shape : PackedVector2Array
	var decomposed_shape : Array[PackedVector2Array]
	var is_outline := is_zero_approx(ring_ratio)
	var is_ring_shape :=  not is_outline and ring_ratio < 1
	var uses_arc := not is_equal_approx(arc_angle, TAU)
	var rounded_corners := not is_zero_approx(corner_size)
	var true_corner_smoothness := corner_smoothness if corner_smoothness != 0 else maxi(1, 32 / vertices_count)

	if is_zero_approx(arc_angle):
		if not Engine.is_editor_hint():
			printerr("Unable to draw a shape whoose arc angle is 0º")

		_queue_status = _QUEUE_DISPERSE
		_created_shape = []
		_decomposed_created_shape = []
		export()
		return

	if vertices_count == 2:
		shape = BasicGeometry2D.create_shape(maxi(sizes.size(), 2), sizes, offset_rotation, offset_position, arc_start, arc_end, false)
		shape.resize(shape.size() * 2)
		for i in shape.size() / 2:
			var index := shape.size() / 2 - i - 1
			var point := shape[index]
			shape[index * 2] = point
			shape[index * 2 + 1] = point.lerp(offset_position, ring_ratio)

		_queue_status = _QUEUE_DISPERSE
		_created_shape = shape
		_decomposed_created_shape = [shape]
		export()
		return

	var add_central_point := closing_method == ClosingMethod.SLICE or closing_method == ClosingMethod.ARC and is_equal_approx(ring_ratio, 1)
	shape = BasicGeometry2D.create_shape(vertices_count, sizes, offset_rotation, offset_position, arc_start, arc_end, add_central_point)

	if rounded_corners:
		if not uses_arc:
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_smoothness)
		elif not round_arc_ends or round_arc_ends and closing_method == ClosingMethod.ARC and is_outline:
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_smoothness, 1, shape.size() - (3 if add_central_point else 2))
		elif closing_method == ClosingMethod.SLICE:
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_smoothness, 0, shape.size() - 1)
		elif closing_method == ClosingMethod.CHORD:
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_smoothness)
		elif closing_method == ClosingMethod.ARC and is_equal_approx(ring_ratio, 1):
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_smoothness, 0, shape.size() - 1)

	if is_ring_shape:
		if not uses_arc or closing_method != ClosingMethod.SLICE:
			BasicGeometry2D.add_ring(shape, ring_ratio, offset_position, not uses_arc or closing_method == ClosingMethod.CHORD)
		else: # uses_arc and closing_strategy == ClosingStrategy.SLICE
			var arc_change := minf(TAU - arc_angle, -TAU * ring_ratio * (1 - arc_angle / TAU) / 4)
			var inner_arc_start := arc_start - arc_change / 2
			var inner_arc_end := arc_end + arc_change / 2
			if inner_arc_start < inner_arc_end:
				var inner_ring := BasicGeometry2D.create_shape(vertices_count, sizes, offset_rotation, offset_position, inner_arc_start, inner_arc_end)
				if is_equal_approx(inner_arc_end - inner_arc_start, TAU):
					inner_ring.resize(inner_ring.size() + 2)
					inner_ring[-2] = inner_ring[0]
					inner_ring[-1] = offset_position

				shape.resize(shape.size() + inner_ring.size() + 1)
				shape[-1] = offset_position
				for i in inner_ring.size():
					shape[-i - 2] = inner_ring[i].lerp(offset_position, ring_ratio)

				if rounded_corners:
					var inner_corner_size := lerpf(corner_size, 0, ring_ratio)
					var inner_start := shape.size() - inner_ring.size()
					var inner_length := inner_ring.size() - 1
					if not round_arc_ends:
						inner_start += 1
						inner_length -= 2

					BasicGeometry2D.add_rounded_corners(shape, inner_corner_size, true_corner_smoothness, inner_start, inner_length, false)

	if rounded_corners and uses_arc and closing_method == ClosingMethod.ARC and round_arc_ends and is_ring_shape:
		var inner_corner_size := lerpf(corner_size, 0, ring_ratio)
		var original_size := shape.size()

		BasicGeometry2D.add_rounded_corners(shape, inner_corner_size, true_corner_smoothness, original_size / 2, original_size / 2)
		BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_smoothness, 0, original_size / 2, false)

	if is_outline:
		if not uses_arc or closing_method != ClosingMethod.ARC:
			shape.push_back(shape[0])

		decomposed_shape = [shape]

		_queue_status = _QUEUE_DISPERSE
		_created_shape = shape
		_decomposed_created_shape = decomposed_shape
		export()
		return

	if absf(arc_angle) <= PI and ring_ratio < 1 and ring_ratio > 0 and closing_method == ClosingMethod.CHORD:
		decomposed_shape = [shape]
	else:
		decomposed_shape = Geometry2D.decompose_polygon_in_convex(shape)

	# block _create_shape from queueing 'disperse' call.
	_queue_status = _QUEUE_DISPERSE
	_created_shape = shape
	_decomposed_created_shape = decomposed_shape
	export()

func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary] = []
	properties.append({
		name = "_created_shape",
		type = TYPE_PACKED_VECTOR2_ARRAY,
		usage = PROPERTY_USAGE_STORAGE
	})
	properties.append({
		name = "_decomposed_created_shape",
		type = TYPE_ARRAY,
		usage = PROPERTY_USAGE_STORAGE
	})

	return properties

func queue_export() -> void:
	if _queue_status >= _QUEUE_DISPERSE:
		return

	_queue_status = _QUEUE_DISPERSE
	if not is_inside_tree():
		return

	await get_tree().process_frame
	if _queue_status != _QUEUE_DISPERSE:
		return

	export()

func export() -> void:
	_queue_status = _UNQUEUED

	shape_created.emit(_created_shape, _decomposed_created_shape, get_created_shape_type())
	if is_exporting():
		var exported_objects : Variant = _decomposed_created_shape if export_as_decomposed_hulls else _created_shape
		for path in export_targets:
			var node := self if path.get_name_count() == 0 else get_node(NodePath(String(path.get_concatenated_names())))
			assert(node != null)
			node.set_indexed(NodePath(String(path.get_concatenated_subnames())), exported_objects)

	if not Engine.is_editor_hint() and auto_free:
		queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if is_equal_approx(arc_start, arc_end):
		warnings.push_back("The arc of the shape is 0º, so nothing will be created")

	if absf(arc_angle) <= PI and ring_ratio < 1 and ring_ratio > 0 and closing_method == ClosingMethod.CHORD and draw_shape:
		warnings.push_back("Unable to draw a ring shape that is closed as a chord when the arc angle is less than or equal to 180º")

	for i in export_targets.size():
		var path := export_targets[i]
		if path.is_empty():
			warnings.push_back("The export path at index %s is unassigned." % i)
			continue

		var node_path := NodePath(String(path.get_concatenated_names()))
		var node := get_node_or_null(node_path)
		if node == null:
			warnings.push_back("The export path at index %s points to a non existant node" % i)
			continue

		if path.get_subname_count() == 0:
			warnings.push_back("The export path at index %s does not reference a property" % i)
			continue

		var previous_object : Variant = node
		var failure := false
		for i2 in path.get_subname_count() - 1:
			var property := path.get_subname(i2)
			if not (property in previous_object):
				warnings.push_back("The export path at index %s has a non-existant property reference at subname #%s (%s)" % [i, i2, property])
				failure = true
				break

			previous_object = previous_object.get(property)
			if typeof(previous_object) != TYPE_OBJECT or previous_object == null:
				warnings.push_back("The export path at index %s has a property reference which is null or isn't of type Object at subname #%s (type: %s)" % [i, i2, "null" if previous_object == null else type_string(typeof(previous_object))])
				failure = true
				break

		if failure:
			continue

		var last_i := path.get_subname_count() - 1
		var property := path.get_subname(last_i)
		if not (property in previous_object):
			warnings.push_back("The export path at index %s points to a non-existant property (%s)" % [i, path.get_concatenated_subnames()])
			continue

		var type := typeof(previous_object.get(property))
		if type != TYPE_PACKED_VECTOR2_ARRAY and type != TYPE_ARRAY:
			warnings.push_back("The export path at index %s points to a property that is either currently null or not an Array or PackedVector2Array (type: %s)" % [i, type_string(type)])
			continue

	return warnings

func _draw() -> void:
	if not draw_shape:
		return

	if is_zero_approx(arc_angle):
		return

	if absf(arc_angle) <= PI and ring_ratio < 1 and ring_ratio > 0 and closing_method == ClosingMethod.CHORD:
		if not Engine.is_editor_hint():
			printerr("Unable to draw a ring shape that is closed as a chord when the arc angle is less than or equal to 180º")
		return

	match get_created_shape_type():
		ShapeType.POLYGON:
			for hull in _decomposed_created_shape:
				draw_colored_polygon(hull, color)
		ShapeType.POLYLINE:
			draw_polyline(_created_shape, color, line_width if line_width > 0 else -1)
		ShapeType.MULTILINE:
			draw_multiline(_created_shape, color, line_width if line_width > 0 else -1)
		_:
			assert(false, "unexpected match case: %s" % get_created_shape_type())

func _init(vertices_count : int = 1, size := 10.0, offset_rotation := 0.0, color := Color.WHITE, offset_position := Vector2.ZERO):
	if vertices_count != 1:
		self.vertices_count = vertices_count
	if size != 10.0:
		self.size = size
	if offset_rotation != 0.0:
		self.offset_rotation = offset_rotation
	if color != Color.WHITE:
		self.color = color
	if offset_position != Vector2.ZERO:
		self.offset = offset_position

static var _circle := get_shape_vertices(32)

## Returns a [PackedVector2Array] with the points for the shape with the specified [param vertices_count].
## [br][br]If [param vertices_count] is [code]1[/code], a value of [code]32[/code] is used instead.
static func get_shape_vertices(vertices_count : int, size : float = 1, offset_rotation : float = 0.0, offset_position : Vector2 = Vector2.ZERO) -> PackedVector2Array:
	assert(vertices_count >= 1, "param 'vertices_count' must be 1 or greater.")
	assert(size > 0, "param 'size' must be positive.")
	
	if vertices_count == 1:
		return _circle * Transform2D(-offset_rotation, Vector2.ONE * size, 0, offset_position)

	var points := PackedVector2Array()
	points.resize(vertices_count)
	var rotation_spacing := TAU / vertices_count
	var current_rotation := -rotation_spacing / 2 + offset_rotation
	for i in vertices_count:
		points[i] = Vector2(-sin(current_rotation), cos(current_rotation)) * size + offset_position
		current_rotation += rotation_spacing

	return points

static func _get_vertices(rotation : float, size : float = 1, offset : Vector2 = Vector2.ZERO) -> Vector2:
	return Vector2(-sin(rotation), cos(rotation)) * size + offset
