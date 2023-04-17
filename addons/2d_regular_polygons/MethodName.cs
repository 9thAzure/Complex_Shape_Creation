using Godot;
using System;

namespace RegularPolygons2D.MemberNames;

public static class MethodName
{
    public static readonly StringName GetShapeVertices = new("get_shape_vertices");
    public static readonly StringName DrawUsingPolygon = new("draw_using_polygon");
    public static readonly StringName UsesPolygonMember = new("uses_polygon_member");
    public static readonly StringName GetSideLength = new("get_side_length");
    /// <remarks>The signature is slightly altered from its GDScript counterpart. An array of <see cref="Vector2"/> is returned instead, and the input array isn't modified.</remarks>
    public static readonly StringName AddRoundedCorners = new("_add_rounded_corners_result");
    public static readonly StringName QuadraticBezierInterpolate = new("quadratic_bezier_interpolate");
    /// <inheritdoc cref="AddRoundedCorners"/>
    public static readonly StringName AddHoleToPoints = new("_add_hole_to_points_result");
    public static readonly StringName QueueRegenerate = new("queue_regenerate");
    public static readonly StringName Regenerate = new("regenerate");
    
}