# max

## Description
The `max` function returns the greatest value from a set of numbers. It can accept individual numbers, arrays of numbers, or a combination of both as arguments.

## Syntax
```
max(number1, [number2, ...])
max([number1, number2, ...])
max(number1, [number2, ...], number3, ...)
```

### Parameters
- `number1, number2, ...` (Number) - Individual number values to compare.
- `[number1, number2, ...]` (Array of Numbers) - An array of numbers to compare.

### Return Value
Returns the largest number from all provided values.

## Examples

### Basic Example
Finding the maximum value among individual numbers:

```
max(10, 14, 3)
```

Output: `14`

### Intermediate Example
Finding the maximum value in an array of numbers:

```
max([10, 14, 3])
```

Output: `14`

You can also mix individual numbers and arrays:

```
max(10, [14, 3])
```

Output: `14`

Using field references:

```
max(price1, price2, price3)
```

If `price1` is 25, `price2` is 30, and `price3` is 15, this would return 30.

### Advanced Example
Using `max` to determine the highest score in a set of test scores and then calculating a grade curve:

```
if(score >= max([score1, score2, score3, score4, score5]) - 10, "A", 
  if(score >= max([score1, score2, score3, score4, score5]) - 20, "B", 
    if(score >= max([score1, score2, score3, score4, score5]) - 30, "C", 
      if(score >= max([score1, score2, score3, score4, score5]) - 40, "D", "F"))))
```

This formula uses the maximum score as a reference point and assigns letter grades based on how close other scores are to the maximum.

Another practical application is finding the maximum value in a dynamic range:

```
max(concat([baseValue], additionalValues))
```

This combines a base value with an array of additional values and finds the maximum among all of them.

## Resources
- [Thomas J Frank MAX Function](https://thomasjfrank.com/formulas/functions/max/)
- [Microsoft Office MAX Function](https://support.microsoft.com/en-us/office/max-function-e0012414-9ac8-4b34-9a47-73e662c08098)