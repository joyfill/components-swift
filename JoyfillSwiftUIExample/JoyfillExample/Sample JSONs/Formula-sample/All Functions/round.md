# round Function

## Description
The `round` function is used to round a number to a specified number of decimal places or to the nearest whole number. If the decimal places parameter is omitted, it rounds to the nearest integer.

## Syntax
```
round(Number, ?Number)
```

### Parameters
- `Number`: The number to round.
- `?Number` (optional): The number of decimal places to round to. If omitted, rounds to the nearest integer (0 decimal places).

## Examples

### Basic Example
```
round(10.3)
```
This will return `10` by rounding 10.3 to the nearest integer.

```
round(10.7)
```
This will return `11` by rounding 10.7 to the nearest integer.

### Intermediate Example
```
round(10.7, 0)
```
This example explicitly specifies 0 decimal places, returning `11`.

```
round(10.71123, 2)
```
This example rounds to 2 decimal places, returning `10.71`.

### Advanced Example
```
round(
  sum(
    map(prices, (price) -> price * quantity),
    shipping
  ) * (1 + taxRate / 100),
  2
)
```
This complex example demonstrates using the `round` function in a financial calculation:
1. It maps over an array of prices, multiplying each by a quantity
2. Sums all the products together with shipping
3. Applies a tax rate to the total
4. Rounds the final amount to 2 decimal places (currency format)

This approach ensures that financial calculations display appropriate precision without showing too many decimal places.

## Resources
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/round-function-c018c5d8-40fb-4053-90b1-b3e7f61a213c)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/round/)
- [Mozilla Developer Network (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/round)