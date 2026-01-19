# not Function

## Description
The `not` function inverts the truth value of a Boolean value. Another way of thinking about it is that it returns true only if its operand is false. It accepts a single Boolean operand and returns the opposite Boolean value.

## Syntax
```
not(Boolean)
```

### Parameters
- `Boolean`: A Boolean expression that evaluates to either true or false.

## Examples

### Basic Example
```
not(true)
```
This will return `false` because the operand is true, and the `not` function inverts it.

```
not(false)
```
This will return `true` because the operand is false, and the `not` function inverts it.

### Intermediate Example
```
not(10 > 5)
```
This example checks if 10 is greater than 5, which is true, and then inverts it. So it returns `false`.

```
not(age < 18)
```
This example checks if the value in a field named "age" is less than 18, and then inverts the result. If age is 15, the expression would return `false` (because 15 < 18 is true, and `not` inverts it). If age is 20, the expression would return `true` (because 20 < 18 is false, and `not` inverts it).

### Advanced Example
```
not(
  and(
    status === "Active",
    or(
      country === "USA",
      country === "Canada"
    ),
    age >= 18
  )
)
```
This complex example demonstrates combining multiple conditions and nested functions:
1. The inner `and` function checks if:
   - The status is "Active"
   - The country is either "USA" or "Canada" (using the `or` function)
   - The age is at least 18
2. The `not` function then inverts the result of this entire check

This would return `true` if any of the conditions in the `and` function are false, effectively checking if someone is NOT an active adult from USA or Canada.

## Resources
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/built-ins/not/)
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/not-function-9cfc6011-a054-40c7-a140-cd4ba2d87d77)