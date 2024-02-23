# Test Guide

This is a short guide to using the tests in this [folder](/tests/).

## Plugins Used

- [GUT](https://github.com/bitwes/Gut) - GDScript unit testing
- [Chickensoft.GoDotTest](https://github.com/chickensoft-games/GoDotTest) - C# unit testing
- [Shouldly](https://github.com/shouldly/shouldly) - C# assertions

## Types of Tests

The tests are organized into folders based on what they do.

### [unit_tests](/tests/unit_tests/)

The proper unit tests, testing the functionality of the nodes and functions.

To run, go to the `GUT` window of the terminal, then press `Run All`.
More info can be found [here](https://gut.readthedocs.io/en/latest/Install.html#running-tests)

### [c#_interop](/tests/c#_interop/)

As the name suggest, these are unit tests specifically for the interop between the C# wrapper classes and GDScript core.

To run, open and run [test_runner.tscn](/tests/c#_interop/test_runner.tscn).
The results will be outputted into the standard `Output`.
By default, the scene will automatically close once tests are done.

### [visual_tests](/tests/visual_tests/)

Due to the nature of the project, it's incredibly hard, if not impossible, to unit test everything.
This folder contains scenes which automatically modulate over the properties of every node.
This is for manual inspection for how the properties interact with each other.

A variety of user defined scripts and `AnimationPlayer` nodes are used. 
Most can be played in editor, `AnimationPlayer` nodes via the `Animation` window, and user defined scripts by an exported property like `is_on`.
however, the [table_display](/tests/visual_tests/table_display.gd) node requires the scene to be run.

For more info on how to use the user defined scripts, checkout the [Script Guide](/tests/visual_tests/script_guide.md).
