using System;
using Godot;
using RegularPolygons2D.MemberNames;

namespace RegularPolygons2D;

public partial class SimplePolygon2D
{
    public const string GDScriptEquivalentPath = "res://addons/2d_regular_polygons/simple_polygon_2d";
    public static readonly GDScript GDScriptEquivalent = GD.Load<GDScript>(GDScriptEquivalentPath);
    private static readonly Lazy<Node2D> _shared = new(() => GDScriptEquivalent.New().As<Node2D>());
    public Node2D Instance { get; }

    public long VerticesCount
    {
        get => (long)Instance.Get(PropertyName.VerticesCount);
        set => Instance.Set(PropertyName.VerticesCount, value);
    }
    public double Size
    {
        get => (double)Instance.Get(PropertyName.Size);
        set => Instance.Set(PropertyName.Size, value);
    }
    public double OffsetRotationDegrees
    {
        get => (double)Instance.Get(PropertyName.OffsetRotationDegrees);
        set => Instance.Set(PropertyName.OffsetRotationDegrees, value);
    }
    public double OffsetRotation
    {
        get => (double)Instance.Get(PropertyName.OffsetRotation);
        set => Instance.Set(PropertyName.OffsetRotation, value);
    }
    public Color Color
    {
        get => (Color)Instance.Get(PropertyName.Color);
        set => Instance.Set(PropertyName.Color, value);
    }
    public Vector2 OffsetPosition
    {
        get => (Vector2)Instance.Get(PropertyName.OffsetPosition);
        set => Instance.Set(PropertyName.OffsetPosition, value);
    }

    public SimplePolygon2D(Node2D instance)
    {
        if (instance is null)
            throw new ArgumentNullException(nameof(instance));
        if (GDScriptEquivalent != instance.GetScript().As<GDScript>())
            throw new ArgumentException($"must have attached script '{GDScriptEquivalentPath}'.", nameof(instance));

        Instance = instance;
    }
    public SimplePolygon2D(long verticesCount = 1, double size = 10, double offsetRotation = 0, Color? color = default, Vector2 offsetPosition = default)
    {
        Instance = New(VerticesCount, size, offsetRotation, color, offsetPosition);
    }
    public static Node2D New(long verticesCount = 1, double size = 10, double offsetRotation = 0, Color? color = default, Vector2 offsetPosition = default)
    {
        if (color is null)
        {
            color = Colors.White;
        }
        return (Node2D)GDScriptEquivalent.New(verticesCount, size, offsetRotation, color.Value, offsetPosition);
    }

    public static Vector2[] GetShapeVertices(long verticesCount, double size = 1, double offsetRotation = 0, Vector2 offsetPosition = default)
    => _shared.Value.Call(MethodNames.GetShapeVertices, verticesCount, size, offsetRotation, offsetPosition).As<Vector2[]>();

    public static implicit operator Node2D(SimplePolygon2D instance) => instance.Instance;
    public static explicit operator SimplePolygon2D(Node2D instance) => new SimplePolygon2D(instance);
}
