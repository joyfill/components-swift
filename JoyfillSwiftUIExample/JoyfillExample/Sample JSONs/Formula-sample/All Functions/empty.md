# empty Function

## Description
The `empty` function returns `true` if its argument is empty, or has a value that equates to empty – including 0, false, "", and []. It's useful for checking if a field or variable has a value before using it in other operations.

## Syntax
```
empty(Any)
```

### Parameters
- `Any`: Any value or expression to check for emptiness.

## Examples

### Basic Example
```
empty("")
```
This will return `true` because an empty string is considered empty.

```
empty(0)
```
This will return `true` because 0 is considered an empty value.

```
empty([])
```
This will return `true` because an empty array is considered empty.

### Intermediate Example
```
empty(name)
```
This example checks if a field named "name" is empty. If the field contains no value, it returns `true`. If it contains any value (even a space), it returns `false`.

```
empty(selectedOptions)
```
This example checks if a field that might contain an array of selected options is empty. It returns `true` if no options are selected (empty array).

### Advanced Example
```
if(empty(email), "Please enter your email", 
  if(contains(email, "@"), "Valid email format", "Invalid email format")
)
```
This complex example demonstrates using the `empty` function in a conditional statement:
1. First, it checks if the email field is empty
2. If it's empty, it returns "Please enter your email"
3. If it's not empty, it checks if the email contains the "@" symbol
4. If it contains "@", it returns "Valid email format", otherwise "Invalid email format"

This is useful for form validation, ensuring that required fields are filled and properly formatted.

## Resources
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/empty/)