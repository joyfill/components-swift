# sqrt Function

## Description
The `sqrt` function returns the square root of its argument. It calculates the number which, when multiplied by itself, gives the input value.

## Syntax
```
sqrt(Number)
```

### Parameters
- `Number`: The number to calculate the square root of. Should be a non-negative number.

## Examples

### Basic Example
```
sqrt(16)
```
This will return `4` because 4 × 4 = 16.

```
sqrt(100)
```
This will return `10` because 10 × 10 = 100.

### Intermediate Example
```
sqrt(area)
```
This example calculates the square root of a field named "area". If `area` is 25, it would return `5`.

```
sqrt(pow(x, 2) + pow(y, 2))
```
This example calculates the hypotenuse of a right triangle using the Pythagorean theorem. If `x` is 3 and `y` is 4, it would return `5` (the square root of 9 + 16 = 25).

### Advanced Example
```
if(
  number < 0,
  "Cannot calculate square root of negative number",
  concat("The square root of ", number, " is ", sqrt(number))
)
```
This complex example demonstrates:
1. Checking if the input number is negative
2. If it is negative, returning an error message
3. If it is non-negative, calculating the square root and returning a formatted message

This approach ensures proper error handling when dealing with square roots, which are undefined for negative numbers in the real number system.

## Resources
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/sqrt/)
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/sqrt-function-654975c2-05c4-4831-9a24-2c65e4040fdf)
- [Mozilla Developer Network (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/sqrt)