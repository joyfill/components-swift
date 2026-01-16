# concat Function

## Description
The `concat` function concatenates (combines) its arguments. It accepts one or more Array or String arguments, and outputs a single combined result. When used with arrays, it joins them into a single array. When used with strings, it combines them into a single string.

## Syntax
```
concat(String|Array, String|Array, ...)
```

### Parameters
- `String|Array`: One or more strings or arrays to concatenate.

## Examples

### Basic Example
```
concat("joy", "fill")
```
This will return `"joyfill"` by combining the two strings.

```
concat("joy", " ", "fill", " ", "rocks")
```
This will return `"joyfill rocks"` by combining all the strings.

### Intermediate Example
```
concat([1, 2], [3, 4])
```
This example combines two arrays into a single array. It returns `[1, 2, 3, 4]`.

```
concat("User: ", userName, " (", userRole, ")")
```
This example combines strings with field values to create a formatted string. If `userName` is "John" and `userRole` is "Admin", it would return `"User: John (Admin)"`.

### Advanced Example
```
concat(
  "Report for ",
  date(year(now()), month(now()), day(now())),
  ": ",
  if(empty(selectedItems), 
    "No items selected", 
    concat("Selected ", length(selectedItems), " items: ", 
      concat(selectedItems)
    )
  )
)
```
This complex example demonstrates:
1. Combining static strings with dynamic values
2. Using nested `concat` functions
3. Using the `concat` function with conditional logic
4. Formatting a date using date functions
5. Handling arrays and converting them to strings

If `selectedItems` is `["Item1", "Item2"]`, it might return something like:
`"Report for 2023-05-15: Selected 2 items: Item1,Item2"`

## Resources
- [Microsoft Office Support](https://support.microsoft.com/en-us/office/concat-function-9b1a9a3f-94ff-41af-9736-694cbd6b4ca2)
- [Thomas J. Frank Documentation](https://thomasjfrank.com/formulas/functions/concat/)