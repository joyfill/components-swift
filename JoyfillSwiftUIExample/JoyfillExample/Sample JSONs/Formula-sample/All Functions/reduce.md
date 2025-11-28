# reduce

## Description
The `reduce` function applies a callback function to each element in an array, resulting in a single output value. It processes the array from left to right, accumulating a result by combining each element with the running total.

## Syntax
```
reduce(array, callback, initialValue)
```

## Parameters
- `array`: The array to reduce.
- `callback`: A function that processes each element. The callback takes up to four arguments:
  - `accumulator`: The accumulated result from previous iterations.
  - `currentValue`: The current element being processed.
  - `index` (optional): The index of the current element.
  - `array` (optional): The array being reduced.
- `initialValue` (optional): A value to use as the first argument to the first call of the callback. If no initial value is provided, the first element of the array is used as the initial accumulator value.

## Return Value
The single value that results from the reduction.

## Basic Example
Sum all numbers in an array:
```
reduce([1, 2, 3, 4], (acc, num) -> acc + num, 0)
```
Result: `10` (0 + 1 + 2 + 3 + 4)

Find the maximum value in an array:
```
reduce([5, 9, 2, 7], (max, num) -> if(num > max, num, max), -Infinity)
```
Result: `9`

## Intermediate Example
Calculate the total price of all products:
```
// Assuming products is an array of objects with price properties
reduce(products, (total, product) -> total + product.price, 0)
```

Concatenate strings with a separator:
```
reduce(["Hello", "World", "!"], (result, str, index) -> 
  if(index == 0, str, concat(result, " ", str)), "")
```
Result: `"Hello World !"`

## Advanced Example
Group objects by a property:
```
// Group people by age
reduce(people, (result, person) -> {
  age = person.age;
  if(empty(result[age]), 
    result[age] = [person], 
    result[age] = concat(result[age], [person])
  );
  return result;
}, {})
```

Calculate statistics in a single pass:
```
// Calculate sum, count, min, max, and average in one reduce operation
reduce(numbers, (stats, num) -> {
  stats.sum = stats.sum + num;
  stats.count = stats.count + 1;
  stats.min = if(num < stats.min, num, stats.min);
  stats.max = if(num > stats.max, num, stats.max);
  stats.avg = stats.sum / stats.count;
  return stats;
}, {sum: 0, count: 0, min: Infinity, max: -Infinity, avg: 0})
```

Create a frequency map:
```
// Count occurrences of each item
reduce(["apple", "banana", "apple", "orange", "banana", "apple"], 
  (freq, fruit) -> {
    freq[fruit] = if(empty(freq[fruit]), 1, freq[fruit] + 1);
    return freq;
  }, {})
```
Result: `{"apple": 3, "banana": 2, "orange": 1}`

## Notes
- The reduce function is extremely versatile and can be used to implement many other array operations like map, filter, find, etc.
- When using an object as the accumulator, make sure to return the accumulator at the end of each callback iteration.
- If no initial value is provided and the array is empty, an error will be thrown.
- For complex operations, it's often clearer to use separate map/filter operations rather than a single complex reduce.

## Resources
- [JavaScript Array.prototype.reduce()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce)
- [Lodash _.reduce](https://lodash.com/docs/4.17.15#reduce)
- [Understanding the Reduce Method in JavaScript](https://www.digitalocean.com/community/tutorials/js-finally-understand-reduce)