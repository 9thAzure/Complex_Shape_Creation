using System;
using System.Diagnostics;
using Godot;
using SimplifiedShapeCreation.MemberNames;

namespace SimplifiedShapeCreation;

/// <summary>
/// A Wrapper for a <see cref="Node2D"/> which contains the script specified in <see cref="BasicPolygon2D.GDScriptEquivalent"/>.
/// It also provides ways for creating such nodes.
/// </summary>
public partial class BasicPolygon2D
{
    /// <summary>The string path to the script this class wraps around.</summary>
    public const string GDScriptEquivalentPath = "res://addons/simplified_shape_creation/basic_polygon2d/basic_polygon2d.gd";
    /// <summary>The loaded <see cref="GDScript"/> of <see cref="GDScriptEquivalentPath"/>.</summary>
    public static readonly GDScript GDScriptEquivalent = GD.Load<GDScript>(GDScriptEquivalentPath);

    /// <summary>The <see cref="GDScriptEquivalent"/> instance this class wraps around.</summary>
    public Node2D Instance { get; }

    public delegate void ShapeCreatedEventHandler(Vector2[] shape, Godot.Collections.Array<Vector2[]> shapeDecomposed, ShapeType shapeType);
    public event ShapeCreatedEventHandler ShapeCreated;
    /// <summary>
    /// The number of vertices in the regular shape. A value of <c>1</c> creates a circle, and a value of <c>2</c> creates a line.
    /// </summary>
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

    public bool DrawShape
    {
        get => Instance.Get(PropertyName.DrawShape).AsBool();
        set => Instance.Set(PropertyName.DrawShape, value);
    }

    public bool DrawBorder
    {
        get => Instance.Get(PropertyName.DrawBorder).AsBool();
        set => Instance.Set(PropertyName.DrawBorder, value);
    }

    public float BorderWidth
    {
        get => Instance.Get(PropertyName.BorderWidth).AsSingle();
        set => Instance.Set(PropertyName.BorderWidth, value);
    }
    /// <summary>The color of the shape.</summary>
    public Color Color
    {
        get => Instance.Get(PropertyName.Color).AsColor();
        set => Instance.Set(PropertyName.Color, value);
    }
    public Color BorderColor
    {
        get => Instance.Get(PropertyName.BorderColor).AsColor();
        set => Instance.Set(PropertyName.BorderColor, value);
    }

    public ExportBehavior ExportBehavior
    {
        get => Instance.Get(PropertyName.ExportBehavior).As<ExportBehavior>();
        set => Instance.Set(PropertyName.ExportBehavior, (int)value);
    }

    public bool ExportAsDecomposedHulls
    {
        get => Instance.Get(PropertyName.ExportAsDecomposedHulls).AsBool();
        set => Instance.Set(PropertyName.ExportAsDecomposedHulls, value);
    }

    public bool AutoFree
    {
        get => Instance.Get(PropertyName.AutoFree).AsBool();
        set => Instance.Set(PropertyName.AutoFree, value);
    }

    public Godot.Collections.Array<NodePath> ExportTargets
    {
        get => Instance.Get(PropertyName.ExportTargets).AsGodotArray<NodePath>();
        set => Instance.Call(MethodName.SetExportTargets, value);
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

    public Vector2[] CreatedShape => Instance.Call(MethodName.GetCreatedShape).AsVector2Array();
    public Godot.Collections.Array<Vector2[]> CreatedShapeDecomposed => Instance.Call(MethodName.GetCreatedShapeDecomposed).AsGodotArray<Vector2[]>();
    public ShapeType CreatedShapeType => Instance.Call(MethodName.GetCreatedShapeType).As<ShapeType>();

    public bool CanExport() => Instance.Call(MethodName.CanExport).AsBool();

    public void QueueRegenerate() => Instance.Call(MethodName.QueueRegenerate);
    public void Regenerate() => Instance.Call(MethodName.Regenerate);
    public void QueueExport() => Instance.Call(MethodName.QueueExport);
    public void Export() => Instance.Call(MethodName.Export);

    // /// <summary>
    // /// Transforms <see cref="BasicPolygon2D"/>, rotating it by <paramref name="rotation"/> radians and scaling it by a factor of <paramref name="scale"/>.
    // /// </summary>
    // /// <remarks>Unlike other methods, this simply affects <see cref="OffsetRotation"/> and <see cref="Size"/>, regenerating the shape </remarks>
    // /// <param name="rotation">The amount to rotate the shape in radians.</param>
    // /// <param name="scale">The factor to scale the shape.</param>
    // public void ApplyTransformation(float rotation, float scale, bool scale_width = true, bool scale_corner_size = true) => Instance.Call(MethodName.ApplyTransformation, rotation, scale, scale_width, scale_corner_size);
    // public void ApplyTransformation(float rotation, float scale) => Instance.Call(MethodName.ApplyTransformation, rotation, scale);

    /// <inheritdoc cref="CanvasItem.QueueRedraw"/>
    public void QueueRedraw() => Instance.QueueRedraw();


    /// <summary>Creates and wraps a <see cref="BasicPolygon2D"/> around <paramref name="instance"/>.</summary>
    /// <param name="instance">The instance of <see cref="GDScriptEquivalent"/> to wrap.</param>
    /// <exception cref="ArgumentNullException"><paramref name="instance"/> is <see langword="null"/>.</exception>
    /// <exception cref="ArgumentException"><paramref name="instance"/> isn't a instance of <see cref="GDScriptEquivalent"/>.</exception>
    public BasicPolygon2D(Node2D instance)
    {
        if (instance is null)
            throw new ArgumentNullException(nameof(instance));
        if (GDScriptEquivalent != instance.GetScript().As<GDScript>())
            throw new ArgumentException($"must have attached script '{GDScriptEquivalentPath}'.", nameof(instance));

        Instance = instance;
        instance.Connect(SignalName.ShapeCreated, Callable.From<Vector2[], Godot.Collections.Array<Vector2[]>, ShapeType>((shape, decomposed, type) => ShapeCreated?.Invoke(shape, decomposed, type)));
    }
    /// <inheritdoc cref="New"/>
    /// <summary>Creates an instance of <see cref="GDScriptEquivalent"/> wrapped by a new <see cref="BasicPolygon2D"/>.</summary>
    /// <remarks>See also: <seealso cref="New"/>.</remarks>
    public BasicPolygon2D(int verticesCount = 1, float size = 10, float offsetRotation = 0, Color? color = default, Vector2 offsetPosition = default)
    {
        Instance = BasicPolygon2D.New(verticesCount, size, offsetRotation, color, offsetPosition);
    }
    /// <inheritdoc cref="GetShapeVertices"/>
    /// <summary>Creates an instance of <see cref="GDScriptEquivalent"/> with the specified parameters.</summary>
    /// <param name="verticesCount">The number of vertices in the shape. A <c>1</c> draws a circle, a <c>2</c> draws a line.</param>
    /// <param name="color">The color of the shape.</param>
    public static Node2D New(int verticesCount = 1, float size = 10, float offsetRotation = 0, Color? color = default, Vector2 offsetPosition = default)
    {
        Debug.Assert(GDScriptEquivalent is not null);
        color ??= Colors.White;
        return GDScriptEquivalent.New(verticesCount, size, offsetRotation, color.Value, offsetPosition).As<Node2D>();
    }

    // /// <summary>Returns an array of <see cref="Vector2"/>s with the points for the shape with the specified <paramref name="verticesCount"/>.</summary>
    // /// <param name="verticesCount">The number of vertices in the shape. If it is <c>1</c>, a value of <c>32</c> is used.</param>
    // /// <param name="size">The distance each corner vertices is from the center.</param>
    // /// <param name="offsetRotation">The rotation applied to the shape.</param>
    // /// <param name="offsetPosition">The center of the shape.</param>
    // public static Vector2[] GetShapeVertices(int verticesCount, float size = 1, float offsetRotation = 0, Vector2 offsetPosition = default)
    // => _shared.Value.Call(MethodName.GetShapeVertices, verticesCount, size, offsetRotation, offsetPosition).As<Vector2[]>();

    public static implicit operator Node2D(BasicPolygon2D instance) => instance.Instance;
    public static explicit operator BasicPolygon2D(Node2D instance) => new(instance);
}
