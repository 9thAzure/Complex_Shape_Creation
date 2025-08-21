@tool
@icon("res://addons/basic_shape_creation/basic_polygon2d/basic_polygon2d.svg")
class_name BasicPolygon2D
extends Node2D

## A basic shape creater.
##
## A node for creating and drawing basic shapes, acting as a simplified wrapper around [BasicGeometry2D].
## The created shape can be accessed by [method get_created_shape], connecting the [signal shape_exported] signal,
## or by using the [BasicPolygon2D]'s export system with [member export_targets].
## [br][br]The shape is regenerated and exported whenever any of the shape properties are changed, and exported whenever any
## of the export properties are changed and [method can_export] returns [code]true[/code].
## [br][br][b][color=red]Warning[/color][/b]: The method [method queue_regenerate], which the [BasicPolygon2D] uses to regenerate the shape,
## as well as [method queue_export], relies upon the main loop being a [SceneTree] to function properly.

@export_group("Generation")
## The number of vertices in the base shape.
## A value of [code]1[/code] creates a 32 vertices shape.
## A value of [code]2[/code] creates multiple equidistantly spaced lines from the center, one for each value in [member sizes].
@export_range(1, 1000)
var vertices_count : int = 1:
	set(value):
		assert(value > 0, "property 'vertices_count' must be greater than 0")
		vertices_count = value
		update_configuration_warnings()
		queue_regenerate()

## The distance from the center to each vertex, cycling through if there are multiple values.
## [br][br][b]Note[/b]: The default value is a [PackedFloat64Array] of [code][10.0][/code]. The [code]<unknown>[/code]
## documented here is a bug with Godot.
@export
var sizes : PackedFloat64Array = PackedFloat64Array([10.0]):
	set(value):
		if value.size() == 0:
			return

		for i in value.size():
			if value[i] < 0.001:
				value[i] = 10 if i >= sizes.size() else sizes[i]


		sizes = value
		queue_regenerate()

## The size of the ring, in proportion from the outer edge to the center. A value of [code]1[/code] creates a normal shape,
## a value of [code]0[/code] creates a [enum ShapeType].Polyline outline, and a negative value extends the ring outwards proportionally.
@export_range(0, 1, 0.001, "or_less")
var ring_ratio : float = 1.0:
	set(value):
		assert(ring_ratio <= 1.0, "property 'ring_ratio' must be 1 or less")
		ring_ratio = value
		update_configuration_warnings()
		queue_regenerate()

## The size of each corner, as the distance along both edges, from the original vertex, to the point where the corner starts and ends.
@export_range(0.0, 10, 0.001, "or_greater", "hide_slider")
var corner_size : float = 0.0:
	set(value):
		assert(value >= 0, "property 'corner_size' must be greater than or equal to 0")
		corner_size = value
		queue_regenerate()

## How many lines make up each corner. A value of [code]0[/code] will use a value of [code]32[/code] divided by [member vertices_count].
@export_range(0, 50)
var corner_detail : int = 0:
	set(value):
		assert(value >= 0, "property 'corner_detail' must be greater than or equal to 0")
		corner_detail = value
		queue_regenerate()

## The starting angle of the arc of the shape that is created, in radians.
@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians")
var arc_start : float = 0.0:
	set(value):
		arc_start = value
		update_configuration_warnings()
		queue_regenerate()

## The angle of the arc of the shape that is created, in radians.
@export_range(0, 360, 0.1, "or_greater", "or_less", "radians")
var arc_angle : float = TAU:
	set(value):
		arc_angle = value
		update_configuration_warnings()
		queue_regenerate()

## The ending angle of the arc of the shape that is created, in radians.
## [br][br][b]Note[/b]: This property's value depends on [member arc_start] and [member arc_angle],
## and setting this property will affect [member arc_angle].
var arc_end : float = TAU:
	get: return arc_start + arc_angle
	set(value): arc_angle = value - arc_start

## The starting angle of the arc of the shape that is created, in degrees.
var arc_start_degrees : float:
	get: return rad_to_deg(arc_start)
	set(value): arc_start = deg_to_rad(value)

## The angle of the arc of the shape that is created, in degrees.
var arc_angle_degrees : float:
	get: return rad_to_deg(arc_angle)
	set(value): arc_angle = deg_to_rad(value)

## The ending angle of the arc of the shape that is created, in degrees.
## [br][br][b]Note[/b]: This property's value depends on [member arc_start_degrees] and [member arc_angle_degrees],
## and setting this property will affect [member arc_angle_degrees].
var arc_end_degrees : float:
	get: return rad_to_deg(arc_end)
	set(value): arc_end = deg_to_rad(value)

## Methods for closing an open shape.
enum ClosingMethod {
	## Shape is closed with two lines between the ends and the center of the shape.
	SLICE = 0,
	## Shape is closed by connected the 2 ends together directly.
	CHORD,
	## Shape is left open. This only has an effect for ring shapes, and is otherwise equivalent to [enum ClosingStrategy].SLICE.
	ARC,
}

## The method for closing an open shape. See [enum ClosingMethod].
@export
var closing_method : ClosingMethod = ClosingMethod.SLICE:
	set(value):
		closing_method = value
		update_configuration_warnings()
		queue_regenerate()

## Toggles rounding the corners cut out by [member arc_angle].
@export
var round_arc_ends : bool = false:
	set(value):
		round_arc_ends = value
		queue_regenerate()

@export_subgroup("Offset tranform", "offset")

## The offset postition of the shape
@export
var offset_position := Vector2.ZERO:
	set(value):
		offset_position = value
		queue_regenerate()

## The offset rotation of the shape, in radians.
@export_range(-360, 360, 0.1, "or_greater", "or_less", "radians")
var offset_rotation : float = 0:
	set(value):
		offset_rotation = value
		queue_regenerate()

## The offset rotation of the shape, in degrees.
var offset_rotation_degrees : float = 0:
	set(value):
		offset_rotation = deg_to_rad(value)
	get:
		return rad_to_deg(offset_rotation)

## The offset scale of the shape.
@export
var offset_scale := Vector2.ONE:
	set(value):
		offset_scale = value
		queue_regenerate()

## The offset skew of the shape
@export_range(-89.9, 89.9, 0.1, "radians")
var offset_skew := 0.0:
	set(value):
		offset_skew = value
		queue_regenerate()

## The offset [Transform2D] of the shape.
var offset_transform := Transform2D.IDENTITY:
	get: return Transform2D(offset_rotation, offset_scale, offset_skew, offset_position)
	set(value):
		offset_rotation = value.get_rotation()
		offset_position = value.get_origin()
		offset_skew = value.get_skew()
		offset_scale = value.get_scale()

@export_group("Drawing")

## Toggles drawing the created shape.
@export
var draw_shape := true:
	set(value):
		draw_shape = value
		update_configuration_warnings()
		queue_redraw()

## Toggles drawing a border around a [enum ShapeType].POLYGON.
## [br][br]If the shape is a line, this property changes which color property is used; [member color] if [code]false[/code], [member border_color] if [code]true[/code].
@export
var draw_border := false:
	set(value):
		draw_border = value
		queue_redraw()

## The width of the drawn border, if the shape is a [enum ShapeType].POLYGON and [member draw_border] is [code]true[/code].
## The width of the drawn shape, if the shape is a line. If set to a value of [code]0[/code], two-point thin lines are drawn.
@export_range(0, 10, 0.001, "or_greater", "hide_slider")
var border_width : float = 0.0:
	set(value):
		assert(value >= 0, "property 'border_width' must be at least 0.")
		border_width = value
		queue_redraw()

## The color of the drawn shape.
@export
var color : Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

## The color of the border of the shape, and for a line shape if [member draw_border] is [code]true[/code].
@export
var border_color := Color.BLACK:
	set(value):
		border_color = value
		queue_redraw()

@export_group("Exporting")

## Toggles the setting of [member export_targets] when exporting the shape with [method export],
## and whether to do so in editor and/or at runtime. See [enum ExportBehavior] for exact values to use.
@export_flags("Editor:1", "Runtime:2")
var export_behavior : int = ExportBehavior.DISABLED:
	set(value):
		var was_exporting := can_export()
		export_behavior = value
		if not was_exporting and can_export():
			queue_export()

## When the [BasicPolygon2D] should set the [member export_targets].
enum ExportBehavior {
	## Never export the shape.
	DISABLED = 0,
	## Export while in the editor. Useful to preview the shape in other nodes, or if the set properties are serialized.
	EDITOR = 1,
	## Export while the game is running.
	RUN_TIME = 2,
}

## Toggles setting the [member export_targets] with the decomposed convex hulls of the created shape, instead of the shape itself.
## If [code]true[/code], the set value will be of type [Array][lb][PackedVector2Array][rb], and type [PackedVector2Array] otherwise.
@export
var export_as_decomposed_hulls := false

## Toggles automatically freeing itself after exporting for the first time at runtime.
@export
var auto_free := false

@export_group("Exporting", "export")

## The properties to set with the created shape when exporting. See description of [NodePath] for how to reference a (sub) property.
## [br][br]Requires [method can_export] to return [code]true[/code] for these properties to be set.
## The type of the set value depends on [member export_as_decomposed_hulls].
@export
var export_targets : Array[NodePath] = []:
	set(value):
		if value == null:
			return
		export_targets = value
		update_configuration_warnings()

# for the purposes of c# interop, which cannot set typed arrays as of Godot v4.2 as the type isn't stored when interopping.
func _set_export_targets(array : Array) -> void:
	if array.is_same_typed(export_targets):
		export_targets = array
	if array.is_empty():
		export_targets = []

	var targets : Array[NodePath] = []
	for value in array:
		assert(typeof(value) == TYPE_NODE_PATH or typeof(value) == TYPE_STRING, "cannot convert %s from %s into a NodePath" % [value, array])
		targets.push_back(value as NodePath)

	export_targets = targets

## Emitted when a shape is exported.
signal shape_exported(shape : PackedVector2Array, decomposed_shape : Array[PackedVector2Array], shape_type : ShapeType)

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

# PackedFloat64Arrays don't play well with reverts when exported in Godot 4.2, so this is required
func _property_can_revert(property: StringName) -> bool: return property == &"sizes"
func _property_get_revert(_property: StringName) -> Variant: return PackedFloat64Array([10.0])

## Returns [code]true[/code] when [member export_targets] will be set on [method export]. This is the case when
## [member export_behavior] has the flag of [enum ExportBehavior] set which corrosponds to where this [BasicPolygon2D] is running, in editor or at runtime.
## [br][br][b]Note:[/b] [signal shape_exported] is emitted on [method export] regardless of this methods return value.
func can_export() -> bool:
	var in_editor := Engine.is_editor_hint()
	return in_editor and (export_behavior & ExportBehavior.EDITOR) > 0 or not in_editor and (export_behavior & ExportBehavior.RUN_TIME) > 0

## Gets the created shape.
## [br][br][b]Note[/b]: The returned value is [b]Not[/b] a copy, and modifications to it will persist for all future consumers until the shape is regenerated.
func get_created_shape() -> PackedVector2Array: return _created_shape
## Gets the created shape, decomposed into convex hulls.
## [br][br][b]Note[/b]: The returned value is [b]Not[/b] a copy, and modifications to it will persist for all future consumers until the shape is regenerated.
func get_created_shape_decomposed() -> Array[PackedVector2Array]: return _decomposed_created_shape

## The type of shape created.
enum ShapeType {
	## The shape is a polygon.
	POLYGON = 0,
	## The shape is a line, where each point is connected to the previous and next points, leading to interconnected lines.
	## The first and last points are not connected.
	POLYLINE,
	## The shape is a line, where points come in pairs representing individual, potentially unconnected lines.
	MULTILINE,
}

## Gets the type of shape created by this [BasicPolygon2D]. See [enum ShapeType].
func get_created_shape_type() -> ShapeType:
	if vertices_count == 2: return ShapeType.MULTILINE
	if is_zero_approx(ring_ratio) or _created_shape.size() == 2: return ShapeType.POLYLINE
	return ShapeType.POLYGON

const _UNQUEUED         := 0
const _QUEUE_DISPERSE   := 1
const _QUEUE_REGENERATE := 2

var _queue_status : int = _UNQUEUED

func _init() -> void:
	queue_regenerate()

func _find_tree() -> SceneTree:
	if is_inside_tree():
		return get_tree()
	assert(Engine.get_main_loop() is SceneTree, "'queue_regenerate' and 'queue_export' functions only work if the current main loop implementation of the engine is a SceneTree")
	return Engine.get_main_loop() as SceneTree

## Queue the [BasicPolygon2D] to regenerate and export the shape. Called when the Generation properties are modified.
## Multiple calls will be converted to a single call. See [method regenerate].
## Removes queued [method queue_export] calls.
func queue_regenerate() -> void:
	if _queue_status >= _QUEUE_REGENERATE:
		return

	_queue_status = _QUEUE_REGENERATE

	await _find_tree().process_frame
	if _queue_status != _QUEUE_REGENERATE:
		return

	regenerate()

## Instantly regenerates the shape, than [method export]s it.
## Removes queued [method queue_regenerate] and [method queue_export] calls.
func regenerate() -> void:
	_queue_status = _UNQUEUED

	var shape : PackedVector2Array
	var decomposed_shape : Array[PackedVector2Array]
	var is_outline := is_zero_approx(ring_ratio)
	var is_ring_shape :=  not is_outline and ring_ratio < 1
	var uses_arc := not is_equal_approx(arc_angle, TAU)
	var rounded_corners :=        not is_zero_approx(corner_size)
	var true_corner_detail := corner_detail if corner_detail != 0 else maxi(1, 32 / vertices_count if vertices_count > 1 else 1)

	if is_zero_approx(arc_angle):
		_queue_status = _QUEUE_DISPERSE
		_created_shape = []
		_decomposed_created_shape = []
		export()
		return

	if vertices_count == 2:
		var line_count := sizes.size()
		var side_chord_arc_angle := TAU / line_count
		var line_arc_start := ceilf(arc_start / side_chord_arc_angle) * side_chord_arc_angle
		var line_arc_end := floorf(arc_end / side_chord_arc_angle) * side_chord_arc_angle

		if line_arc_start > line_arc_end:
			_queue_status = _QUEUE_DISPERSE
			_created_shape = []
			_decomposed_created_shape = []
			export()
			return

		if sizes.size() == 1:
			shape = PackedVector2Array([BasicGeometry2D._circle_point(line_arc_start + offset_rotation) * sizes[0], offset_position])
		elif is_equal_approx(line_arc_start, line_arc_end):
			shape = PackedVector2Array([BasicGeometry2D._circle_point(line_arc_start + offset_rotation) * sizes[((line_arc_start / side_chord_arc_angle) as int) % line_count], offset_position])
		else:
			shape = BasicGeometry2D.create_shape(line_count, sizes, offset_transform, line_arc_start, line_arc_end, false)
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
	shape = BasicGeometry2D.create_shape(vertices_count, sizes, offset_transform, arc_start, arc_end, add_central_point)

	if rounded_corners and shape.size() >= 3:
		if not uses_arc:
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_detail)
		elif not round_arc_ends or round_arc_ends and closing_method == ClosingMethod.ARC and is_outline:
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_detail, 1, shape.size() - (3 if add_central_point else 2))
		elif closing_method == ClosingMethod.SLICE:
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_detail, 0, shape.size() - 1)
		elif closing_method == ClosingMethod.CHORD:
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_detail)
		elif closing_method == ClosingMethod.ARC and is_equal_approx(ring_ratio, 1):
			BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_detail, 0, shape.size() - 1)

	if is_ring_shape:
		if not uses_arc or closing_method != ClosingMethod.SLICE:
			BasicGeometry2D.add_ring(shape, ring_ratio, offset_position, not uses_arc or closing_method == ClosingMethod.CHORD)
		else: # uses_arc and closing_strategy == ClosingStrategy.SLICE
			var arc_change := minf(TAU - arc_angle, -TAU * ring_ratio * (1 - arc_angle / TAU) / 4)
			var inner_arc_start := arc_start - arc_change / 2
			var inner_arc_end := arc_end + arc_change / 2
			if inner_arc_start < inner_arc_end:
				var inner_ring := BasicGeometry2D.create_shape(vertices_count, sizes, offset_transform, inner_arc_start, inner_arc_end, false)
				if is_equal_approx(inner_arc_end - inner_arc_start, TAU):
					inner_ring.push_back(inner_ring[0])

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

					BasicGeometry2D.add_rounded_corners(shape, inner_corner_size, true_corner_detail, inner_start, inner_length, false)

	if rounded_corners and uses_arc and closing_method == ClosingMethod.ARC and round_arc_ends and is_ring_shape:
		var inner_corner_size := lerpf(corner_size, 0, ring_ratio)
		var original_size := shape.size()

		BasicGeometry2D.add_rounded_corners(shape, inner_corner_size, true_corner_detail, original_size / 2, original_size / 2)
		BasicGeometry2D.add_rounded_corners(shape, corner_size, true_corner_detail, 0, original_size / 2, false)

	if is_outline or shape.size() == 2:
		if (not uses_arc or closing_method != ClosingMethod.ARC) and shape.size() != 2:
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

## Queue the [BasicPolygon2D] to export the shape. Multiple calls will be converted to a single call.
func queue_export() -> void:
	if _queue_status >= _QUEUE_DISPERSE:
		return

	_queue_status = _QUEUE_DISPERSE

	await _find_tree().process_frame
	if _queue_status != _QUEUE_DISPERSE:
		return

	export()

## Instantly exports the previously created shape, emitting [signal shape_exported],
## as well as setting the export properties if [method can_export] returns [code]true[/code].
## Removes queued [method queue_regenerate] and [method queue_export] calls.
func export() -> void:
	_queue_status = _UNQUEUED

	shape_exported.emit(_created_shape, _decomposed_created_shape, get_created_shape_type())
	if can_export():
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

	if absf(arc_angle) <= PI and ring_ratio < 1 and ring_ratio > 0 and closing_method == ClosingMethod.CHORD:
		warnings.push_back("A ring shape polygon that is closed as a chord with an arc angle less than or equal to 180º will not be a valid shape for the purposes of drawing and the like.")

	if vertices_count == 2 and not is_zero_approx(arc_angle):
		var line_count := maxi(sizes.size(), 2)
		var side_chord_arc_angle := TAU / line_count
		var line_arc_start := ceilf(arc_start / side_chord_arc_angle) * side_chord_arc_angle
		var line_arc_end := floorf(arc_end / side_chord_arc_angle) * side_chord_arc_angle
		if line_arc_start > line_arc_end:
			warnings.push_back("The arc of the shape covers an area where no lines are, so nothing will be created")

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

	if is_zero_approx(arc_angle) or is_zero_approx(_created_shape.size()):
		return

	if absf(arc_angle) <= PI and ring_ratio < 1 and ring_ratio > 0 and closing_method == ClosingMethod.CHORD:
		return

	match get_created_shape_type():
		ShapeType.POLYGON:
			if draw_border:
				if ring_ratio < 1 and (is_equal_approx(arc_angle, TAU) or closing_method == ClosingMethod.CHORD):
					assert(_created_shape.size() % 2 == 0)
					var border_line := _created_shape.slice(0, _created_shape.size() / 2)
					draw_polyline(border_line, border_color, border_width)

					for i in border_line.size():
						border_line[i] = _created_shape[-i - 1]
					draw_polyline(border_line, border_color, border_width)
				elif is_zero_approx(border_width):
					draw_polyline(_created_shape, border_color)
					draw_line(_created_shape[-1], _created_shape[0], border_color)
				elif ring_ratio < 1 and arc_angle < TAU and closing_method == ClosingMethod.SLICE and _created_shape.size() > 3:
					var split := _created_shape.find(offset_position)
					assert(split != -1)

					var border_line := _created_shape.slice(0, split + 1)
					border_line.push_back(border_line[0])
					draw_polyline(border_line, border_color, border_width)
					border_line = _created_shape.slice(split)
					draw_polyline(border_line, border_color, border_width)

				else:
					var border_line := _created_shape.duplicate()
					border_line.push_back(_created_shape[0])
					draw_polyline(border_line, border_color, border_width)

			for hull in _decomposed_created_shape:
				draw_colored_polygon(hull, color)
		ShapeType.POLYLINE:
			draw_polyline(_created_shape, border_color if draw_border else color, border_width if border_width > 0 else -1)
		ShapeType.MULTILINE:
			draw_multiline(_created_shape, border_color if draw_border else color, border_width if border_width > 0 else -1)
		_:
			assert(false, "unexpected match case: %s" % get_created_shape_type())
