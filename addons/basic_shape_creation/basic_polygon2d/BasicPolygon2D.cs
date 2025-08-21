using System;
using Godot;

namespace BasicShapeCreation;

/// <summary>
/// A node for creating and drawing basic shapes, acting as a simplified wrapper around <see cref="BasicGeometry2D"/>.
/// The created shape can be accessed by <see cref="CreatedShape"/>, connecting the <see cref="ShapeExported"/> signal,
/// or by using the <see cref="BasicPolygon2D"/>'s export system with <see cref="ExportTargets"/>.
/// <br/><br/>The shape is regenerated and exported whenever any of the shape properties are changed, and exported whenever any
/// of the export properties are changed and <see cref="CanExport"/> returns <see langword="true"/>.
/// </summary>
/// <remarks>
/// This class is a wrapper around an instance of a <see cref="Node2D"/> s with the <see cref="GDScript"/> at
/// "res://addons/basic_shape_creation/basic_polygon2d/basic_polygon2d.gd" attached.
/// The <see cref="Node2D"/> instance can be accessed with <see cref="Instance"/>.
/// </remarks>
public class BasicPolygon2D
{
    /// <summary>The string path to the script this class wraps around.</summary>
    public const string GDScriptEquivalentPath = "res://addons/basic_shape_creation/basic_polygon2d/basic_polygon2d.gd";
    /// <summary>The loaded <see cref="GDScript"/> of <see cref="GDScriptEquivalentPath"/>.</summary>
    public static readonly GDScript GDScriptEquivalent = GD.Load<GDScript>(GDScriptEquivalentPath);

    /// <summary>The <see cref="GDScriptEquivalent"/> instance this class wraps around.</summary>
    public Node2D Instance { get; }

    /// <summary>Emitted when a shape is exported.</summary>
    public delegate void ShapeExportedEventHandler(Vector2[] shape, Godot.Collections.Array<Vector2[]> shapeDecomposed, ShapeType shapeType);
    /// <inheritdoc cref="ShapeExportedEventHandler"/>
    public event ShapeExportedEventHandler ShapeExported;

    /// <summary>
    /// The number of vertices in the base shape.
    /// </summary>
    /// <remarks>
    /// A value of <c>1</c> creates a 32 vertices shape.
    /// A value of <c>2</c> creates multiple equidistantly spaced lines from the center, one for each value in <see cref="Sizes"/>.
    /// </remarks>
    public int VerticesCount
    {
        get => (int)Instance.Get(PropertyName.VerticesCount);
        set => Instance.Set(PropertyName.VerticesCount, value);
    }

    /// <summary>
    /// The distance from the center to each vertex, cycling through if there are multiple values.
    /// </summary>
    public double[] Sizes
    {
        get => Instance.Get(PropertyName.Sizes).AsFloat64Array();
        set => Instance.Set(PropertyName.Sizes, value);
    }

    /// <summary>The size of the ring, in proportion from the outer edge to the center.</summary>
    /// <remarks>
    /// A value of <c>1</c> creates a normal shape,
    /// a value of <c>0</c> creates a <see cref="ShapeType.Polyline"/> outline, and a negative value extends the ring outwards proportionally.
    /// </remarks>
    public float RingRatio
    {
        get => Instance.Get(PropertyName.RingRatio).AsSingle();
        set => Instance.Set(PropertyName.RingRatio, value);
    }

    /// <summary>The size of each corner, as the distance along both edges, from the original vertex, to the point where the corner starts and ends.</summary>
    public float CornerSize
    {
        get => Instance.Get(PropertyName.CornerSize).AsSingle();
        set => Instance.Set(PropertyName.CornerSize, value);
    }

    /// <summary>
    /// How many lines make up each corner. A value of <c>0</c> will use a value of <c>32</c> divided by <see cref="VerticesCount"/>.
    /// </summary>
    public int CornerDetail
    {
        get => Instance.Get(PropertyName.CornerDetail).AsInt32();
        set => Instance.Set(PropertyName.CornerDetail, value);
    }

    /// <summary> The starting angle of the arc of the shape that is created, in radians.</summary>
    public float ArcStart
    {
        get => Instance.Get(PropertyName.ArcStart).AsSingle();
        set => Instance.Set(PropertyName.ArcStart, value);
    }

    /// <summary>The angle of the arc of the shape that is created, in radians.</summary>
    public float ArcAngle
    {
        get => Instance.Get(PropertyName.ArcAngle).AsSingle();
        set => Instance.Set(PropertyName.ArcAngle, value);
    }

    /// <summary>The ending angle of the arc of the shape that is created, in radians.</summary>
    /// <remarks>
    /// This property's value depends on <see cref="ArcStart"/> and <see cref="ArcEnd"/>,
    /// and setting this property will affect <see cref="ArcAngle"/>.
    /// </remarks>
    public float ArcEnd
    {
        get => Instance.Get(PropertyName.ArcEnd).AsSingle();
        set => Instance.Set(PropertyName.ArcEnd, value);
    }


    /// <summary>The starting angle of the arc of the shape that is created, in degrees.</summary>
    public float ArcStartDegrees
    {
        get => Instance.Get(PropertyName.ArcStartDegrees).AsSingle();
        set => Instance.Set(PropertyName.ArcStartDegrees, value);
    }

    /// <summary>The angle of the arc of the shape that is created, in degrees.</summary>
    public float ArcAngleDegrees
    {
        get => Instance.Get(PropertyName.ArcAngleDegrees).AsSingle();
        set => Instance.Set(PropertyName.ArcAngleDegrees, value);
    }

    /// <summary>The ending angle of the arc of the shape that is created, in degrees.</summary>
    /// <remarks>
    /// This property's value depends on <see cref="ArcStartDegrees"/> and <see cref="ArcEndDegrees"/>,
    /// and setting this property will affect <see cref="ArcAngleDegrees"/>.
    /// </remarks>
    public float ArcEndDegrees
    {
        get => Instance.Get(PropertyName.ArcEndDegrees).AsSingle();
        set => Instance.Set(PropertyName.ArcEndDegrees, value);
    }

    /// <summary>The method for closing an open shape.</summary>
    /// <seealso cref="ClosingMethod"/>
    public ClosingMethod ClosingMethod
    {
        get => Instance.Get(PropertyName.ClosingMethod).As<ClosingMethod>();
        set => Instance.Set(PropertyName.ClosingMethod, (int)value);
    }

    /// <summary>Toggles rounding the corners cut out by <see cref="ArcAngle"/>.</summary>
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

    /// <summary>The offset scale of the shape.</summary>
    public Vector2 OffsetScale
    {
        get => Instance.Get(PropertyName.OffsetScale).AsVector2();
        set => Instance.Set(PropertyName.OffsetScale, value);
    }

    /// <summary>The offset skew of the shape</summary>
    public float OffsetSkew
    {
        get => Instance.Get(PropertyName.OffsetSkew).AsSingle();
        set => Instance.Set(PropertyName.OffsetSkew, value);
    }

    /// <summary>The offset <see cref="Transform2D"/> of the shape.</summary>
    public Transform2D OffsetTransform
    {
        get => Instance.Get(PropertyName.OffsetTransform).AsTransform2D();
        set => Instance.Set(PropertyName.OffsetTransform, value);
    }

    /// <summary>Toggles drawing the created shape.</summary>
    public bool DrawShape
    {
        get => Instance.Get(PropertyName.DrawShape).AsBool();
        set => Instance.Set(PropertyName.DrawShape, value);
    }

    /// <summary>Toggles drawing a border around a <see cref="ShapeType.Polygon"/>.</summary>
    /// <remarks>
    /// If the shape is a line, this property changes which color property is used; <see cref="Color"/> if <see langword="false"/>,
    /// <see cref="BorderColor"/> if <see langword="true"/>.
    /// </remarks>
    public bool DrawBorder
    {
        get => Instance.Get(PropertyName.DrawBorder).AsBool();
        set => Instance.Set(PropertyName.DrawBorder, value);
    }

    /// <summary>
    /// The width of the drawn border, if the shape is a <see cref="ShapeType.Polygon"/> and <see cref="DrawBorder"/> is <see langword="true"/>.
    /// The width of the drawn shape, if the shape is a line. If set to a value of <c>0</c>, two-point thin lines are drawn.
    /// </summary>
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


    /// <summary>The color of the border of the shape, and for a line shape if <see cref="DrawBorder"/> is <see langword="true"/>.</summary>
    public Color BorderColor
    {
        get => Instance.Get(PropertyName.BorderColor).AsColor();
        set => Instance.Set(PropertyName.BorderColor, value);
    }

    /// <summary>
    /// Toggles the setting of <see cref="ExportTargets"/> when exporting the shape with <see cref="Export"/>,
    /// and whether to do so in editor and/or at runtime.
    /// </summary>
    /// <seealso cref="ExportBehavior"/>
    public ExportBehavior ExportBehavior
    {
        get => Instance.Get(PropertyName.ExportBehavior).As<ExportBehavior>();
        set => Instance.Set(PropertyName.ExportBehavior, (int)value);
    }

    /// <summary>
    /// Toggles setting the <see cref="ExportTargets"/> with the decomposed convex hulls of the created shape, instead of the shape itself.
    /// If <see langword="true"/>, the set value will be of type <see cref="T:Godot.Collections.Array{Vector2[]}"/>, and type <see cref="T:Vector2[]"/> otherwise.
    /// </summary>
    public bool ExportAsDecomposedHulls
    {
        get => Instance.Get(PropertyName.ExportAsDecomposedHulls).AsBool();
        set => Instance.Set(PropertyName.ExportAsDecomposedHulls, value);
    }

    /// <summary>Toggles automatically freeing itself after exporting for the first time at runtime.</summary>
    public bool AutoFree
    {
        get => Instance.Get(PropertyName.AutoFree).AsBool();
        set => Instance.Set(PropertyName.AutoFree, value);
    }

    /// <summary>
    /// The properties to set with the created shape when exporting. See description of [NodePath] for how to reference a (sub) property.
    /// </summary>
    /// <remarks>
    /// Requires <see cref="CanExport"/> to return <see langword="true"/> for these properties to be set.
    /// The type of the set value depends on <see cref="ExportAsDecomposedHulls"/>.
    /// </remarks>
    public Godot.Collections.Array<NodePath> ExportTargets
    {
        get => Instance.Get(PropertyName.ExportTargets).AsGodotArray<NodePath>();
        set => Instance.Call(MethodName.SetExportTargets, value);
    }

    /// <inheritdoc cref="Node2D.Position"/>
    public Vector2 Position
    {
        get => Instance.Position; 
        set => Instance.Position = value;
    }
    /// <inheritdoc cref="Node2D.Rotation"/>
    public float Rotation
    {
        get => Instance.Rotation;
        set => Instance.Rotation = value;
    }
    /// <inheritdoc cref="Node2D.RotationDegrees"/>
    public float RotationDegrees
    {
        get => Instance.RotationDegrees;
        set => Instance.RotationDegrees = value;
    }
    /// <inheritdoc cref="Node2D.Scale"/>
    public Vector2 Scale
    {
        get => Instance.Scale;
        set => Instance.Scale = value;
    }

    /// <summary>Gets the created shape.</summary>
    /// <value>A <b>copy</b> of the created shape</value>
    public Vector2[] CreatedShape => Instance.Call(MethodName.GetCreatedShape).AsVector2Array();

    /// <summary>Gets the created shape, decomposed into convex hulls.</summary>
    /// <value>A <b>copy</b> of the created shape, decomposed into convex hulls.</value>
    public Godot.Collections.Array<Vector2[]> CreatedShapeDecomposed => Instance.Call(MethodName.GetCreatedShapeDecomposed).AsGodotArray<Vector2[]>();

    /// <summary>Gets the type of shape created by this <see cref="BasicPolygon2D"/>.</summary>
    /// <value>The <see cref="ShapeType"/> created.</value>
    public ShapeType CreatedShapeType => Instance.Call(MethodName.GetCreatedShapeType).As<ShapeType>();

    /// <summary>Determines whether <see cref="ExportTargets"/> will be set on <see cref="Export"/>.</summary>
    /// <remarks>
    /// This is the case when <see cref="ExportBehavior"/> has the flag of <see cref="BasicShapeCreation.ExportBehavior"/>
    /// set which corresponds to whether this <see cref="BasicPolygon2D"/>  is running in editor or at runtime.
    /// <br/><br/><see cref="ShapeExported"/> is emiited on <see cref="Export"/> regardless of this method's return value.
    /// </remarks>
    /// <returns>
    /// Returns <see langword="true"/> <see cref="ExportTargets"/> will be set on <see cref="Export"/>.
    /// </returns>
    public bool CanExport() => Instance.Call(MethodName.CanExport).AsBool();

    /// <summary>
    /// Queues the <see cref="BasicPolygon2D"/> to <see cref="Regenerate"/> and <see cref="Export"/> the shape.
    /// Called when the Generation properties are modified. Multiple calls will be converted to a single call.
    /// </summary>
    /// <remarks>
    /// Removes queued <see cref="QueueExport"/> calls.
    /// </remarks>
    public void QueueRegenerate() => Instance.Call(MethodName.QueueRegenerate);

    /// <summary>Instantly regenerates the shape, then <see cref="Export"/>s it.</summary>
    /// <remarks>Removes queued <see cref="QueueRegenerate"/> and <see cref="QueueExport"/> calls.</remarks>
    public void Regenerate() => Instance.Call(MethodName.Regenerate);

    /// <summary>
    /// Queue the <see cref="BasicPolygon2D"/> to <see cref="Export"/> the shape. Multiple calls will be converted to a single call.
    /// </summary>
    public void QueueExport() => Instance.Call(MethodName.QueueExport);

    /// <summary>
    /// Instantly exports the previously created shape, emitting <see cref="ShapeExported"/>,
    /// as well as setting the <see cref="ExportTargets"/> if <see cref="CanExport"/> returns <see langword="true"/>.
    /// </summary>
    /// <export>Removes queued <see cref="QueueRegenerate"/> and <see cref="QueueExport"/> calls.</export>
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
    /// <param name="instance">The node with the <see cref="GDScriptEquivalent"/> attached to wrap.</param>
    /// <exception cref="ArgumentNullException"><paramref name="instance"/> is <see langword="null"/>.</exception>
    /// <exception cref="ArgumentException"><paramref name="instance"/> does not have the <see cref="GDScriptEquivalent"/> attached.</exception>
    public BasicPolygon2D(Node2D instance)
    {
        if (instance is null)
            throw new ArgumentNullException(nameof(instance));
        if (GDScriptEquivalent != instance.GetScript().As<GDScript>())
            throw new ArgumentException($"must have attached script '{GDScriptEquivalentPath}'.", nameof(instance));

        Instance = instance;
        instance.Connect(SignalName.ShapeExported, Callable.From<Vector2[], Godot.Collections.Array<Vector2[]>, ShapeType>((shape, decomposed, type) => ShapeExported?.Invoke(shape, decomposed, type)));
    }
    /// <summary>Creates an instance of <see cref="GDScriptEquivalent"/> wrapped by a new <see cref="BasicPolygon2D"/>.</summary>
    public BasicPolygon2D()
    : this(GDScriptEquivalent.New().As<Node2D>())
    {
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

    /// <summary>Cached <see cref="StringName"/>s for the properties and fields contained in this class, for fast lookup.</summary>
    public class PropertyName : Node2D.PropertyName
    {
        public static readonly StringName VerticesCount = new("vertices_count");
        public static readonly StringName Sizes = new("sizes");
        public static readonly StringName OffsetRotationDegrees = new("offset_rotation_degrees");
        public static readonly StringName OffsetRotation = new("offset_rotation");
        public static readonly StringName OffsetScale = new("offset_scale");
        public static readonly StringName OffsetSkew = new("offset_skew");
        public static readonly StringName OffsetTransform = new("offset_transform");
        public static readonly StringName Color = new("color");
        public static readonly StringName OffsetPosition = new("offset_position");
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
    }

    /// <summary>Cached <see cref="StringName"/>s for the methods contained in this class, for fast lookup.</summary>
    public class MethodName : Node2D.MethodName
    {
        public static readonly StringName QueueRegenerate = new("queue_regenerate");
        public static readonly StringName Regenerate = new("regenerate");
        public static readonly StringName QueueExport = new("queue_export");
        public static readonly StringName Export = new("export");
        public static readonly StringName CanExport = new("can_export");
        public static readonly StringName SetExportTargets = new("_set_export_targets");
        public static readonly StringName GetCreatedShape = new("get_created_shape");
        public static readonly StringName GetCreatedShapeDecomposed = new("get_created_shape_decomposed");
        public static readonly StringName GetCreatedShapeType = new("get_created_shape_type");
    }

    /// <summary>Cached <see cref="StringName"/>s for the signals contained in this class, for fast lookup.</summary>
    public class SignalName : Node2D.SignalName
    {
        public static readonly StringName ShapeExported = new("shape_exported");
    }
}
