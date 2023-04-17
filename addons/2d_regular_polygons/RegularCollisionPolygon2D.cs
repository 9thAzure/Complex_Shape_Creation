using System;
using System.Diagnostics;
using Godot;
using RegularPolygons2D.MemberNames;

namespace RegularPolygons2D;

public class RegularCollisionPolygon2D
{
    /// <inheritdoc cref="SimplePolygon2D.GDScriptEquivalentPath"/>
    public const string GDScriptEquivalentPath = "res://addons/2d_regular_polygons/regular_collision_polygon_2d.gd";
    /// <summary>The loaded <see cref="GDScript"/> of <see cref="GDScriptEquivalentPath"/>.</summary>
    public static readonly GDScript GDScriptEquivalent = GD.Load<GDScript>(GDScriptEquivalentPath);

    /// <summary>The <see cref="GDScriptEquivalent"/> instance this class wraps around.</summary>
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
    /// <summary>Determines the width of the shape.</summary>
    /// <remarks>
    /// It only has an effect with values greater than <c>0</c>.
    /// Values greater than or equal to <see cref="size"/> force the usage of <see cref="ConvexPolygonShape2D"/>.
    /// </remarks>
    public double Width
    {
        get => (double)Instance.Get(PropertyName.Width);
        set => Instance.Set(PropertyName.Width, value);
    }
    /// <inheritdoc cref="RegularPolygon2D.DrawnArcDegrees"/>
    public double DrawnArcDegrees
    {
        get => (double)Instance.Get(PropertyName.DrawnArcDegrees);
        set => Instance.Set(PropertyName.DrawnArcDegrees, value);
    }
    /// <inheritdoc cref="RegularPolygon2D.DrawnArc"/>
    public double DrawnArc
    {
        get => (double)Instance.Get(PropertyName.DrawnArc);
        set => Instance.Set(PropertyName.DrawnArc, value);
    }
    /// <inheritdoc cref="RegularPolygon2D.CornerSize"/>
    public double CornerSize
    {
        get => (double)Instance.Get(PropertyName.CornerSize);
        set => Instance.Set(PropertyName.CornerSize, value);
    }
    /// <inheritdoc cref="RegularPolygon2D.CornerSmoothness"/>
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

    /// <summary>Creates and wraps a <see cref="CollisionShape2D"/> around <paramref name="instance"/>.</summary>
    /// <param name="instance">The instance of <see cref="GDScriptEquivalent"/> to wrap.</param>
    /// <exception cref="ArgumentNullException"><paramref name="instance"/> is <see langword="null"/>.</exception>
    /// <exception cref="ArgumentException"><paramref name="instance"/> isn't a instance of <see cref="GDScriptEquivalent"/>.</exception>
    public RegularCollisionPolygon2D(CollisionShape2D instance)
    {
        if (instance is null)
            throw new ArgumentNullException(nameof(instance));
        if (GDScriptEquivalent != instance.GetScript().As<GDScript>())
            throw new ArgumentException($"must have attached script '{GDScriptEquivalentPath}'.", nameof(instance));

        Instance = instance;
    }
    /// <inheritdoc cref="New"/>
    /// <summary>Creates an instance of <see cref="GDScriptEquivalent"/> wrapped by a new <see cref="CollisionShape2D"/>.</summary>
    /// <remarks>See also: <seealso cref="New"/>.</remarks>
    public RegularCollisionPolygon2D(long verticesCount = 1, double size = 10, double offsetRotation = 0,
        double width = 0, double drawnArc = Math.Tau, double cornerSize = 0, long cornerSmoothness = 0)
    => Instance = RegularCollisionPolygon2D.New(verticesCount, size, offsetRotation, width, drawnArc, cornerSize, cornerSmoothness);

    /// <inheritdoc cref="RegularPolygon2D.New)"/>
    /// <summary>Creates an instance of <see cref="GDScriptEquivalent"/> with the specified parameters.</summary>
    public static CollisionShape2D New(long verticesCount = 1, double size = 10, double offsetRotation = 0,
        double width = 0, double drawnArc = Math.Tau, double cornerSize = 0, long cornerSmoothness = 0)
        => GDScriptEquivalent.New(verticesCount, size, offsetRotation, width, drawnArc, cornerSize, cornerSmoothness).As<CollisionShape2D>();

    /// <summary>
    /// Queues <see cref="Regenerate"/> for the next process frame. If this method is called multiple times, the shape is only regenerated once.
    /// </summary>
    /// <remarks>This method does nothing if the node is outside the <see cref="SceneTree"/>. Use <see cref="Regenerate"/> instead.</remarks>
    public void QueueRegenerate()
    => Instance.Call(MethodName.QueueRegenerate);

    /// <summary>
    /// Regenerates the <see cref="CollisionShape2D.Shape"/> using the properties of this node.
    /// </summary>
    public void Regenerate()
    => Instance.Call(MethodName.Regenerate);

    public static implicit operator CollisionShape2D(RegularCollisionPolygon2D instance) => instance.Instance;
    public static explicit operator RegularCollisionPolygon2D(CollisionShape2D instance) => new RegularCollisionPolygon2D(instance);
}
