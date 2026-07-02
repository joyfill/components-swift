# every

## Description
The `every` function tests whether all elements in an array pass the test implemented by the provided callback function. It returns a boolean value - `true` if all elements pass the test, or `false` if any element fails.

## Syntax
```
every(array, callback)
```

## Parameters
- `array`: The array to test.
- `callback`: A function that tests each element. The callback takes up to three arguments:
  - `element`: The current element being processed.
  - `index` (optional): The index of the current element.
  - `array` (optional): The array being tested.

## Return Value
`true` if the callback function returns a truthy value for every array element; otherwise, `false`.

## Basic Example
Check if all numbers are greater than 5:
```
every([6, 7, 8, 9], (num) -> num > 5)
```
Result: `true`

```
every([4, 6, 8, 10], (num) -> num > 5)
```
Result: `false` (because 4 is not greater than 5)

## Intermediate Example
Check if all products are in stock:
```
// Assuming products is an array of objects with inStock property
every(products, (product) -> product.inStock)
```

Check if all elements at even indices are even numbers:
```
every([2, 3, 4, 5, 6, 7], (num, index) -> 
  if(mod(index, 2) == 0, mod(num, 2) == 0, true)
)
```
Result: `true` (elements at indices 0, 2, 4 are 2, 4, 6, which are all even)

## Advanced Example
Check if all employees in all departments meet a salary threshold:
```
// Check if all departments have all employees with salary > 30000
every(departments, (dept) -> 
  every(dept.employees, (emp) -> emp.salary > 30000)
)
```

Validate a form with multiple conditions:
```
// Check if a form is valid (all required fields are filled)
every(
  [
    !empty(form.name),
    !empty(form.email),
    contains(form.email, "@"),
    length(form.password) >= 8
  ],
  (condition) -> condition
)
```

Combining with other functions:
```
// Check if all filtered items meet a condition
every(
  filter(products, (product) -> product.category == "Electronics"),
  (product) -> product.warranty > 0
)
```

## Notes
- The `every` function returns `true` for any condition if the array is empty.
- The function stops executing once it finds an element for which the callback returns a falsy value.
- Unlike some implementations in programming languages, the callback cannot modify the original array.
- The `every` function is useful for validation scenarios where all conditions must be met.

## Resources
- [JavaScript Array.prototype.every()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every)
- [Lodash _.every](https://lodash.com/docs/4.17.15#every)
- [Python's all() function](https://docs.python.org/3/library/functions.html#all)