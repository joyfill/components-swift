# length

## Description
The `length` function returns the total length of an Array or String. For strings, it counts the number of characters, and for arrays, it counts the number of elements.

## Syntax
```
length(value)
```

### Parameters
- `value` (String or Array) - The string or array whose length you want to determine.

### Return Value
Returns a number representing the length of the input string or array.

## Examples

### Basic Example
Finding the length of a string:

```
length("Joyfill")
```

Output: `7`

Finding the length of an array:

```
length(['opt1', 'opt2'])
```

Output: `2`

### Intermediate Example
Using the `length` function with field references:

```
length(userName)
```

If `userName` is "John Smith", this would return 10 (the number of characters, including the space).

You can also use it to check the number of items in a dynamic array:

```
length(selectedOptions)
```

If `selectedOptions` is an array like `["Option 1", "Option 2", "Option 3"]`, this would return 3.

### Advanced Example
Using `length` in conditional logic to validate input:

```
if(length(phoneNumber) < 10, "Please enter a valid phone number", "Valid")
```

This checks if a phone number has at least 10 digits and returns an appropriate message.

You can also use `length` in more complex expressions, such as calculating the average length of multiple strings:

```
(length(firstName) + length(lastName) + length(middleName)) / 3
```

Or to dynamically adjust UI elements based on content length:

```
if(length(description) > 100, "Long description", "Short description")
```

## Resources
- [Thomas J Frank LENGTH Function](https://thomasjfrank.com/formulas/functions/length/)

## Notes
Unlike Excel, which has separate functions for strings (`LEN`) and arrays, the `length` function in Joyfill works with both data types.