using System;
using System.Diagnostics;
using Godot;
using RegularPolygons2D.MemberNames;

namespace RegularPolygons2D;

public class RegularPolygon2D
{
    /// <inheritdoc cref="SimplePolygon2D.GDScriptEquivalentPath"/>
    public const string GDScriptEquivalentPath = "res://addons/2d_regular_polygons/regular_polygon_2d.gd";
    /// <summary>The loaded <see cref="GDScript"/> of <see cref="GDScriptEquivalentPath"/>.</summary>
    public static readonly GDScript GDScriptEquivalent = GD.Load<GDScript>(GDScriptEquivalentPath);
    private static readonly Lazy<Polygon2D> _shared = new(() => GDScriptEquivalent.New().As<Polygon2D>());

    /// <summary>The <see cref="GDScriptEquivalent"/> instance this class wraps around.</summary>
    public Polygon2D Instance { get; }
    
    /// <inheritdoc cref="SimplePolygon2D.VerticesCount"/>
    public long VerticesCount
    {
        get => (long)Instance.Get(PropertyName.VerticesCount);
        set => Instance.Set(PropertyName.VerticesCount, value);
    }
    /// <inheritdoc cref="SimplePolygon2D.Size"/>
    public double Size
    {
        get => (double)Instance.Get(PropertyName.Size);
        set => Instance.Set(PropertyName.Size, value);
    }
    /// <inherit doc cref="SimplePolygon2D.OffsetRotationDegrees"/>
    public double OffsetRotationDegrees
    {
        get => (double)Instance.Get(PropertyName.OffsetRotationDegrees);
        set => Instance.Set(PropertyName.OffsetRotationDegrees, value);
    }
    /// <inherit doc cref="SimplePolygon2D.OffsetRotation"/>
    public double OffsetRotation
    {
        get => (double)Instance.Get(PropertyName.OffsetRotation);
        set => Instance.Set(PropertyName.OffsetRotation, value);
    }
    /// <summary>Determines the width of the shape and whether is uses Draw* methods or <see cref="Polygon2D.Polygon"/>.</summary>
    /// <remarks>
    /// Determines the width of the shape. A value of <c>0</c> outlines the shape with lines, and a value smaller than <c>0</c> ignores this effect.
    /// Values greater than <c>0</c> will have <see cref="Polygon2D.Polygon"/> used,
    /// and value greater than [member size] also ignores this effect while still using [member Polygon2D.polygon].
    /// [br][br]A value between <c>0</c> and <c>0.01</c> is converted to <c>0</c>, to make it easier to select it in the inspector.
    /// </remarks>
    public double Width
    {
        get => (double)Instance.Get(PropertyName.Width);
        set => Instance.Set(PropertyName.Width, value);
    }
    /// <summary>The arc of the drawn shape, in degrees, cutting off beyond that arc.</summary>
    /// <remarks>
    /// Values greater than <c>360</c> or <c>-360</c> draws a full shape. It starts in the middle of the base of the shapes. 
    /// The direction of the arc is clockwise with positive values and counterclockwise with negative values.
    /// [br][br]A value of <c>0</c> makes the node not draw anything.
    /// </remarks>
    public double DrawnArcDegrees
    {
        get => (double)Instance.Get(PropertyName.DrawnArcDegrees);
        set => Instance.Set(PropertyName.DrawnArcDegrees, value);
    }
    /// <summary>The arc of the drawn shape, radians, cutting off beyond that arc.</summary>
    /// <remarks>
    /// Values greater than [constant @GDScript.TAU] or -[constant @GDScript.TAU] draws a full shape. It starts in the middle of the base of the shapes. 
    /// The direction of the arc is clockwise with positive values and counterclockwise with negative values.
    /// [br][br]A value of <c>0</c> makes the node not draw anything.
    /// </remarks>
    public double DrawnArc
    {
        get => (double)Instance.Get(PropertyName.DrawnArc);
        set => Instance.Set(PropertyName.DrawnArc, value);
    }

    /// <summary>The distance from each vertex along the edge to the point where the rounded corner starts.</summary>
    /// <remarks>If this value is over half of the edge length, the mid-point of the edge is used instead.</remarks>
    public double CornerSize
    {
        get => (double)Instance.Get(PropertyName.CornerSize);
        set => Instance.Set(PropertyName.CornerSize, value);
    }
    /// <summary>How many lines make up each corner</summary>
    /// <remarks>A value of <c>0</c> will use a value of <c>32</c> divided by [member vertices_count].</remarks>
    public long CornerSmoothness
    {
        get => (long)Instance.Get(PropertyName.CornerSmoothness);
        set => Instance.Set(PropertyName.CornerSmoothness, value);
    }
    /// <inherit doc cref="SimplePolygon2D.Color"/>
    public Color Color
    {
        get => Instance.Color;
        set => Instance.Color = value;
    }
    /// <inherit doc cref="SimplePolygon2D.OffsetPosition"/>
    public Vector2 OffsetPosition
    {
        get => Instance.Offset;
        set => Instance.Offset = value;
    }
    /// <inherit doc cref="SimplePolygon2D.Position"/>
    public Vector2 Position
    {
        get => Instance.Position; 
        set => Instance.Position = value;
    }
    /// <inherit doc cref="SimplePolygon2D.Rotation"/>
    public float Rotation
    {
        get => Instance.Rotation;
        set => Instance.Rotation = value;
    }
    /// <inherit doc cref="SimplePolygon2D.RotationDegrees"/>
    public float RotationDegrees
    {
        get => Instance.RotationDegrees;
        set => Instance.RotationDegrees = value;
    }
    /// <inherit doc cref="SimplePolygon2D.Scale"/>
    public Vector2 Scale
    {
        get => Instance.Scale;
        set => Instance.Scale = value;
    }

    public RegularPolygon2D(Polygon2D instance)
    {
        if (instance is null)
            throw new ArgumentNullException(nameof(instance));
        if (GDScriptEquivalent != instance.GetScript().As<GDScript>())
            throw new ArgumentException($"must have attached script '{GDScriptEquivalentPath}'.", nameof(instance));

        Instance = instance;
    }
    public RegularPolygon2D(long verticesCount = 1, double size = 10, double offsetRotation = 0, Color? color = default, Vector2 offsetPosition = default,
        double width = -0.001, double drawnArc = Math.Tau, double cornerSize = 0, long cornerSmoothness = 0)
    {
        Instance = RegularPolygon2D.New(verticesCount, size, offsetRotation, color, offsetPosition,
            width, drawnArc, cornerSize, cornerSmoothness);
    }
    public static Polygon2D New(long verticesCount = 1, double size = 10, double offsetRotation = 0, Color? color = default, Vector2 offsetPosition = default,
        double width = -0.001, double drawnArc = Math.Tau, double cornerSize = 0, long cornerSmoothness = 0)
    {
        Debug.Assert(GDScriptEquivalent is not null);
        if (color is null)
        {
            color = Colors.White;
        }
        return (Polygon2D)GDScriptEquivalent.New(verticesCount, size, offsetRotation, color.Value, offsetPosition, 
            width, drawnArc, cornerSize, cornerSmoothness);
    }

    public static Vector2[] GetShapeVertices(long verticesCount, double size = 1, double offsetRotation = 0, Vector2 offsetPosition = default,
       double drawnArc = Math.Tau, bool addCentralPoint = true)
    => _shared.Value.Call(MethodNames.GetShapeVertices, verticesCount, size, offsetRotation, offsetPosition, drawnArc, addCentralPoint).AsVector2Array();
    public static Vector2 QuadraticBezierInterpolate(Vector2 start, Vector2 control, Vector2 end)
    => _shared.Value.Call(MethodNames.QuadraticBezierInterpolate, start, control, end).AsVector2();
    public static Vector2[] AddRoundedCorners(Vector2[] points, double cornerSize, long cornerSmoothness)
    => _shared.Value.Call(MethodNames.AddRoundedCorners, points, cornerSize, cornerSmoothness).AsVector2Array();
    public static Vector2[] AddHoleToPoints(Vector2[] points, double holeScaler, bool closeShape = true)
    => _shared.Value.Call(MethodNames.AddHoleToPoints, points, holeScaler, closeShape).AsVector2Array();

    public static implicit operator Polygon2D(RegularPolygon2D instance) => instance.Instance;
    public static explicit operator RegularPolygon2D(Polygon2D instance) => new RegularPolygon2D(instance);
}