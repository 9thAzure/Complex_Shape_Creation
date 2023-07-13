// using Chickensoft.GoDotCollections;
using Chickensoft.GoDotLog;
using Chickensoft.GoDotTest;
using Godot;
using RegularPolygons2D;
using Shouldly;

namespace RegularPolygons2D.Tests;

public class StarPolygon2DTests : TestClass
{
    // readonly GDLog _log = new GDLog(nameof(StarPolygon2D));
    readonly StarPolygon2D polygon = new();
    public StarPolygon2DTests(Node testScene) : base(testScene)
    {
    }

    [Test]
    public void PointCount_Set3_Returns3()
    {
        polygon.PointCount = 3;
        
        polygon.PointCount.ShouldBe(3);
    }

    [Test]
    public void Size_Set8_Returns8()
    {
        polygon.Size = 8;

        polygon.Size.ShouldBe(8);
    }

    [Test]
    public void InnerSize_Set4_Returns8()
    {
        polygon.InnerSize = 4;

        polygon.InnerSize.ShouldBe(4);
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
    public void SetPointAngle_Set2_InnerSizeChanges()
    {
        var previousInnerSize = polygon.InnerSize;

        polygon.SetPointAngle(2);

        polygon.InnerSize.ShouldNotBe(previousInnerSize);
    }

    [Test]
    public void UsesPolygonMember_WidthIs10_ReturnsTrue()
    {
        polygon.Width = 10;

        var result = polygon.UsesPolygonMember();

        result.ShouldBe(true);
    }

    [Test]
    public void RegeneratePolygon_PolygonSetEmpty_PolygonFilled()
    {
        polygon.Instance.Polygon = System.Array.Empty<Vector2>();

        polygon.RegeneratePolygon();

        polygon.Instance.Polygon.Length.ShouldBeGreaterThan(0);
    }

    [Test]
    public void GetStarVertices_DiamondShape_Returns4LengthArray()
    {
        var array = StarPolygon2D.GetStarVertices(4, 2, 1);

        array.Length.ShouldBe(8);
    }
}
