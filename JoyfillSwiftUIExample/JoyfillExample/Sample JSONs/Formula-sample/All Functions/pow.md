# pow Function

## Description
The `pow` function returns the result of a base number raised to a specified power (exponent). It's used for exponential calculations, allowing you to compute values like squares, cubes, and other powers.

## Syntax
```
pow(Base, Exponent)
```

### Parameters
- `Base`: The base number to be raised to a power.
- `Exponent`: The power to which the base number should be raised.

## Examples

### Basic Example
```
pow(2, 3)
```
This will return `8` because 2 raised to the power of 3 is 2 × 2 × 2 = 8.

```
pow(10, 2)
```
This will return `100` because 10 raised to the power of 2 is 10 × 10 = 100.

### Intermediate Example
```
pow(baseValue, exponentValue)
```
This example raises a base field value to the power of an exponent field value. If `baseValue` is 3 and `exponentValue` is 4, it would return `81` (3⁴ = 3 × 3 × 3 × 3 = 81).

```
pow(length, 2) * Math.PI
```
This example calculates the area of a circle by squaring the length (radius) and multiplying by π. If `length` is 5, it would return approximately `78.54` (5² × π = 25 × 3.14159... ≈ 78.54).

### Advanced Example
```
if(
  dimension === "area",
  pow(sideLength, 2),
  if(
    dimension === "volume",
    pow(sideLength, 3),
    if(
      dimension === "perimeter",
      sideLength * 4,
      "Invalid dimension"
    )
  )
)
```
This complex example demonstrates using the `pow` function for different geometric calculations:
1. If the dimension is "area", it calculates the area of a square (side length²)
2. If the dimension is "volume", it calculates the volume of a cube (side length³)
3. If the dimension is "perimeter", it calculates the perimeter of a square (side length × 4)
4. Otherwise, it returns an error message

This approach provides a versatile calculator for different geometric properties of a square/cube.

## Resources
- [Mozilla Developer Network (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/pow)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/built-ins/pow/)
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/power-function-d3f2908b-56f4-4c3f-895a-07fb519c362a)