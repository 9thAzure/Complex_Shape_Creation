using System;
using System.Diagnostics;
using Godot;
using RegularPolygons2D.MemberNames;

namespace RegularPolygons2D;

public class RegularCollisionPolygon2D
{
    public const string GDScriptEquivalentPath = "res://addons/2d_regular_polygons/regular_collision_polygon_2d.gd";
    public static readonly GDScript GDScriptEquivalent = GD.Load<GDScript>(GDScriptEquivalentPath);

    public CollisionShape2D Instance { get; }

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
    /// and value greater than <see cref="size"/> also ignores this effect while still using [member Polygon2D.polygon].
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
    /// [br][br]A value of <c>0</c> makes the node not draw anything.
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
    /// <remarks>A value of <c>0</c> will use a value of <c>32</c> divided by <see cref="verticesCount"/>.</remarks>
    public long CornerSmoothness
    {
        get => (long)Instance.Get(PropertyName.CornerSmoothness);
        set => Instance.Set(PropertyName.CornerSmoothness, value);
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

    public RegularCollisionPolygon2D(CollisionShape2D instance)
    {
        if (instance is null)
            throw new ArgumentNullException(nameof(instance));
        if (GDScriptEquivalent != instance.GetScript().As<GDScript>())
            throw new ArgumentException($"must have attached script '{GDScriptEquivalentPath}'.", nameof(instance));

        Instance = instance;
    }
    public RegularCollisionPolygon2D(long verticesCount = 1, double size = 10, double offsetRotation = 0, Vector2 offsetPosition = default,
        double width = 0, double drawnArc = Math.Tau, double cornerSize = 0, long cornerSmoothness = 0)
    => Instance = RegularCollisionPolygon2D.New(verticesCount, size, offsetRotation, offsetPosition, width, drawnArc, cornerSize, cornerSmoothness);

    public static CollisionShape2D New(long verticesCount = 1, double size = 10, double offsetRotation = 0, Vector2 offsetPosition = default,
        double width = 0, double drawnArc = Math.Tau, double cornerSize = 0, long cornerSmoothness = 0)
        => GDScriptEquivalent.New(verticesCount, size, offsetRotation, offsetPosition, width, drawnArc, cornerSize, cornerSmoothness).As<CollisionShape2D>();

    public void QueueRegenerate()
    => Instance.Call(MethodNames.QueueRegenerate);

    public void Regenerate()
    => Instance.Call(MethodNames.Regenerate);
}
