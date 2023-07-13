// using Chickensoft.GoDotCollections;
using Chickensoft.GoDotLog;
using Chickensoft.GoDotTest;
using Godot;
using RegularPolygons2D;
using Shouldly;

namespace RegularPolygons2D.Tests;

public class RegularCollisionPolygon2DTests : TestClass
{
    // readonly GDLog _log = new GDLog(nameof(RegularCollisionPolygon2D));
    readonly RegularCollisionPolygon2D polygon = new();
    public RegularCollisionPolygon2DTests(Node testScene) : base(testScene)
    {
    }

    [Test]
    public void VerticesCount_Set3_Returns3()
    {
        polygon.VerticesCount = 3;
        
        polygon.VerticesCount.ShouldBe(3);
    }

    [Test]
    public void Size_Set8_Returns8()
    {
        polygon.Size = 8;

        polygon.Size.ShouldBe(8);
    }

    [Test]
    public void OffsetRotationDegrees_Set45_Returns45()
    {
        polygon.OffsetRotationDegrees = 45;

        polygon.OffsetRotationDegrees.ShouldBe(45);
    }

    [Test]
    public void OffsetRotation_Set2_Returns2()
    {
        polygon.OffsetRotation = 2;

        polygon.OffsetRotation.ShouldBe(2);
    }

    [Test]
    public void Width_Set5_Returns5()
    {
        polygon.Width = 5;

        polygon.Width.ShouldBe(5);
    }

    [Test]
    public void DrawnArcDegrees_Set180_Returns180()
    {
        polygon.DrawnArcDegrees = 180;

        polygon.DrawnArcDegrees.ShouldBe(180);
    }

    [Test]
    public void DrawnArc_Set2_Returns2()
    {
        polygon.DrawnArc = 2;
        polygon.DrawnArc.ShouldBe(2);
    }

    [Test]
    public void CornerSize_Set1_Returns1()
    {
        polygon.CornerSize = 1;

        polygon.CornerSize.ShouldBe(1);
    }

    [Test]
    public void CornerSmoothness_Set2_Returns2()
    {
        polygon.CornerSmoothness = 2;

        polygon.CornerSmoothness.ShouldBe(2);
    }

    [Test]
    public void Regenerate_ShapeSetEmpty_PolygonFilled()
    {
        polygon.Instance.Shape = null;

        polygon.Regenerate();

        polygon.Instance.Shape.ShouldNotBeNull();
    }

    [Test]
    public async System.Threading.Tasks.Task QueueRegenerate_ShapeSetEmpty_PolygonFilled()
    {
        polygon.Instance.Shape = null;
        TestScene.AddChild(polygon);

        polygon.QueueRegenerate();
        await TestScene.ToSignal(TestScene.GetTree(), SceneTree.SignalName.ProcessFrame);
        await TestScene.ToSignal(TestScene.GetTree(), SceneTree.SignalName.ProcessFrame);

        TestScene.RemoveChild(polygon);
        polygon.Instance.Shape.ShouldNotBeNull();
    }
}
