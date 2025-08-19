using System.Diagnostics.CodeAnalysis;
using Chickensoft.GoDotTest;
using Godot;
using Shouldly;

namespace SimplifiedShapeCreation.Tests;

[SuppressMessage("ReSharper", "ConditionIsAlwaysTrueOrFalse")]
public class BasicCollisionPolygon2DTest : TestClass
{
    private BasicCollisionPolygon2D _polygon;
    private readonly Node _root;
    public BasicCollisionPolygon2DTest(Node testScene) : base(testScene)
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
    public void Cleanup()
    {
        _polygon.Instance.QueueFree();
        _root.RemoveChild(_polygon);
    }

    [Test]
    public void Properties_AllSet_GetSameValue()
    {
        bool disabled = true;
        bool oneWayCollision = true;
        int oneWayCollisionMargin = 5;
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

        _polygon.ShouldSatisfyAllConditions(
            p => (p.Disabled = disabled).ShouldBeTrue(),
            p => (p.OneWayCollision = oneWayCollision).ShouldBeTrue(),
            p => (p.OneWayCollisionMargin = oneWayCollisionMargin).ShouldBe(oneWayCollisionMargin),
            p => (p.VerticesCount = verticesCount).ShouldBe(verticesCount),
            p => (p.Sizes = sizes).ShouldBe(sizes),
            p => (p.RingRatio = ringRatio).ShouldBe(ringRatio),
            p => (p.CornerSize = cornerSize).ShouldBe(cornerSize),
            p => (p.CornerDetail = cornerDetail).ShouldBe(cornerDetail),
            p => (p.ArcStart = arcStart).ShouldBe(arcStart),
            p => (p.ArcAngle = arcAngle).ShouldBe(arcAngle),
            p => (p.ClosingMethod = closingMethod).ShouldBe(closingMethod),
            p => (p.RoundArcEnds = roundArcEnds).ShouldBeTrue(),
            p => (p.OffsetPosition = offsetPosition).ShouldBe(offsetPosition),
            p => (p.OffsetRotation = offsetRotation).ShouldBe(offsetRotation),
            p => (p.OffsetScale = offsetScale).ShouldBe(offsetScale),
            p => (p.OffsetSkew = offsetSkew).ShouldBe(offsetSkew)
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

        _polygon.BasicPolygon.Regenerate();

        _polygon.CreatedShapeType.ShouldBe(ShapeType.Polyline);
    }

    [Test]
    public void CreatedShape_RegenerateNewShape_ShapeExported()
    {
        _polygon.VerticesCount = 4;
        _polygon.Sizes = new double[] { 10 };

        _polygon.ShouldSatisfyAllConditions(
            p => p.CreatedShape.ShouldNotBeEmpty(),
            p => p.CreatedShapeDecomposed.ShouldNotBeEmpty(),
            p =>
            {
                p.ShapeCount.ShouldNotBe(0);
                p.GetShape(0).ShouldBeOfType(typeof(ConvexPolygonShape2D));
            });
    }
}
