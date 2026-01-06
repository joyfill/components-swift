# flatMap Function

## Description
The `flatMap` function returns a new array formed by applying a given callback function to each element of the array, and then flattening the result by one level. It combines the functionality of `map` and `flat` into a single operation, which is both more efficient and more readable when you need to map over an array and then flatten the result.

## Syntax
```
flatMap(Array, Function(Any, Number))
```

### Parameters
- `Array`: The array to process.
- `Function(Any, Number)`: A callback function that produces an element of the new array. It takes two arguments:
  * `Any`: The current element being processed in the array.
  * `Number` (optional): The index of the current element being processed.

The callback function should return an array containing new elements of the new array, or a single non-array value to be added to the new array.

## Examples

### Basic Example
```
flatMap([1, 2, 3], (item) -> [item, item])
```
This will return `[1, 1, 2, 2, 3, 3]` by duplicating each element and then flattening the result.

```
flatMap([1, 2, 3], (item) -> item * 2)
```
This will return `[2, 4, 6]`, which is the same as using `map` since the callback returns non-array values.

### Intermediate Example
```
flatMap(["Hello", "world"], (word) -> word.split(""))
```
This example splits each word into its individual characters and flattens the result. It returns `["H", "e", "l", "l", "o", "w", "o", "r", "l", "d"]`.

```
flatMap(products, (product) -> 
  if(product.inStock, [product.name], [])
)
```
This example filters and maps in a single operation. It returns an array containing only the names of products that are in stock, skipping out-of-stock items by returning an empty array for them.

### Advanced Example
```
flatMap(
  orders,
  (order) -> 
    if(order.status === "shipped",
      map(order.items, (item) -> 
        concat(order.id, ": ", item.name, " (", item.quantity, ")")
      ),
      []
    )
)
```
This complex example demonstrates:
1. Filtering orders to only include those with "shipped" status
2. For each shipped order, mapping over its items to create formatted strings
3. Flattening the result to get a single array of all shipped items across all orders

This approach is more efficient than using separate filter, map, and flat operations, especially for large datasets.

## Resources
- [Mozilla Developer Network (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/flatMap)