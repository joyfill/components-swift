# contains Function

## Description
The `contains` function tests whether the first argument contains the second argument. This search is not case-sensitive. It returns a boolean value: `true` if the first string contains the second string, and `false` otherwise.

## Syntax
```
contains(String, String)
```

### Parameters
- `String` (first argument): The string to search within.
- `String` (second argument): The substring to search for.

## Examples

### Basic Example
```
contains("Joyfill Rocks", "rock")
```
This will return `true` because "Joyfill Rocks" contains "rock" (case-insensitive).

```
contains("Joyfill Rocks", "test")
```
This will return `false` because "Joyfill Rocks" does not contain "test".

### Intermediate Example
```
contains(productName, "premium")
```
This example checks if a field named "productName" contains the word "premium". It will return `true` if the product name includes "premium" (in any case), and `false` otherwise.

```
if(contains(email, "@"), "Valid email format", "Invalid email format")
```
This example uses the `contains` function within an `if` statement to check if an email address contains the "@" symbol, which is a basic validation for email format.

### Advanced Example
```
and(
  contains(fullName, firstName),
  contains(fullName, lastName),
  not(contains(blockedWords, userInput))
)
```
This complex example demonstrates combining multiple conditions:
1. Checks if `fullName` contains `firstName`
2. Checks if `fullName` also contains `lastName`
3. Checks that `userInput` does not contain any words from a `blockedWords` list

This could be used for validation that ensures a full name contains both first and last names, while also ensuring user input doesn't contain inappropriate content.

## Resources
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/contains/)