# and Function

## Description
The `and` function returns true if and only if all of its operands have a true Boolean value. Otherwise, it will return false. It accepts Boolean operands and can take multiple arguments.

## Syntax
```
and(Boolean, Boolean, Boolean, ...)
```

### Parameters
- `Boolean`: One or more Boolean expressions that evaluate to either true or false.

## Examples

### Basic Example
```
and(true, true)
```
This will return `true` because both operands are true.

```
and(true, false)
```
This will return `false` because one of the operands is false.

### Intermediate Example
```
and(10 > 5, "Male" === "Male")
```
This example checks if 10 is greater than 5 AND if the string "Male" is equal to "Male". Since both conditions are true, it returns `true`.

```
and(age > 18, gender === "Female")
```
This example checks if the value in a field named "age" is greater than 18 AND if the "gender" field equals "Female". It will return true only if both conditions are met.

### Advanced Example
```
and(
  length(name) > 0,
  age >= 18,
  or(country === "USA", country === "Canada"),
  not(hasVoted)
)
```
This complex example demonstrates combining multiple conditions and nested functions:
1. Checks if the name field is not empty
2. Checks if age is at least 18
3. Checks if country is either USA or Canada (using the `or` function)
4. Checks if the person has not voted (using the `not` function)

It will return true only if ALL of these conditions are true.

## Resources
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/and-function-5f19b2e8-e1df-4408-897a-ce285a19e9d9)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/built-ins/and/)