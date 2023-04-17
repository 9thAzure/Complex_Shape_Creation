using System;
using System.Diagnostics;
using Godot;
using RegularPolygons2D.MemberNames;

namespace RegularPolygons2D;

/// <summary>
/// A Wrapper for a <see cref="Polygon2D"/> which contains the script specified in <see cref="GDScriptEquivalent"/>.
/// It also provides ways for creating such nodes.
/// </summary>
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
    /// A value of <c>0</c> outlines the shape with lines, and a value smaller than <c>0</c> ignores this effect.
    /// Values greater than <c>0</c> will have <see cref="Polygon2D.Polygon"/> used,
    /// and value greater than <see cref="size"/> also ignores this effect while still using <see cref="Polygon2D.Polygon"/>.
    /// A value between <c>0</c> and <c>0.01</c> is converted to <c>0</c>, to make it easier to select it in the inspector.
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
    /// A value of <c>0</c> makes the node not draw anything.
    /// </remarks>
    public double DrawnArcDegrees
    {
        get => (double)Instance.Get(PropertyName.DrawnArcDegrees);
        set => Instance.Set(PropertyName.DrawnArcDegrees, value);
    }
    /// <summary>The arc of the drawn shape, radians, cutting off beyond that arc.</summary>
    /// <remarks>
    /// Values greater than <see cref="Math.Tau"/> or -<see cref="Math.Tau"/> draws a full shape. It starts in the middle of the base of the shapes. 
    /// The direction of the arc is clockwise with positive values and counterclockwise with negative values.
    /// A value of <c>0</c> makes the node not draw anything.
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
    /// <remarks>A value of <c>0</c> will use a value of <c>32</c> divided by <see cref="verticesCount"/>.</remarks>
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
    
    /// <summary>Creates and wraps a <see cref="RegularPolygon2D"/> around <paramref name="instance"/>.</summary>
    /// <param name="instance">The instance of <see cref="GDScriptEquivalent"/> to wrap.</param>
    /// <exception cref="ArgumentNullException"><paramref name="instance"/> is <see langword="null"/>.</exception>
    /// <exception cref="ArgumentException"><paramref name="instance"/> isn't a instance of <see cref="GDScriptEquivalent"/>.</exception>
    public RegularPolygon2D(Polygon2D instance)
    {
        if (instance is null)
            throw new ArgumentNullException(nameof(instance));
        if (GDScriptEquivalent != instance.GetScript().As<GDScript>())
            throw new ArgumentException($"must have attached script '{GDScriptEquivalentPath}'.", nameof(instance));

        Instance = instance;
    }
    /// <inheritdoc cref="New"/>
    /// <summary>Creates an instance of <see cref="GDScriptEquivalent"/> wrapped by a new <see cref="RegularPolygon2D"/>.</summary>
    /// <remarks>See also: <seealso cref="New"/>.</remarks>
    public RegularPolygon2D(long verticesCount = 1, double size = 10, double offsetRotation = 0, Color? color = default, Vector2 offsetPosition = default,
        double width = -0.001, double drawnArc = Math.Tau, double cornerSize = 0, long cornerSmoothness = 0)
    {
        Instance = RegularPolygon2D.New(verticesCount, size, offsetRotation, color, offsetPosition,
            width, drawnArc, cornerSize, cornerSmoothness);
    }
    /// <inheritdoc cref="SimplePolygon2D.New(long, double, double, Color?, Vector2)"/>
    /// <summary>Creates an instance of <see cref="GDScriptEquivalent"/> with the specified parameters.</summary>
    /// <param name="width">The width of the shape. Negative values draw a full shape.</param>
    /// <param name="drawnArc">The drawn arc of the shape. Positive values go clockwise, negative values go counterclockwise.</param>
    /// <param name="cornerSize">The distance along each edge to the point where the corner starts.</param>
    /// <param name="cornerSmoothness">How many lines make up each corner.</param>
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

    /// <inheritdoc cref="SimplePolygon2D.GetShapeVertices(long, double, double, Vector2)"/>
    /// <summary>Returns an array of <see cref="Vector2"/>s with the points for the shape with the specified <paramref name="vertices_count"/>.</summary>
    /// <param name="addCentralPoint">
    /// <paramref name="add_central_point"/> adds <paramref name="offset_rotation"/> at the end of the array. 
    /// It only has an effect if <paramref name="drawn_arc"/> is used and isn't ±<see cref="Math.Tau"/>.
    /// It should be set to false when using <see cref="AddHoleToPoints"/>.
    /// </param>
    public static Vector2[] GetShapeVertices(long verticesCount, double size = 1, double offsetRotation = 0, Vector2 offsetPosition = default,
       double drawnArc = Math.Tau, bool addCentralPoint = true)
    => _shared.Value.Call(MethodName.GetShapeVertices, verticesCount, size, offsetRotation, offsetPosition, drawnArc, addCentralPoint).AsVector2Array();
    /// <summary>
    /// Returns the point at the given <paramref name="t"/> on the Bézier curve with the given 
    /// <paramref name="start"/>, <paramref name="end"/>, and single <paramref name="control"/> points.
    /// </summary>
    public static Vector2 QuadraticBezierInterpolate(Vector2 start, Vector2 control, Vector2 end)
    => _shared.Value.Call(MethodName.QuadraticBezierInterpolate, start, control, end).AsVector2();
    /// <summary>Returns a modified copy of <paramref name="points"/> so that the shape it represents have rounded corners. </summary>
    /// <remarks>The method uses quadratic Bézier curves for the corners (see <see cref="QuadraticBezierInterpolate"/>).</remarks>
    /// <param name="points">The array to clone and modify</param>
    /// <param name="cornerSize">The distance along each edge to the point where the corner starts.</param>
    /// <param name="cornerSmoothness">The number of lines that make up each corner.</param>
    public static Vector2[] AddRoundedCorners(Vector2[] points, double cornerSize, long cornerSmoothness)
    => _shared.Value.Call(MethodName.AddRoundedCorners, points, cornerSize, cornerSmoothness).AsVector2Array();
    /// <summary>
    /// Appends points, which are <paramref name="holeScaler"/> times the original <paramref name="points"/>, 
    /// to a clone of <paramref name="points"/>, in reverse order from <paramref name="points"/>.
    /// </summary>
    /// <remarks>This method doesn't work properly if there is an offset applied to <paramref name="points"/>.</remarks>
    /// <param name="points">The array to clone and modify.</param>
    /// <param name="holeScaler">The multiplier applied to the duplicated points.</param>
    /// <param name="closeShape">Adds the first point to the end of <paramref cref="points"/>.</param>
    public static Vector2[] AddHoleToPoints(Vector2[] points, double holeScaler, bool closeShape = true)
    => _shared.Value.Call(MethodName.AddHoleToPoints, points, holeScaler, closeShape).AsVector2Array();

    public static implicit operator Polygon2D(RegularPolygon2D instance) => instance.Instance;
    public static explicit operator RegularPolygon2D(Polygon2D instance) => new RegularPolygon2D(instance);
}
