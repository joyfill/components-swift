# dateAdd

## Description
The `dateAdd` function adds a specified amount of time to a date. It allows you to increment a date by various time units such as years, months, days, hours, etc., making it useful for date calculations and manipulations.

## Syntax
```
dateAdd(date, amount, unit)
```

### Parameters
- `date` (Date) - The date to which time will be added.
- `amount` (Number) - The quantity of the specified unit to add.
- `unit` (String) - The unit of time to add. Supported units are:
  - "years"
  - "months"
  - "weeks"
  - "days"
  - "hours"
  - "minutes"
  - "seconds"
  - "milliseconds"

### Return Value
Returns a new Date object with the specified amount of time added.

## Examples

### Basic Example
Adding 3 years to a date:

```
dateAdd(date(2023, 1, 1), 3, "years")
```

Output: A Date object representing January 1, 2026 (displayed as `2026-01-01T00:00:00.000Z` or similar format).

Adding 2 months to the current date:

```
dateAdd(now(), 2, "months")
```

This adds 2 months to the current date and time.

### Intermediate Example
Using `dateAdd` with field references:

```
dateAdd(startDate, durationValue, durationUnit)
```

If `startDate` is "2023-05-15", `durationValue` is 14, and `durationUnit` is "days", this would return a date 14 days after May 15, 2023.

You can also chain multiple `dateAdd` calls to add different units:

```
dateAdd(dateAdd(date(2023, 1, 1), 6, "months"), 15, "days")
```

This adds 6 months and 15 days to January 1, 2023, resulting in July 16, 2023.

### Advanced Example
Using `dateAdd` for business date calculations:

```
if(dateAdd(now(), 30, "days") > dueDate, "Payment due soon!", "Payment due in more than 30 days")
```

This checks if a payment is due within the next 30 days.

You can also use it for more complex date logic:

```
if(month(dateAdd(now(), 3, "months")) == 12, "Q4 planning needed", "Not time for Q4 planning yet")
```

This checks if 3 months from now will be in December, which might trigger quarterly planning activities.

Another practical application is calculating expiration dates:

```
"Your subscription expires on " + dateAdd(subscriptionStartDate, 1, "years")
```

This calculates and displays a subscription expiration date that is one year after the start date.

## Resources
- [Thomas J Frank DateAdd Function](https://thomasjfrank.com/notion-formula-cheat-sheet/#dateadd)

## Notes
Unlike Excel, which has different functions for adding different time units (e.g., EDATE for months), Joyfill's `dateAdd` function handles all time units with a single function.

When adding months or years, the function maintains the same day of the month when possible. If the resulting month has fewer days than the original day, the function will adjust to the last day of the resulting month.