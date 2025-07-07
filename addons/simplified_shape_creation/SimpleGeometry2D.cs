using System;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.Threading;
using Godot;

namespace SimplifiedShapeCreation;

/// <summary>Holds methods for creating and modifying shapes.</summary>
/// <remarks>
/// In order to interop with the gdscript equivalent methods, an instance of the <see cref="GDScript"/> has to be created,
/// as well as be manually freed at the end of application lifetime via <see cref="Dispose"/>.
/// <br/><br/>If the <see cref="MainLoop"/> is implemented as a <see cref="SceneTree"/>, <see cref="Dispose"/> will
/// automatically be called when the root <see cref="Window"/> node is exiting the tree.
/// </remarks>
public static class SimpleGeometry2D
{
    private static readonly ScriptLoader Loader = new();
    private class ScriptLoader : Lazy<GodotObject>, IDisposable
    {
        private static readonly GDScript Script = GD.Load<GDScript>("res://addons/simplified_shape_creation/simple_geometry2d.gd");

        public ScriptLoader() : base(Factory, LazyThreadSafetyMode.ExecutionAndPublication)
        {
        }

        private static GodotObject Factory()
        {
            if (Engine.GetMainLoop() is SceneTree tree)
            {
                tree.Root.TreeExiting += SimpleGeometry2D.Dispose;
            }
            return Script.New(true).AsGodotObject();
        }

        ~ScriptLoader()
        {
            Dispose();
        }

        [SuppressMessage("ReSharper", "MemberHidesStaticFromOuterClass")]
        public void Dispose()
        {
            if (GodotObject.IsInstanceValid(Value))
            {
                Value.Free();
            }
        }
    }

    /// <summary>
    /// <see cref="GodotObject.Free"/>s the gdscript instance this class interops with to call
    /// the other methods, if it hasn't been already.
    /// </summary>
    public static void Dispose()
    {
        Loader.Dispose();
    }

    /// <summary>
    /// Cached <see cref="StringName"/>s for the methods contained in this class, for fast lookup.
    /// </summary>
    [SuppressMessage("ReSharper", "MemberHidesStaticFromOuterClass")]
    public static class MethodName
    {
        public static readonly StringName Dispose = new(nameof(SimpleGeometry2D.Dispose));
        public static readonly StringName CreateShape = new("create_shape");
        public static readonly StringName AddRing = new("add_ring");
        public static readonly StringName AddRoundedCorners = new("add_rounded_corners");
    }

    /// <summary>
    /// Creates and returns a <see cref="T:Vector2[]"/> describing the shape specified by the parameters.
    /// </summary>
    /// <param name="verticesCount">The number of points on the base shape. If it is a value of <c>1</c>, a value of <c>32</c> is used instead.</param>
    /// <param name="sizes">Determines the length of each point from the center of the base shape, being repeatedly iterated through to get the length for each corner.</param>
    /// <param name="offsetRotation">The amount in radians to rotate the shape.</param>
    /// <param name="offsetPosition">The amount to shift the shape.</param>
    /// <param name="arcStart">The starting angle of the arc out of the base shape that is cut out and returned, in radians.</param>
    /// <param name="arcEnd">The ending angle of the arc out of the base shape that is cut out and returned, in radians.</param>
    /// <param name="addCentralPoint">If <c>true</c>, adds a center point to the shape. It is automatically false if the arc of the shape is a complete circle.</param>
    /// <returns>A <see cref="T:Vector2[]"/> describing the shape specified by the parameters.</returns>
    public static Vector2[] CreateShape(int verticesCount, double[] sizes, double offsetRotation = 0d,
        Vector2 offsetPosition = default, double arcStart = 0d, double arcEnd = Math.Tau, bool addCentralPoint = true)
    {
        Debug.Assert(Loader.Value.HasMethod(MethodName.CreateShape));
        return Loader.Value.Call(MethodName.CreateShape, verticesCount, sizes, offsetRotation, offsetPosition,
            arcStart, arcEnd, addCentralPoint).AsVector2Array();
    }

    /// <summary>
    /// Returns a modified copy of <paramref name="shape"/>, adding a duplicate ring of points.
    /// </summary>
    /// <param name="shape">The base shape.</param>
    /// <param name="lengthProportion">The proportion of the distance of the original points which the new points are placed at, relative to the <paramref name="shapeCenter"/>.</param>
    /// <param name="shapeCenter">The center of the shape.</param>
    /// <param name="closeRing">If true, the first point is also appended to the end before adding the ring.</param>
    /// <returns>A <see cref="T:Vector2[]"/>, representing the shape of <paramref name="shape"/> with an added ring.</returns>
    public static Vector2[] AddRing(Vector2[] shape, double lengthProportion, Vector2 shapeCenter = default, bool closeRing = true)
    {
        Debug.Assert(Loader.Value.HasMethod(MethodName.AddRing));
        return Loader.Value.Call(MethodName.AddRing, shape, lengthProportion, shapeCenter, closeRing).AsVector2Array();
    }

    /// <summary>
    /// Returns a modified copy of <paramref name="shape"/> with rounded corners.
    /// </summary>
    /// <remarks>The method uses quadratic Bézier curves to place the points on the rounded corner.</remarks>
    /// <param name="shape">The base shape.</param>
    /// <param name="cornerSize">The distance along the edge where the smoothed corner will start from.</param>
    /// <param name="cornerSmoothness">How many lines are in each corner.</param>
    /// <returns>A <see cref="T:Vector2[]"/>, representing the shape of <paramref name="shape"/> with rounded corners.</returns>
    public static Vector2[] AddRoundedCorners(Vector2[] shape, double cornerSize, long cornerSmoothness)
    {
        Debug.Assert(Loader.Value.HasMethod(MethodName.AddRoundedCorners));
        return Loader.Value.Call(MethodName.AddRoundedCorners, shape, cornerSize, cornerSmoothness).AsVector2Array();
    }
}
