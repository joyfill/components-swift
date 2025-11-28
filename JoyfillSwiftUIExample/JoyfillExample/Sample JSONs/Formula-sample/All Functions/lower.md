# lower Function

## Description
The `lower` function converts all uppercase characters in a string to lowercase. It leaves characters that are already lowercase, as well as numbers and special characters, unchanged.

## Syntax
```
lower(String)
```

### Parameters
- `String`: The string to convert to lowercase.

## Examples

### Basic Example
```
lower("JOY")
```
This will return `"joy"` by converting all uppercase characters to lowercase.

```
lower("Joyfill")
```
This will return `"joyfill"` by converting all uppercase characters to lowercase while leaving the already lowercase characters unchanged.

### Intermediate Example
```
lower(productName)
```
This example converts the value in a field named "productName" to lowercase. If `productName` contains "Premium SUBSCRIPTION", it would return `"premium subscription"`.

```
concat(firstName, " ", lower(lastName))
```
This example combines a field with the `lower` function to create a name where the last name is in lowercase. If `firstName` is "John" and `lastName` is "DOE", it would return `"John doe"`.

### Advanced Example
```
if(
  equals(lower(userInput), lower(expectedValue)),
  "Input matches expected value (case-insensitive)",
  concat("Input does not match. Expected: ", expectedValue)
)
```
This complex example demonstrates using the `lower` function for case-insensitive comparison:
1. It converts both the user input and the expected value to lowercase
2. Then checks if they are exactly equal (case-insensitive comparison)
3. If they match, it returns a success message
4. Otherwise, it returns an error message with the expected value

This approach ensures that the comparison is case-insensitive, so "Hello" would match "HELLO", "hello", or "Hello".

## Resources
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/lower-function-3f21df02-a80c-44b2-afaf-81358f9fdeb4)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/lower/)