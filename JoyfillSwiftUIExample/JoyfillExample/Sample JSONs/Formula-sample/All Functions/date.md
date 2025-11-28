# date

## Description
The `date` function creates a Date object from individual year, month, and day components. It's useful for creating specific dates for calculations, comparisons, and formatting.

## Syntax
```
date(year, month, day)
```

### Parameters
- `year` (Number) - The year (e.g., 2023).
- `month` (Number) - The month (1-12), where 1 represents January and 12 represents December.
- `day` (Number) - The day of the month (1-31).

### Return Value
Returns a Date object representing the specified date.

## Examples

### Basic Example
Creating a specific date:

```
date(2023, 5, 15)
```

Output: A Date object representing May 15, 2023 (displayed as `2023-05-15T00:00:00.000Z` or similar format).

You can also use variables or field references for the parameters:

```
date(yearValue, monthValue, dayValue)
```

### Intermediate Example
Using the `date` function with other date functions:

```
year(date(2023, 5, 15))
```

Output: `2023`

```
month(date(2023, 5, 15))
```

Output: `5`

```
day(date(2023, 5, 15))
```

Output: `15`

You can also use it for date calculations:

```
(date(2023, 5, 15) - date(2023, 1, 1)) / (1000 * 60 * 60 * 24)
```

This calculates the number of days between January 1, 2023, and May 15, 2023.

### Advanced Example
Using `date` for dynamic date creation and comparison:

```
if(date(year(now()), month(now()), day(now())) == date(2023, 12, 25), "Merry Christmas!", "Not Christmas yet")
```

This checks if today is Christmas Day.

You can also use it to create dates for business logic:

```
if(now() > date(year(now()), 4, 15), "Tax filing deadline has passed", "You still have time to file taxes")
```

This checks if the current date is past April 15th of the current year (U.S. tax filing deadline).

Another practical application is creating recurring annual events:

```
if(month(now()) == 10 && day(now()) == 31, "Happy Halloween!", "Not Halloween")
```

This checks if today is Halloween (October 31st).

## Resources
- [Microsoft Office DATE Function](https://support.microsoft.com/en-us/office/date-function-e36c0c8c-4104-49da-ab83-82328b832349)

## Notes
The `date` function in Joyfill creates a date with the time set to midnight (00:00:00) in the UTC timezone. If you need to specify a time as well, you would need to use additional functions or methods.

If any of the parameters are out of range (e.g., month > 12), the function will adjust the date accordingly. For example, `date(2023, 13, 1)` would return a date representing January 1, 2024.