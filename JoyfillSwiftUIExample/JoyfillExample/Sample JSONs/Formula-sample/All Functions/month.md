# month

## Description
The `month` function extracts the month component from a date value. It returns the month as an integer ranging from 1 (January) to 12 (December), making it useful for date calculations, filtering, and formatting.

## Syntax
```
month(date)
```

### Parameters
- `date` (Date) - The date from which to extract the month.

### Return Value
Returns a number (1-12) representing the month of the provided date.

## Examples

### Basic Example
Extracting the month from a specific date:

```
month(date(2023, 5, 15))
```

Output: `5` (representing May)

You can also use it with the current date:

```
month(now())
```

This would return the current month as a number (e.g., `7` for July).

### Intermediate Example
Using the `month` function with field references:

```
month(orderDate)
```

If `orderDate` is "2023-03-15", this would return `3` (representing March).

You can also use it to create month names:

```
if(month(date) == 1, "January", 
  if(month(date) == 2, "February", 
    if(month(date) == 3, "March", 
      // ... and so on
    )
  )
)
```

This converts the numeric month to its name.

### Advanced Example
Using `month` in conditional logic for seasonal operations:

```
if(month(now()) >= 3 && month(now()) <= 5, "Spring", 
  if(month(now()) >= 6 && month(now()) <= 8, "Summer", 
    if(month(now()) >= 9 && month(now()) <= 11, "Fall", "Winter")
  )
)
```

This determines the current season based on the month.

You can also use it for business logic like quarterly reporting:

```
"Q" + ceil(month(date) / 3) + " " + year(date)
```

This creates a quarter label like "Q2 2023" based on the month.

Another practical application is determining if a date is in a specific month:

```
if(month(eventDate) == month(now()) && year(eventDate) == year(now()), "This month", "Different month")
```

This checks if an event is happening in the current month.

## Resources
- [Thomas J Frank MONTH Function](https://thomasjfrank.com/formulas/functions/month/)
- [Microsoft Office MONTH Function](https://support.microsoft.com/en-us/office/month-function-579a2881-199b-48b2-ab90-ddba0eba86e8)

## Notes
The `month` function works with any valid date object. If the input is not a valid date, the function may return an error or unexpected results.