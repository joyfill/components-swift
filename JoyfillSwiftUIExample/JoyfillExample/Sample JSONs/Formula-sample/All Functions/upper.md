# upper Function

## Description
The `upper` function converts all lowercase characters in a string to uppercase. It leaves characters that are already uppercase, as well as numbers and special characters, unchanged.

## Syntax
```
upper(String)
```

### Parameters
- `String`: The string to convert to uppercase.

## Examples

### Basic Example
```
upper("joy")
```
This will return `"JOY"` by converting all lowercase characters to uppercase.

```
upper("Joyfill")
```
This will return `"JOYFILL"` by converting all lowercase characters to uppercase while leaving the already uppercase 'J' unchanged.

### Intermediate Example
```
upper(firstName)
```
This example converts the value in a field named "firstName" to uppercase. If `firstName` contains "John", it would return `"JOHN"`.

```
concat(upper(firstName), " ", upper(lastName))
```
This example combines the `upper` function with the `concat` function to create a full name in uppercase. If `firstName` is "John" and `lastName` is "Doe", it would return `"JOHN DOE"`.

### Advanced Example
```
if(
  contains(upper(userInput), upper(searchTerm)),
  concat("Found match for: ", searchTerm),
  "No match found"
)
```
This complex example demonstrates using the `upper` function for case-insensitive searching:
1. It converts both the user input and the search term to uppercase
2. Then checks if the uppercase user input contains the uppercase search term
3. If a match is found, it returns a message with the original search term
4. Otherwise, it returns "No match found"

This approach ensures that the search is case-insensitive, so searching for "joy" would match "Joy", "JOY", or "jOy".

## Resources
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/upper-function-c11f29b3-d1a3-4537-8df6-04d0049963d6f)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/upper/)