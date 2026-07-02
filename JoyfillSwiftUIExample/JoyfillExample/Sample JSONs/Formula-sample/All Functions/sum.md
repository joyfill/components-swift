# sum Function

## Description
The `sum` function returns the sum of its arguments. It accepts only numbers and lists of numbers, or a combination of the two. This function is essential for performing addition operations on numeric values or arrays of numbers.

## Syntax
```
sum(Number|Number[], Number, ...)
```

### Parameters
- `Number|Number[]`: One or more numbers or arrays of numbers to sum.

## Examples

### Basic Example
```
sum(10, 20, 30)
```
This will return `60` by adding the three numbers together.

```
sum([10, 20, 30])
```
This will return `60` by adding all the numbers in the array.

### Intermediate Example
```
sum(subtotal, tax)
```
This example adds two field values together. If `subtotal` is 100 and `tax` is 8, it would return `108`.

```
sum([price1, price2, price3], shipping)
```
This example adds an array of price fields plus a shipping field. If the prices are [25, 30, 15] and shipping is 10, it would return `80`.

### Advanced Example
```
sum(
  map(lineItems, (item) -> item.quantity * item.price),
  if(includeShipping, shippingCost, 0),
  if(includeInsurance, insuranceCost, 0)
)
```
This complex example demonstrates:
1. Using `map` to calculate the total for each line item (quantity × price)
2. Summing all line item totals
3. Conditionally adding shipping cost if `includeShipping` is true
4. Conditionally adding insurance cost if `includeInsurance` is true

This approach provides a comprehensive calculation for an order total with optional components.

## Resources
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/sum/)
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/sum-function-043e1c7d-7726-4e80-8f32-07b23e057f89)