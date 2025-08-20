using System;
using System.Diagnostics.CodeAnalysis;
using System.Threading.Tasks;
using Chickensoft.GoDotLog;
using Chickensoft.GoDotTest;
using Godot;
using Godot.Collections;
using BasicShapeCreation;
using Shouldly;

namespace BasicShapeCreation.Tests;

[SuppressMessage("ReSharper", "ConditionIsAlwaysTrueOrFalse")]
public class BasicPolygon2DTests : TestClass
{
    // readonly GDLog _log = new GDLog(nameof(SimplePolygon2D));
    private BasicPolygon2D _polygon;
    private readonly Node _root;
    public BasicPolygon2DTests(Node testScene) : base(testScene)
    {
        _root = testScene;
    }

    [Setup]
    public void Setup()
    {
        _polygon = new();
        _root.AddChild(_polygon);
    }

    [Cleanup]
    public void CleanUp()
    {
        if (_used_handler is not null)
        {
            _polygon.ShapeExported -= _used_handler;
        }

        _used_handler = null;

        _polygon.Instance.QueueFree();
        _root.RemoveChild(_polygon);
    }

    [Test]
    public void Misc_SetMostProperties_GetSameValuesWithoutError()
    {
        int verticesCount = 5;
        double[] sizes = { 10.0, 10.0 };
        float ringRatio = 0.5f;
        float cornerSize = 1.0f;
        int cornerDetail = 1;
        float arcStart = Mathf.Pi;
        float arcAngle = Mathf.Pi;
        ClosingMethod closingMethod = ClosingMethod.Arc;
        bool roundArcEnds = true;
        Vector2 offsetPosition = Vector2.One;
        float offsetRotation = Mathf.Pi;
        Vector2 offsetScale = Vector2.One * 2;
        float offsetSkew = Mathf.Pi;
        bool drawShape = false;
        bool drawBorder = true;
        float borderWidth = 1.0f;
        Color color = Colors.Aqua;
        Color borderColor = Colors.Aqua;
        ExportBehavior exportBehavior = ExportBehavior.Editor;
        bool exportAsHulls = true;
        bool autoFree = true;
        Godot.Collections.Array<NodePath> exportTargets = new Array<NodePath>();
        exportTargets.Add(new NodePath(""));

        _polygon.VerticesCount = verticesCount;
        _polygon.Sizes = sizes;
        _polygon.RingRatio = ringRatio;
        _polygon.CornerSize = cornerSize;
        _polygon.CornerDetail = cornerDetail;
        _polygon.ArcStart = arcStart;
        _polygon.ArcAngle = arcAngle;
        _polygon.ClosingMethod = closingMethod;
        _polygon.RoundArcEnds = roundArcEnds;
        _polygon.OffsetPosition = offsetPosition;
        _polygon.OffsetRotation = offsetRotation;
        _polygon.OffsetScale = offsetScale;
        _polygon.OffsetSkew = offsetSkew;
        _polygon.DrawShape = drawShape;
        _polygon.DrawBorder = drawBorder;
        _polygon.BorderWidth = borderWidth;
        _polygon.Color = color;
        _polygon.BorderColor = borderColor;
        _polygon.ExportBehavior = exportBehavior;
        _polygon.ExportAsDecomposedHulls = exportAsHulls;
        _polygon.AutoFree = autoFree;
        _polygon.ExportTargets = exportTargets;

        _polygon.ShouldSatisfyAllConditions(
            () => _polygon.VerticesCount.ShouldBe(verticesCount),
            () => _polygon.RingRatio.ShouldBe(ringRatio),
            () => _polygon.CornerSize.ShouldBe(cornerSize),
            () => _polygon.CornerDetail.ShouldBe(cornerDetail),
            () => _polygon.ArcStart.ShouldBe(arcStart),
            () => _polygon.ArcAngle.ShouldBe(arcAngle),
            () => _polygon.ClosingMethod.ShouldBe(closingMethod),
            () => _polygon.RoundArcEnds.ShouldBe(roundArcEnds),
            () => _polygon.OffsetPosition.ShouldBe(offsetPosition),
            () => _polygon.OffsetRotation.ShouldBe(offsetRotation),
            () => _polygon.OffsetScale.ShouldBe(offsetScale),
            () => _polygon.OffsetSkew.ShouldBe(offsetSkew),
            () => _polygon.DrawShape.ShouldBe(drawShape),
            () => _polygon.DrawBorder.ShouldBe(drawBorder),
            () => _polygon.BorderWidth.ShouldBe(borderWidth),
            () => _polygon.Color.ShouldBe(color),
            () => _polygon.BorderColor.ShouldBe(borderColor),
            () => _polygon.ExportBehavior.ShouldBe(exportBehavior),
            () => _polygon.ExportAsDecomposedHulls.ShouldBe(exportAsHulls),
            () => _polygon.AutoFree.ShouldBe(autoFree),
            () => _polygon.ExportTargets.Count.ShouldBe(exportTargets.Count)
        );
    }

    [Test]
    public void Misc_SetChangingProperties_GetExpectedValues()
    {
        Transform2D offsetTransform = new Transform2D(2, 2, 2, 2, 2, 2);

        _polygon.ShouldSatisfyAllConditions(
            p => (p.ArcStartDegrees = 180).ShouldBe(180),
            p => (p.ArcAngleDegrees = 180).ShouldBe(180),
            p => {p.ArcEndDegrees = 540; p.ShouldSatisfyAllConditions(() => p.ArcEndDegrees.ShouldBe(540), () => p.ArcAngleDegrees.ShouldBe(360));},
            p => {p.ArcEnd = Mathf.Tau; p.ShouldSatisfyAllConditions(() => p.ArcEnd.ShouldBe(Mathf.Tau), () => p.ArcAngle.ShouldBe(Mathf.Pi));},
            p => (p.OffsetTransform = offsetTransform).ShouldBe(offsetTransform)
        );
    }

    [Test]
    public void CreatedShapeType_SetAsPolyline_GetPolylineShapeType()
    {
        _polygon.RingRatio = 0;

        _polygon.Regenerate();

        _polygon.CreatedShapeType.ShouldBe(ShapeType.Polyline);
    }

    [Test]
    public void Regenerate_Called_CreatesShape()
    {
        _polygon.Regenerate();

        _polygon.ShouldSatisfyAllConditions(
            p => p.CreatedShape.ShouldNotBeEmpty(),
            p => p.CreatedShapeDecomposed.ShouldNotBeEmpty()
        );
    }

    [Test]
    public void CanExport_SetShapeToExport_ReturnsTrue()
    {
        _polygon.ExportBehavior = ExportBehavior.Runtime | ExportBehavior.Editor;

        _polygon.CanExport().ShouldBeTrue();
    }

    private BasicPolygon2D.ShapeExportedEventHandler _used_handler;

    public async Task<bool> CheckForExport()
    {
        bool capture = false;

        _used_handler = (_, _, _) =>
        {
            capture = true;
        };
        _polygon.ShapeExported += _used_handler;

        for (int i = 0; i < 4; i++)
        {
            await _polygon.Instance.ToSignal(_polygon.Instance.GetTree(), SceneTree.SignalName.ProcessFrame);
        }

        _polygon.ShapeExported -= _used_handler;
        _used_handler = null;

        return capture;
    }

    [Test]
    public async Task ShapeExported_CauseSignalActivation_RaiseEvent()
    {
        var task = CheckForExport();

        _polygon.VerticesCount = 4;

        await task;
        task.Exception.ShouldBeNull();
        task.Result.ShouldBeTrue();
    }

    [Test]
    public async Task QueueRegenerate_Called_RaiseEvent()
    {
        var task = CheckForExport();

        _polygon.QueueRegenerate();

        await task;
        task.Exception.ShouldBeNull();
    }

    [Test]
    public async Task QueueExport_Called_RaiseEvent()
    {
        var task = CheckForExport();

        _polygon.QueueExport();

        await task;
        task.Exception.ShouldBeNull();
    }

    [Test]
    public async Task Export_Called_RaiseEvent()
    {
        var task = CheckForExport();

        _polygon.Export();

        await task;
        task.Exception.ShouldBeNull();
    }

    [Test]
    public void AsyncDurationExtender()
    {
        // Ensures previous async tests to complete fully.
        System.Threading.Thread.Sleep(1000/60 * 5);
    }
}
