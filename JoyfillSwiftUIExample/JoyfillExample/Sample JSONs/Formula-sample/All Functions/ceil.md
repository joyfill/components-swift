# ceil Function

## Description
The `ceil` function returns the smallest integer that is greater than or equal to its argument. In other words, it rounds a number up to the nearest integer, regardless of the decimal part.

## Syntax
```
ceil(Number)
```

### Parameters
- `Number`: The number to round up to the nearest integer.

## Examples

### Basic Example
```
ceil(4.2)
```
This will return `5` because 5 is the smallest integer greater than 4.2.

```
ceil(4)
```
This will return `4` because 4 is already an integer, so it remains unchanged.

### Intermediate Example
```
ceil(-4.7)
```
This example demonstrates ceiling a negative number, which returns `-4`. For negative numbers, ceiling moves toward zero.

```
ceil(itemPrice * quantity * (1 + taxRate / 100))
```
This example calculates a total price with tax and rounds up to the nearest whole number. If `itemPrice` is 19.99, `quantity` is 2, and `taxRate` is 8.25, it would return `44` (19.99 × 2 × 1.0825 = 43.2784 → 44).

### Advanced Example
```
if(
  shippingMethod === "express",
  ceil(packageWeight) * expressRate,
  if(
    shippingMethod === "standard",
    ceil(packageWeight / 2) * standardRate,
    "Invalid shipping method"
  )
)
```
This complex example demonstrates using the `ceil` function in a shipping cost calculation:
1. If the shipping method is "express", it rounds up the package weight to the nearest whole number and multiplies by the express rate
2. If the shipping method is "standard", it divides the package weight by 2 (since standard shipping allows two items per weight unit), rounds up, and multiplies by the standard rate
3. Otherwise, it returns an error message

This approach ensures that shipping costs are always rounded up to the next weight unit, which is common in shipping calculations.

## Resources
- [Mozilla Developer Network (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/ceil)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/ceil/)