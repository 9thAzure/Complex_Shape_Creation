# Test Style Guide
this is the style guide for the tests written in the [/tests] folder. 

### Testing plugins used
gdscript:
- [GUT]

c# (as nuget packages):
- [Chickensoft.GoDotTest](https://github.com/chickensoft-games/GoDotTest)
- [shouldly](https://github.com/shouldly/shouldly)

## Format and Naming
Files be in sub-folders within [/tests] folder
and should named in the format: `test_class_name.gd`.

Methods should be named in the format: 
`test_method_name__scenario__expected_result`.
The tests should be separated into 3 parts: *arrange, act, assert*.

Member variables are declared first, 
then the methods `before_each`, `before_all`, etc,
then the test methods.
Preferably, the methods under test appear in the same order as in the class script.
```swift
# calculator.gd
extends Node

func add(num1 : int, num2 : int) -> int:
    return num1 + num2

func subtract(num1 : int, num2 : int) -> int:
    return num1 - num2
```
```swift
# test_calculator.gd
extends GutTest

var class_script := preload("res://calculator.gd")

func test_add__1_and_1__returns_2():
    var calculator := class_script.new()

    var result := calculator.add(1, 1)

    assert_eq(result, 2, "Result should be 2.")

func test_subtract__2_and_1__returns_1():
    var calculator := class_script.new()

    var result := calculator.subtract(2, 1)

    assert_eq(result, 1, "Result should be 1.")
```

> [!NOTE]
the reason `test_` is prefixed to files and methods
is because that is what [GUT] looks for when finding 
tests.

## Gut Features Style Guide
### Asserts
Always use the message parameters of asserts to provide better context, like so:
```swift
assert_eq(polygon.size(), 4, "Property 'polygon' should be of size 4.")
```

### Doubles
The creation of doubles should be done in line. Static typing should still be used.
```swift
var calculator : Calculator = double(class_script).new()
```

`ignore_method_when_doubling` for static methods should be put in the `before_each` method. 
`_init` methods should also be ignored if they use default parameters (all of them currently do).
```swift
func before_each():
    ignore_method_when_doubling(class_script, "static_method")
    ignore_method_when_doubling(class_script, "_init")
```

### Auto Freeing
`autofree()` and variants should be done in line
with static typing.
```swift
var node : Node = autoqfree(Node.new())
```

### Parameterized Tests
The name of the parameter should be `p`,
and the array used in `use_parameters()` should be in-line,
unless it is too big.
```swift
func test_add__param_and_0__returns_param(p = use_parameters([1, 2, 3, 4])):
```

## C#
Besides testing [interop](/tests/c#_interop/), c# shouldn't be used for any other unit tests.

Only the guidelines under **format and naming** apply to c# tests. 
The assertion default messages are generally better, so customs ones are not required.

[/tests]: (/tests/)
[GUT]: (https://github.com/bitwes/Gut)
