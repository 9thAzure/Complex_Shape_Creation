using System;

namespace BasicShapeCreation;

public enum ClosingMethod
{
    Slice = 0, Chord, Arc
}

[Flags]
public enum ExportBehavior
{
    Disabled = 0b_00, Editor= 0b_01, Runtime=0b_10
}

public enum ShapeType
{
    Polygon = 0, Polyline, Multiline
}
