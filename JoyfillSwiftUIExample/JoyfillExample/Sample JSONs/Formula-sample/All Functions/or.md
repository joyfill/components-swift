# or Function

## Description
The `or` function returns true if any of its operands are true. It accepts Boolean operands and can take multiple arguments. If at least one of the conditions evaluates to true, the function returns true; otherwise, it returns false.

## Syntax
```
or(Boolean, Boolean, Boolean, ...)
```

### Parameters
- `Boolean`: One or more Boolean expressions that evaluate to either true or false.

## Examples

### Basic Example
```
or(true, false)
```
This will return `true` because at least one operand (the first one) is true.

```
or(false, false)
```
This will return `false` because none of the operands are true.

### Intermediate Example
```
or(10 < 5, "Male" === "Male")
```
This example checks if 10 is less than 5 OR if the string "Male" is equal to "Male". Since the second condition is true (even though the first is false), it returns `true`.

```
or(age < 18, status === "Student")
```
This example checks if the value in a field named "age" is less than 18 OR if the "status" field equals "Student". It will return true if either condition is met.

### Advanced Example
```
or(
  and(age >= 65, country === "USA"),
  and(age >= 60, country === "Canada"),
  and(status === "Disabled", age >= 18)
)
```
This complex example demonstrates combining multiple conditions and nested functions to check eligibility:
1. Checks if the person is 65 or older AND from the USA
2. OR if the person is 60 or older AND from Canada
3. OR if the person has "Disabled" status AND is 18 or older

It will return true if ANY of these combined conditions are true, making it useful for complex eligibility rules.

## Resources
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/or-function-7d17ad14-8700-4281-b308-00b131e22af0)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/built-ins/or/)