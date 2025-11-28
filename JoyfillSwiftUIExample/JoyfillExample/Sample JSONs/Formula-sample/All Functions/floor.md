# floor Function

## Description
The `floor` function returns the largest integer that is less than or equal to its argument. In other words, it rounds a number down to the nearest integer, regardless of the decimal part.

## Syntax
```
floor(Number)
```

### Parameters
- `Number`: The number to round down to the nearest integer.

## Examples

### Basic Example
```
floor(4.9)
```
This will return `4` because 4 is the largest integer less than or equal to 4.9.

```
floor(4)
```
This will return `4` because 4 is already an integer, so it remains unchanged.

### Intermediate Example
```
floor(-4.3)
```
This example demonstrates flooring a negative number, which returns `-5`. For negative numbers, flooring moves away from zero.

```
floor(totalAmount / itemPrice)
```
This example calculates how many complete items can be purchased with a given amount. If `totalAmount` is 50 and `itemPrice` is 12.99, it would return `3` (50 / 12.99 = 3.85 → 3), indicating you can buy 3 complete items.

### Advanced Example
```
if(
  inventoryType === "perishable",
  floor(daysRemaining / 7) * weeklyDiscount,
  if(
    inventoryType === "seasonal",
    floor(monthsRemaining) * monthlyDiscount,
    0
  )
)
```
This complex example demonstrates using the `floor` function in an inventory discount calculation:
1. If the inventory type is "perishable", it calculates how many complete weeks remain before expiration, and applies a weekly discount
2. If the inventory type is "seasonal", it calculates how many complete months remain in the season, and applies a monthly discount
3. Otherwise, it applies no discount (0)

This approach ensures that discounts are applied based on complete time periods, which is common in inventory management systems.

## Resources
- [Mozilla Developer Network (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/floor)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/floor/)