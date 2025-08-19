using System;
using Godot;

namespace SimplifiedShapeCreation.MemberNames;

/// <summary>
/// Cached StringNames for the properties and fields contained in the nodes of the SimplifiedShapeCreation plugin, for fast lookup.
/// </summary>
public static class PropertyName
{
    public static readonly StringName Disabled = new("disabled");
    public static readonly StringName OneWayCollision = new("one_way_collision");
    public static readonly StringName OneWayCollisionMargin = new("one_way_collision_margin");
    public static readonly StringName VerticesCount = new("vertices_count");
    [Obsolete("Property name has been replaced, use 'Sizes' instead.", true)]
    public static readonly StringName Size = new("size");
    public static readonly StringName Sizes = new("sizes");
    public static readonly StringName OffsetRotationDegrees = new("offset_rotation_degrees");
    public static readonly StringName OffsetRotation = new("offset_rotation");
    public static readonly StringName OffsetScale = new("offset_scale");
    public static readonly StringName OffsetSkew = new("offset_skew");
    public static readonly StringName OffsetTransform = new("offset_transform");
    public static readonly StringName Color = new("color");
    public static readonly StringName OffsetPosition = new("offset_position");
    [Obsolete("Property name has been replaced, use 'OffsetPosition' instead.", true)]
    public static readonly StringName Offset = new("offset");
    public static readonly StringName RingRatio = new("ring_ratio");
    public static readonly StringName ArcStart = new("arc_start");
    public static readonly StringName ArcAngle = new("arc_angle");
    public static readonly StringName ArcEnd = new("arc_end");
    public static readonly StringName ArcStartDegrees = new("arc_start_degrees");
    public static readonly StringName ArcAngleDegrees = new("arc_angle_degrees");
    public static readonly StringName ArcEndDegrees = new("arc_end_degrees");
    public static readonly StringName CornerSize = new("corner_size");
    public static readonly StringName CornerDetail = new("corner_detail");
    public static readonly StringName ClosingMethod = new("closing_method");
    public static readonly StringName RoundArcEnds = new("round_arc_ends");
    public static readonly StringName DrawShape = new("draw_shape");
    public static readonly StringName DrawBorder = new("draw_border");
    public static readonly StringName BorderWidth = new("border_width");
    public static readonly StringName BorderColor = new("border_color");
    public static readonly StringName ExportBehavior = new("export_behavior");
    public static readonly StringName ExportAsDecomposedHulls = new("export_as_decomposed_hulls");
    public static readonly StringName AutoFree = new("auto_free");
    public static readonly StringName ExportTargets = new("export_targets");
    [Obsolete("Property name has been replaced, use 'VerticesCount' instead.", false)]
    public static readonly StringName PointCount = new("vertices_count");
    public static readonly StringName InnerSize = new("inner_size");
}
