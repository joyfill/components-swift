# toNumber Function

## Description
The `toNumber` function converts its argument to a number if it can do so. It's useful for converting string representations of numbers into actual numeric values that can be used in calculations. If the conversion fails, it returns `NaN` (Not a Number).

## Syntax
```
toNumber(String)
```

### Parameters
- `String`: The string to convert to a number.

## Examples

### Basic Example
```
toNumber("100")
```
This will return `100` as a number, converting the string "100" to its numeric equivalent.

```
toNumber("100.11")
```
This will return `100.11` as a number, converting the string "100.11" to its numeric equivalent with decimal places.

### Intermediate Example
```
toNumber("-1")
```
This example converts a negative number string to a numeric value, returning `-1`.

```
toNumber(priceField) * quantity
```
This example converts a price field (which might be stored as text) to a number and then multiplies it by a quantity to calculate a total. If `priceField` contains "25.99" and `quantity` is 3, it would return `77.97`.

### Advanced Example
```
if(
  isNaN(toNumber(userInput)),
  "Please enter a valid number",
  if(
    toNumber(userInput) < 0,
    "Number cannot be negative",
    concat("Valid number: ", userInput)
  )
)
```
This complex example demonstrates using the `toNumber` function for input validation:
1. It attempts to convert the user input to a number
2. Checks if the result is `NaN` (not a number)
3. If it's not a valid number, it returns an error message
4. If it is a valid number, it checks if it's negative
5. If it's negative, it returns another error message
6. If it's a valid, non-negative number, it returns a success message

This approach provides comprehensive validation for numeric input fields.

## Resources
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/tonumber/)
- [Microsoft Office Support (VALUE function)](https://support.microsoft.com/en-us/office/value-function-257d0108-07dc-437d-ae1c-bc2d3953d8c2)