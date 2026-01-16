# filter

## Description
The `filter` function creates a new array containing all elements from the original array that satisfy a specified condition. It evaluates each element against a provided callback function and includes only those elements for which the callback returns `true`.

## Syntax
```
filter(array, callback)
```

## Parameters
- `array`: The array to filter.
- `callback`: A function that tests each element. The callback takes up to three arguments:
  - `element`: The current element being processed.
  - `index` (optional): The index of the current element.
  - `array` (optional): The array being filtered.

## Return Value
A new array containing only the elements that pass the test implemented by the callback function. If no elements pass the test, an empty array is returned.

## Basic Example
Filter numbers greater than 5:
```
filter([2, 5, 8, 12, 3], (num) -> num > 5)
```
Result: `[8, 12]`

Filter non-empty strings:
```
filter(["apple", "", "banana", "", "cherry"], (str) -> !empty(str))
```
Result: `["apple", "banana", "cherry"]`

## Intermediate Example
Filter products with price less than 50:
```
// Assuming products is an array of objects with name and price properties
filter(products, (product) -> product.price < 50)
```

Filter elements at even indices:
```
filter([10, 20, 30, 40, 50], (num, index) -> mod(index, 2) == 0)
```
Result: `[10, 30, 50]` (elements at indices 0, 2, 4)

## Advanced Example
Combining filter with other functions:
```
// Get the names of products under $100
map(
  filter(products, (product) -> product.price < 100),
  (product) -> product.name
)
```

Filtering with multiple conditions:
```
// Find products that are both in stock and on sale
filter(products, (product) -> product.inStock && product.onSale)
```

Filtering nested arrays:
```
// Find departments with at least one employee who has a salary over 50000
filter(departments, (dept) -> 
  length(
    filter(dept.employees, (emp) -> emp.salary > 50000)
  ) > 0
)
```

## Notes
- The filter function does not modify the original array.
- If the callback function doesn't return a boolean value, the result will be coerced to a boolean.
- Unlike some implementations in programming languages, the callback cannot be used to remove or skip elements by returning `null` or `undefined` - it must return a boolean value.

## Resources
- [Microsoft Excel FILTER function](https://support.microsoft.com/en-us/office/filter-function-f4f7cb66-82eb-4767-8f7c-4877ad80c759)
- [JavaScript Array.prototype.filter()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter)
- [Thomas J. Frank's FILTER function in Google Sheets](https://thomasjfrank.com/google-sheets-filter-function/)