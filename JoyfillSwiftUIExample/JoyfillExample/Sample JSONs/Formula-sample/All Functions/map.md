# map Function

## Description
The `map` function creates a new array by applying a transformation function to each element in the original array. It processes each element one by one and returns a new array containing the results of calling the provided function on every element in the original array.

## Syntax
```
map(Array, Function(Any, Number))
```

### Parameters
- `Array`: The array to be processed.
- `Function(Any, Number)`: A callback function that is called for each element in the array.
  - The first parameter of the callback is the current element being processed.
  - The second parameter (optional) is the index of the current element.

## Examples

### Basic Example
```
map([1, 2, 3], (item) -> item * 2)
```
This will return `[2, 4, 6]` by multiplying each element in the array by 2.

```
map(["hello", "world"], (item) -> upper(item))
```
This will return `["HELLO", "WORLD"]` by converting each string to uppercase.

### Intermediate Example
```
map(products, (product) -> product.name)
```
This example extracts just the name property from each product object in an array. If `products` is `[{"name": "Laptop", "price": 999}, {"name": "Phone", "price": 699}]`, it would return `["Laptop", "Phone"]`.

```
map(numbers, (num, index) -> num + index)
```
This example adds the index to each element. If `numbers` is `[10, 20, 30]`, it would return `[10, 21, 32]` because it adds 0 to the first element, 1 to the second, and 2 to the third.

### Advanced Example
```
map(
  filter(products, (product) -> product.price < 500),
  (product) -> concat(product.name, " - $", product.price)
)
```
This complex example demonstrates combining `map` with `filter`:
1. First, it filters the products array to include only items with a price less than 500
2. Then, it maps each filtered product to a formatted string that includes the name and price

If `products` is `[{"name": "Laptop", "price": 999}, {"name": "Mouse", "price": 25}, {"name": "Keyboard", "price": 45}]`, it would return `["Mouse - $25", "Keyboard - $45"]`.

Another practical application is calculating values based on multiple arrays:

```
map(
  range(0, length(prices) - 1),
  (index) -> prices[index] * quantities[index]
)
```

This calculates the total price for each item by multiplying the price by the quantity at each index. If `prices` is `[10, 20, 30]` and `quantities` is `[2, 1, 3]`, it would return `[20, 20, 90]`.

## Resources
- [Microsoft Office MAP Function](https://support.microsoft.com/en-us/office/map-function-48006093-f97c-47c1-bfcc-749263bb1f01)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/map/)
- [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map)

## Notes
The Excel implementation of `map` can iterate over multiple arrays simultaneously, which differs from JavaScript where only one array can be iterated at a time. The Joyfill implementation follows the JavaScript approach.