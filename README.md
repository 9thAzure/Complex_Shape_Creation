# Simplified Shape Creation

![Regular Polygon 2D icon](/addons/basic_shape_creation/basic_polygon2d/basic_polygon2d.svg)

![GitHub Release](https://img.shields.io/github/v/release/9thAzure/basic_shape_creation)
![GitHub License](https://img.shields.io/github/license/9thAzure/basic_shape_creation)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/9thAzure/basic_shape_creation)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/9thAzure/basic_shape_creation/total)

An addon for the  [Godot Engine](https://godotengine.org/) which adds a few basic functions for creating and modifying shapes,
and a few nodes that use those functions to create shapes and use them. 

These functions and nodes are written in GDScript to make them universally compatible.
They are exposed to C# via wrapper classes in the `BasicShapeCreation` namespace. 

## Installation

There are 2 ways to download the plugin:

### Godot Asset Library download
1. In the Godot editor, go to the **AssetLib** tab.
2. Search for the "2D Regular Polygons" addon.
3. Select and click `install` (and subsequent `install`s.).

### Zip-file download.
1. Go to the **Releases** page.
2. Download the zip file in **Assets** section of the wanted release.
3. Extract the `basic_shape_creation` folder from the zip file and put it in the `addons` folder in the target project.
    Create the `addons` folder if it does not exist yet project.

***

Once downloaded, the addon can be enabled in `Project` > `Project Settings` > `Plugins`.

## Quick Tutorial

This is a short introduction to how the addon works.

### Nodes

Currently, there are 2 nodes that this plugin offer:

#### [BasicPolygon2D]

A general purpose node for creating shapes, which can be both polygons or disconnected lines.
After a shape is created, the node offers 2 ways of making use of it.

The first is to draw it, which can be enabled (and is by default) by setting `draw_shape` to true. Colors and borders can 
also be customized.

The second way is to send the created shape to other nodes so that they can use it for their own purposes.
The shapes can be obtained from a reference to the [BasicPolygon2D] with `get_created_shape()`.
The signal `shape_exported` is also emitted whenever a new shape is created, which can be connected to a different script.
Finally, the node has an export system where it can set properties of other nodes. This can be done by setting `export_behavior`
to export either or both in editor or in runtime, then setting `export_targets` to an array of `NodePath`s, relative to the [BasicPolygon2D],
pointing to the properties to set. (The `NodePath`s should look something like: `^"../../Relative/Path/To/Node:property:sub_property"`)

#### BasicCollisionPolygon2D

This node is a specialization of [BasicPolygon2D], only providing a similarly generated shape 
to a `CollisionObject2D`, like `CollisionPolygon2D` or `CollisionShape2D`.

### Generation 

Both of these nodes share the same properties for generating the shape. Here are some of them and what they do below.

- `vertices_count` - Determines the number of vertices in the base shape. For instance, a value of `3` creates a triangle. 
    A value of `1` is equivalent to a 32-point shape, and a value of `2` creates a special shape of multiple radiating lines.
- `sizes` - Determines the size of the shape, from the center to the outer vertices. Multiple values are allowed, cycling through for each
    vertex. For instance, a star shape can be created with `sizes` set with 2 values. Note that this does not affect the number of vertices,
    so a 5-point star would require a `vertices_count` of `10`.
- `ring_ratio` - With values below 1, it can be used to create ring shapes.
- `corner_size`/`corner_detail` - Controls the size of the rounded corners, if to have any, and the number of points to make up each corner.
    Corners make use of quadratic Bézier curves. 
- `arc_start`/`arc_angle` - Enables cutting out a slice of the base shape. For instance, it can be used to cut out a corner of a square.

### Functions

The functions used for creating the bulk of these shapes are accessible under the [BasicGeometry2D] singleton. 
All of them return the new shape. If they are passed a shape, that shape is directly modified as well as returned.
The provided functions are:

- `add_shape` - Creates a shape and inserts it into the provided array at the provided index. Takes `vertices_count`, `sizes`, and `arc_angle`. 
- `create_shape` - A variant of add_shape which puts the created shape into a newly created array.
- `add_ring` - Takes a shape and duplicates its points to be some proportional amount closer to the shape center.
- `add_rounded_corners` - Takes a shape and rounds the corners.

### C# API

The provided nodes and the singleton are exposed to C# via wrapper classes in the `BasicShapeCreation` namespace.
These wrapper classes can also be used for creating these nodes.

> [!WARNING]
> Since static methods still require an instance to access, the `BasicGeometry2D` Singleton must create an object that must be
> freed before the application ends. By default, the instance is freed when the root `Window` is exiting the `SceneTree` and
> emits the `TreeExiting` signal. If a custom behaviour needs to be supplied, the default behaviour can be disabled by setting
> the project setting `basic_shape_creation/dotnet/default_singleton_freeing` to false, then calling `BasicGeometry2D.Dispose`
> whenever the application is about to close.

#### API Differences

##### BasicPolygon2D
The following methods have been converted into readonly properties.

`get_created_shape()` > `CreatedShape`\
`get_created_shape_decomposed()` > `CreatedShapeDecomposed`\
`get_created_shape_type()` > `CreatedShapeType`\

##### BasicCollisionPolygon2D
The following methods have been converted into readonly properties.

`get_created_shape()` > `CreatedShape`\
`get_created_shape_decomposed()` > `CreatedShapeDecomposed`\
`get_created_shape_type()` > `CreatedShapeType`\
`shape_count()` > `ShapeCount`\
`get_basic_polygon()`> `BasicPolygon`


## License

This addon is available under the [MIT](https://mit-license.org/) license,
which is in the addon's [folder](/addons/simplified_shape_creation/LICENSE.txt).
A copy is available in the root [folder](/LICENSE.md).

## Plugins / Packages Used

This addon uses several external packages for unit testing:
- [GUT (Godot Unit Test)](https://github.com/bitwes/Gut) (Godot addon)
- [Chickensoft.GoDotTest](https://github.com/chickensoft-games/GoDotTest) (Nuget package)
- [Shouldly](https://github.com/shouldly/shouldly) (Nuget package)

[BasicPolygon2D]: (addons/basic_shape_creation/basic_polygon2d/basic_polygon2d.gd)
[BasicCollisionPolygon2D]: (addons/basic_shape_creation/basic_collision_polygon2d/basic_collision_polygon2d.gd)
[BasicGeometry2D]: (addons/basic_shape_creation/basic_geometry2d.gd)
