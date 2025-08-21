using System;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.Threading;
using Godot;

namespace BasicShapeCreation;

/// <summary>Holds methods for creating and modifying shapes.</summary>
/// <remarks>
/// In order to interop with the gdscript equivalent methods, an instance of the <see cref="GDScript"/> has to be created,
/// as well as be manually freed at the end of application lifetime via <see cref="Dispose"/>.
/// <br/><br/>If the <see cref="MainLoop"/> is implemented as a <see cref="SceneTree"/>, <see cref="Dispose"/> will
/// automatically be called when the root <see cref="Window"/> node is exiting the tree. This behaviour can be disabled
/// with <see cref="FreeOnWindowExit"/>.
/// </remarks>
public static class BasicGeometry2D
{
    private static readonly ScriptLoader _loader = new();
    private class ScriptLoader : Lazy<GodotObject>, IDisposable
    {
        public ScriptLoader() : base(Factory, LazyThreadSafetyMode.ExecutionAndPublication)
        {
        }

        private static GodotObject Factory()
        {
            if (Engine.GetMainLoop() is SceneTree tree)
            {
                tree.Root.TreeExiting += BasicGeometry2D.Dispose;
            }

            var gdScript = GD.Load<GDScript>("res://addons/basic_shape_creation/basic_geometry2d.gd");
            return gdScript.New().AsGodotObject();
        }

        ~ScriptLoader()
        {
            Dispose();
        }

        [SuppressMessage("ReSharper", "MemberHidesStaticFromOuterClass")]
        public void Dispose()
        {
            if (BasicGeometry2D.FreeOnWindowExit && GodotObject.IsInstanceValid(Value))
            {
                Value.Free();
            }
        }
    }

    /// <summary>
    /// Toggles whether to automatically free the gdscript <see cref="Instance"/> when it is detected that the root <see cref="Window"/>
    /// is exiting the <see cref="SceneTree"/>.
    /// </summary>
    /// <remarks>
    /// Set this property to <see langword="false"/> if you need to provide your own system to free the instance and prevent
    /// the auto freeing. Note that the auto freeing does not occur if the <see cref="MainLoop"/> isn't a <see cref="SceneTree"/> anyways,
    /// so setting this property to <see langword="false"/> is not necessary.
    /// </remarks>
    public static bool FreeOnWindowExit { get; set; } = true;

    /// <summary>
    /// Gets the instance used by this class to access the gdscript methods.
    /// </summary>
    public static GodotObject Instance => _loader.Value;

    /// <summary>
    /// <see cref="GodotObject.Free"/>s the gdscript instance this class interops with to call
    /// the other methods, if it hasn't been already.
    /// </summary>
    public static void Dispose()
    {
        _loader.Dispose();
    }

    /// <inheritdoc cref="GodotObject.MethodName"/>
    public class MethodName : GodotObject.MethodName
    {
        public static readonly StringName CreateShape = new("create_shape");
        public static readonly StringName AddShape = new("add_shape");
        public static readonly StringName AddRing = new("add_ring");
        public static readonly StringName AddRoundedCorners = new("add_rounded_corners");
    }

    /// <inheritdoc cref="GodotObject.PropertyName"/>
    public class PropertyName : GodotObject.PropertyName {}

    /// <inheritdoc cref="GodotObject.SignalName"/>
    public class Signalname : GodotObject.SignalName {}

    /// <summary>
    /// Creates and returns a <see cref="T:Vector2[]"/> describing the shape specified by the parameters.
    /// </summary>
    /// <param name="verticesCount">The number of points on the base shape. If it is a value of <c>1</c>, a value of <c>32</c> is used instead.</param>
    /// <param name="sizes">Determines the length of each point from the center of the base shape, being repeatedly iterated through to get the length for each corner.</param>
    /// <param name="offsetTransform">The offset transform of the created shape.</param>
    /// <param name="arcStart">The starting angle of the arc out of the base shape that is cut out and returned, in radians.</param>
    /// <param name="arcEnd">The ending angle of the arc out of the base shape that is cut out and returned, in radians.</param>
    /// <param name="addCentralPoint">If <c>true</c>, adds a center point to the shape. It is automatically false if the arc of the shape is a complete circle.</param>
    /// <returns>A <see cref="T:Vector2[]"/> describing the shape specified by the parameters.</returns>
    public static Vector2[] CreateShape(int verticesCount, double[] sizes, Transform2D? offsetTransform = null,
        double arcStart = 0d, double arcEnd = Math.Tau, bool addCentralPoint = true)
    {
        Debug.Assert(GodotObject.IsInstanceValid(_loader.Value));
        Debug.Assert(_loader.Value.HasMethod(MethodName.CreateShape));
        return _loader.Value.Call(MethodName.CreateShape, verticesCount, sizes, offsetTransform ?? Transform2D.Identity,
            arcStart, arcEnd, addCentralPoint).AsVector2Array();
    }

    /// <inheritdoc cref="CreateShape"/>
    /// <summary>
    /// Creates and inserts the shape specified by the parameters into a copy of <paramref name="points"/> at <paramref name="start"/> index.
    /// </summary>
    /// <param name="points">The initial array to clone and insert a shape into.</param>
    /// <param name="start">The index to insert the shape at.</param>
    public static Vector2[] AddShape(Vector2[] points, int start, int verticesCount, double[] sizes, Transform2D? offsetTransform = null,
        double arcStart = 0d, double arcEnd = Math.Tau, bool addCentralPoint = true)
    {
        Debug.Assert(GodotObject.IsInstanceValid(_loader.Value));
        Debug.Assert(_loader.Value.HasMethod(MethodName.AddShape));
        return _loader.Value.Call(MethodName.AddShape, points, start, verticesCount, sizes, offsetTransform ?? Transform2D.Identity,
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
        Debug.Assert(GodotObject.IsInstanceValid(_loader.Value));
        Debug.Assert(_loader.Value.HasMethod(MethodName.AddRing));
        return _loader.Value.Call(MethodName.AddRing, shape, lengthProportion, shapeCenter, closeRing).AsVector2Array();
    }

    /// <summary>
    /// Returns a modified copy of <paramref name="shape"/> with rounded corners.
    /// </summary>
    /// <remarks>The method uses quadratic Bézier curves to place the points on the rounded corner.</remarks>
    /// <param name="shape">The base shape.</param>
    /// <param name="cornerSize">The distance along the edge where the smoothed corner will start from.</param>
    /// <param name="cornerDetail">How many lines are in each corner.</param>
    /// <param name="startIndex">The initial point to round.</param>
    /// <param name="length">The number of points to round.</param>
    /// <param name="limitEndingSlopes">Whether the first and last corner should be limited to half the side distance or not. No effect if the entire shape is being rounded.</param>
    /// <returns>A <see cref="T:Vector2[]"/>, representing the shape of <paramref name="shape"/> with rounded corners.</returns>
    public static Vector2[] AddRoundedCorners(Vector2[] shape, double cornerSize, long cornerDetail, long startIndex = 0, long length = -1, bool limitEndingSlopes = true)
    {
        Debug.Assert(GodotObject.IsInstanceValid(_loader.Value));
        Debug.Assert(_loader.Value.HasMethod(MethodName.AddRoundedCorners));
        return _loader.Value.Call(MethodName.AddRoundedCorners, shape, cornerSize, cornerDetail, startIndex, length, limitEndingSlopes).AsVector2Array();
    }
}
