# if Function

## Description
The `if` function allows you to write conditional statements that return different values based on whether a condition is true or false. It evaluates a Boolean expression and returns one value if the condition is true, and another value if the condition is false.

## Syntax
```
if(condition, valueIfTrue, valueIfFalse)
```

### Parameters
- `condition`: A Boolean expression that evaluates to either true or false.
- `valueIfTrue`: The value to return if the condition is true.
- `valueIfFalse`: The value to return if the condition is false.

## Examples

### Basic Example
```
if(true, "Hello World", "False")
```
This will return "Hello World" because the condition is true.

### Intermediate Example
```
if(age > 16, "Can Vote", "Cannot Vote")
```
This example checks if the value in a field named "age" is greater than 16. If it is, it returns "Can Vote", otherwise it returns "Cannot Vote".

### Advanced Example
```
if(gender == "Male", "Boy", if(gender == "Female", "Girl", "Unknown"))
```
This example demonstrates nested if functions. It checks if the "gender" field equals "Male". If true, it returns "Boy". If false, it evaluates another if function that checks if "gender" equals "Female". If that's true, it returns "Girl", otherwise it returns "Unknown".

## Resources
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/if-function-69aed7c9-4e8a-4755-a9bc-aa8bbff73be2)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/if/)