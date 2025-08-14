using Godot;
using System;
using SimplifiedShapeCreation.MemberNames;

namespace SimplifiedShapeCreation;

public class BasicCollisionPolygon2D
{
    /// <summary>The string path to the script this class wraps around.</summary>
    public const string GDScriptEquivalentPath = "res://addons/simplified_shape_creation/basic_collision_polygon2d/basic_collision_polygon2d.gd";
    /// <summary>The loaded <see cref="GDScript"/> of <see cref="GDScriptEquivalentPath"/>.</summary>
    public static readonly GDScript GDScriptEquivalent = GD.Load<GDScript>(GDScriptEquivalentPath);

    /// <summary>The <see cref="GDScriptEquivalent"/> instance this class wraps around.</summary>
    public Node2D Instance { get; }

    public bool Disabled
    {
        get => Instance.Get(PropertyName.Disabled).AsBool();
        set => Instance.Set(PropertyName.Disabled, value);
    }

    public bool OneWayCollision
    {
        get => Instance.Get(PropertyName.OneWayCollision).AsBool();
        set => Instance.Set(PropertyName.OneWayCollision, value);
    }

    public int OneWayCollisionMargin
    {
        get => Instance.Get(PropertyName.OneWayCollisionMargin).AsInt32();
        set => Instance.Set(PropertyName.OneWayCollisionMargin, value);
    }

    public int VerticesCount
    {
        get => (int)Instance.Get(PropertyName.VerticesCount);
        set => Instance.Set(PropertyName.VerticesCount, value);
    }
    /// <summary>The length from each corner to the center of the shape.</summary>
    public double[] Sizes
    {
        get => Instance.Get(PropertyName.Sizes).AsFloat64Array();
        set => Instance.Set(PropertyName.Sizes, value);
    }
    public float RingRatio
    {
        get => Instance.Get(PropertyName.RingRatio).AsSingle();
        set => Instance.Set(PropertyName.RingRatio, value);
    }

    public float CornerSize
    {
        get => Instance.Get(PropertyName.CornerSize).AsSingle();
        set => Instance.Set(PropertyName.CornerSize, value);
    }

    public int CornerDetail
    {
        get => Instance.Get(PropertyName.CornerDetail).AsInt32();
        set => Instance.Set(PropertyName.CornerDetail, value);
    }

    public float ArcStart
    {
        get => Instance.Get(PropertyName.ArcStart).AsSingle();
        set => Instance.Set(PropertyName.ArcStart, value);
    }

    public float ArcAngle
    {
        get => Instance.Get(PropertyName.ArcAngle).AsSingle();
        set => Instance.Set(PropertyName.ArcAngle, value);
    }

    public float ArcEnd
    {
        get => Instance.Get(PropertyName.ArcEnd).AsSingle();
        set => Instance.Set(PropertyName.ArcEnd, value);
    }

    public float ArcStartDegrees
    {
        get => Instance.Get(PropertyName.ArcStartDegrees).AsSingle();
        set => Instance.Set(PropertyName.ArcStartDegrees, value);
    }

    public float ArcAngleDegrees
    {
        get => Instance.Get(PropertyName.ArcAngleDegrees).AsSingle();
        set => Instance.Set(PropertyName.ArcAngleDegrees, value);
    }

    public float ArcEndDegrees
    {
        get => Instance.Get(PropertyName.ArcEndDegrees).AsSingle();
        set => Instance.Set(PropertyName.ArcEndDegrees, value);
    }

    public ClosingMethod ClosingMethod
    {
        get => Instance.Get(PropertyName.ClosingMethod).As<ClosingMethod>();
        set => Instance.Set(PropertyName.ClosingMethod, (int)value);
    }

    public bool RoundArcEnds
    {
        get => Instance.Get(PropertyName.RoundArcEnds).AsBool();
        set => Instance.Set(PropertyName.RoundArcEnds, value);
    }

    /// <summary>The offset position of the shape.</summary>
    public Vector2 OffsetPosition
    {
        get => Instance.Get(PropertyName.OffsetPosition).AsVector2();
        set => Instance.Set(PropertyName.OffsetPosition, value);
    }
    /// <summary>The offset rotation of the shape, in degrees.</summary>
    public float OffsetRotationDegrees
    {
        get => Instance.Get(PropertyName.OffsetRotationDegrees).AsSingle();
        set => Instance.Set(PropertyName.OffsetRotationDegrees, value);
    }
    /// <summary>The offset rotation of the shape, in radians.</summary>
    public float OffsetRotation
    {
        get => Instance.Get(PropertyName.OffsetRotation).AsSingle();
        set => Instance.Set(PropertyName.OffsetRotation, value);
    }

    public Vector2 OffsetScale
    {
        get => Instance.Get(PropertyName.OffsetScale).AsVector2();
        set => Instance.Set(PropertyName.OffsetScale, value);
    }

    public float OffsetSkew
    {
        get => Instance.Get(PropertyName.OffsetSkew).AsSingle();
        set => Instance.Set(PropertyName.OffsetSkew, value);
    }

    public Transform2D OffsetTransform
    {
        get => Instance.Get(PropertyName.OffsetTransform).AsTransform2D();
        set => Instance.Set(PropertyName.OffsetTransform, value);
    }

    /// <summary>Position, relative to the node's parent.</summary>
    public Vector2 Position
    {
        get => Instance.Position;
        set => Instance.Position = value;
    }
    /// <summary>Rotation in radians, relative to the node's parent.</summary>
    public float Rotation
    {
        get => Instance.Rotation;
        set => Instance.Rotation = value;
    }
    /// <summary>Helper property to access <see cref="Node2D.Rotation"/> in degrees instead of radians.</summary>
    public float RotationDegrees
    {
        get => Instance.RotationDegrees;
        set => Instance.RotationDegrees = value;
    }
    /// <summary>The node's scale. Unscaled value: (1, 1).</summary>
    public Vector2 Scale
    {
        get => Instance.Scale;
        set => Instance.Scale = value;
    }

    public BasicPolygon2D BasicPolygon { get; private init; }
    public Vector2[] CreatedShape => Instance.Call(MethodName.GetCreatedShape).AsVector2Array();
    public Godot.Collections.Array<Vector2[]> CreatedShapeDecomposed => Instance.Call(MethodName.GetCreatedShapeDecomposed).AsGodotArray<Vector2[]>();
    public ShapeType CreatedShapeType => Instance.Call(MethodName.GetCreatedShapeType).As<ShapeType>();
    public int ShapeCount => Instance.Call(MethodName.ShapeCount).AsInt32();

    public Shape2D GetShape(int index) => Instance.Call(MethodName.GetShape, index).As<Shape2D>();

    public BasicCollisionPolygon2D(Node2D instance)
    {
        ArgumentNullException.ThrowIfNull(instance);
        if (!GDScriptEquivalent.InstanceHas(instance))
            throw new ArgumentException($"must have attached script '{GDScriptEquivalentPath}'.", nameof(instance));

        Instance = instance;
        BasicPolygon = new BasicPolygon2D(instance.Call(MethodName.GetBasicPolygon).As<Node2D>());
    }

    public BasicCollisionPolygon2D() : this(GDScriptEquivalent.New().As<Node2D>()) {}

    public static implicit operator Node2D(BasicCollisionPolygon2D node) => node.Instance;
    public static explicit operator BasicCollisionPolygon2D(Node2D node) => new(node);
}
