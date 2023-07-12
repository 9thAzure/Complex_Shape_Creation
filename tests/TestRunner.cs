using System;
using System.Reflection;
using Chickensoft.GoDotTest;
using Godot;

namespace RegularPolygons2D.Tests;

public partial class TestRunner : Node
{
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        _ = GoTest.RunTests(Assembly.GetExecutingAssembly(), this, TestEnvironment.From(new string[]{"--run-tests", "--quit-on-finish"}));
    }

}
