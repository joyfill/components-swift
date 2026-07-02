# countIf

## Description
The `countIf` function counts the number of items in an array that match a specified criterion. It's useful for analyzing data collections and performing conditional counting operations.

## Syntax
```
countIf(array, criterion)
```

### Parameters
- `array` (Array) - The array of values to search through.
- `criterion` (String) - The value to match against each item in the array.

### Return Value
Returns a number representing the count of items in the array that match the criterion.

## Examples

### Basic Example
Counting occurrences of a specific string in an array:

```
countIf(["joy", "Joyfill", "hello"], "joy")
```

Output: `2`

This counts how many times the string "joy" appears in the array. Note that the function performs a case-insensitive search, so both "joy" and "Joyfill" (which contains "joy") are counted.

### Intermediate Example
Using `countIf` with field references:

```
countIf(selectedOptions, "Yes")
```

If `selectedOptions` is an array like `["Yes", "No", "Yes", "Maybe", "Yes"]`, this would return 3 (the number of times "Yes" appears in the array).

You can also use it to count items that match a specific pattern:

```
countIf(productCategories, "electronics")
```

This would count how many items in the `productCategories` array contain the string "electronics".

### Advanced Example
Using `countIf` for data analysis and decision making:

```
if(countIf(responses, "Positive") > countIf(responses, "Negative"), "Overall Positive Feedback", "Needs Improvement")
```

This compares the count of "Positive" responses to "Negative" responses and returns an appropriate message based on which is greater.

You can also use `countIf` in more complex calculations, such as determining the percentage of items that match a criterion:

```
(countIf(answers, "Correct") / length(answers)) * 100
```

This calculates the percentage of correct answers in a test.

## Resources
- [Microsoft Office COUNTIF Function](https://support.microsoft.com/en-us/office/countif-function-e0de10c6-f885-4e71-abb4-1f464816df34)

## Notes
The `countIf` function in Joyfill performs a case-insensitive substring match, meaning it will count an item if the criterion appears anywhere within the item's string value.