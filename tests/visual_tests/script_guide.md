# Visual Tests Script Guide

A guide to the scripts used in [this](/tests/visual_tests/) folder.

## [animation_manager.gd](/tests/visual_tests/animation_manager.gd)

This is normally the root node of scenes in [visual_test](/tests/visual_tests/).
It enables/disables `AnimationPlayer` and [random_modulate] nodes,
as well as reset the animated shapes.

It runs in the editor and inherits `Node`.

### enable_all

Enables/disables `AnimationPlayer` and [random_modulate] nodes that are children to it.
It will also print a message if there is a node it does not expect (`AnimationPlayer`, [random_modulate], [table_display](/tests/visual_tests/table_display.gd)).

If enabling an `AnimationPlayer` node, it will play the first animation that isn't `"RESET"`.

### reset

Attempts to reset all nodes under its children to their default state. It always returns `false`.

For `AnimationPlayer`s, it will set the animation to the beggining of the track.

For [random_modulate], it will reset properties in mentioned `random_modulate.properties` to their default value.
If it cannot obtain a value (for instance, a non-script variable), it will use an alternate value:
- `0` if there is no script
- `Color.WHITE` if the variable is of type `Color`
- `Vector2.ZERO` if the variable is of type `Vector2`
- the starting value of `random_modulate.properties`

> [!NOTE]
> `reset` does not set the animations of `AnimationPlayers`to a valid state like `enable_all` does,
> and may fail to reset it if no animation is selected.
> enable and disable `enable_all` before using `reset` to fix this.

### auto_play

If true, [animation_manager](/tests/visual_tests/animation_manager.gd) will enable all children nodes when the scene is run.


## [random_modulate.gd](/tests/visual_tests/random_modulate.gd)

Randomly modulates specific properties of a node with the given range one by one.

It runs in the editor and inherits `Node`.

### node_path

The path to the node to modulate

### properties

Provides the properties of the node to modulate and the range.

This property enforces a strict style:
- Each inner array is of size 3
- The first element of each inner array is always a string
- The second and third element must be the same type (If they are different, the second element is assigned to the third)

The first element contains the name of the property to modulate.
The second and third element indicates the lower and upper bounds to modulate by.

If the modulated type is `Color` or `Vector2`, it will modulate the internal properties individually.

### max_time

The maximum allowed time that the transition takes.

There is a minimum time of 0.5s.

### is_on

Starts/stops modulation of the node.


## [table_display.gd](/tests/visual_tests/table_display.gd)

When the scene is run, it will generate a table of the specified script where each node has 2 properties being modulated.
It assumes the script is inherited from `Node2D`.

It inherits `Node2D`.

### test_script

The script to generate the table with.

It will provide an error if the script is not inherited from `Node2D`.

### spacing

The space between each node.

### max_time

The maximum allowed time that the transition takes.

There is a minimum time of 0.5s.

### properties

Provides the properties of the node to modulate and the range.

This property enforces a strict style:
- Each inner array is of size 3
- The first element of each inner array is always a string
- The second and third element must be the same type (If they are different, the second element is assigned to the third)

The first element contains the name of the property to modulate.
The second and third element indicates the lower and upper bounds to modulate by.

If the modulated type is `Color` or `Vector2`, it will modulate the internal properties individually.

### defaults

A dictionary of values to set to specific properties of all scripts.
The key is the name of the property, the value is the value to set to that property.

If the value is an array of size 2 where the first element is a `int`, `string`, or `StringName`,
It will use that value as a filter, applying the second element to scripts
where one of their properties modulated is the same as the first element / same index in `properties``.

[random_modulate]: (/tests/visual_tests/random_modulate.gd)
