# year

## Description
The `year` function extracts the year component from a date value. It returns the year as a number, making it useful for date calculations, filtering, and formatting.

## Syntax
```
year(date)
```

### Parameters
- `date` (Date) - The date from which to extract the year.

### Return Value
Returns a number representing the year of the provided date.

## Examples

### Basic Example
Extracting the year from a specific date:

```
year(date(2023, 5, 15))
```

Output: `2023`

You can also use it with the current date:

```
year(now())
```

This would return the current year (e.g., `2023`).

### Intermediate Example
Using the `year` function with field references:

```
year(birthDate)
```

If `birthDate` is "1990-06-20", this would return `1990`.

You can also use it in calculations to determine age:

```
year(now()) - year(birthDate)
```

This calculates a person's approximate age by subtracting their birth year from the current year.

### Advanced Example
Using `year` in conditional logic for date-based decisions:

```
if(year(expiryDate) < year(now()), "Expired", "Valid")
```

This checks if a document or product has expired based on the year.

You can also use it for more complex date filtering:

```
if(year(date) == 2023 && month(date) > 6, "Second half of 2023", "First half of 2023 or different year")
```

This determines if a date falls in the second half of 2023.

Another practical application is creating fiscal year labels:

```
"FY" + (year(date) + (month(date) > 6 ? 1 : 0))
```

This creates a fiscal year label that increments in July, assuming a fiscal year that runs from July to June.

## Resources
- [Thomas J Frank YEAR Function](https://thomasjfrank.com/formulas/functions/year/)
- [Microsoft Office YEAR Function](https://support.microsoft.com/en-us/office/year-function-c64f017a-1354-490d-981f-578e8ec8d3b9)

## Notes
The `year` function works with any valid date object. If the input is not a valid date, the function may return an error or unexpected results.