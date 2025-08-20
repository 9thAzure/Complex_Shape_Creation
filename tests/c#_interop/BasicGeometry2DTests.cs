using Chickensoft.GoDotTest;
using Godot;
using Shouldly;

namespace SimplifiedShapeCreation.Tests;

public class BasicGeometry2DTests : TestClass
{
    public BasicGeometry2DTests(Node testScene) : base(testScene)
    {
    }

    [Test]
    public void CreateShape_SampleCall_ExpectedReturnValue()
    {
        Vector2[] result = BasicGeometry2D.CreateShape(4, new[]{1D});

        result.ShouldNotBeNull();
        result.Length.ShouldBe(4);
    }

    [Test]
    public void AddShape_SampleCall_ExpectedReturnValue()
    {
        Vector2[] result = BasicGeometry2D.AddShape(new Vector2[] { Vector2.Zero, Vector2.Zero }, 1, 4, new[] { 1D });

        result.ShouldNotBeNull();
        result.Length.ShouldBe(6);
    }

    [Test]
    public void AddRing_SampleCall_ExpectedReturnValue()
    {
        Vector2[] shape = new[] { Vector2.Up, Vector2.Down };
        float lengthProportion = 0.5f;

        Vector2[] result = BasicGeometry2D.AddRing(shape, lengthProportion);

        result.ShouldNotBeNull();
        result.Length.ShouldBe(6);
    }

    [Test]
    public void AddRoundedCorners_SampleCall_ExpectedReturnValue()
    {
        Vector2[] shape = new[] { Vector2.Left, Vector2.Up, Vector2.Right };
        float cornerSize = 0.1f;
        int cornerSmoothness = 2;

        Vector2[] result = BasicGeometry2D.AddRoundedCorners(shape, cornerSize, cornerSmoothness);

        result.ShouldNotBeNull();
        result.Length.ShouldBe(9);
    }
}
