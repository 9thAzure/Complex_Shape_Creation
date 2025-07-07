using System;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.Threading;
using Godot;

namespace SimplifiedShapeCreation;

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

    public static void Dispose()
    {
        Loader.Dispose();
    }

    /// <summary>
    /// Cached <see cref="StringName"/>s for most of the methods contained in this class, for fast lookup.
    /// </summary>
    [SuppressMessage("ReSharper", "MemberHidesStaticFromOuterClass")]
    public static class MethodName
    {
        public static readonly StringName CreateShape = new("create_shape");
        public static readonly StringName AddRing = new("add_ring");
        public static readonly StringName AddRoundedCorners = new("add_rounded_corners");
    }

    public static Vector2[] CreateShape(int verticesCount, long[] sizes, double offsetRotation = 0d,
        Vector2 offsetPosition = default, double arcStart = 0d, double arcEnd = Math.Tau, bool addCentralPoint = true)
    {
        Debug.Assert(Loader.Value.HasMethod(MethodName.CreateShape));
        return Loader.Value.Call(MethodName.CreateShape, verticesCount, sizes, offsetRotation, offsetPosition,
            arcStart, arcEnd, addCentralPoint).AsVector2Array();
    }



    public static Vector2[] AddRing(Vector2[] shape, double lengthProportion, Vector2 shapeCenter = default, bool closeRing = true)
    {
        Debug.Assert(Loader.Value.HasMethod(MethodName.AddRing));
        return Loader.Value.Call(MethodName.AddRing, shape, lengthProportion, shapeCenter, closeRing).AsVector2Array();
    }

    // static func add_rounded_corners(points : PackedVector2Array, corner_size : float, corner_smoothness : int,
    // start_index := 0, length := -1, limit_ending_slopes := true, original_array_size := 0) -> void:
    public static Vector2[] AddRoundedCorners(Vector2[] shape, double cornerSize, long cornerSmoothness)
    {
        Debug.Assert(Loader.Value.HasMethod(MethodName.AddRoundedCorners));
        return Loader.Value.Call(MethodName.AddRoundedCorners, shape, cornerSize, cornerSmoothness).AsVector2Array();
    }
}
