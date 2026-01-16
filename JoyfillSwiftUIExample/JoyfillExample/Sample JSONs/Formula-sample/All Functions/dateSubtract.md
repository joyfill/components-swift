# dateSubtract Function

## Description
The `dateSubtract` function is used to subtract a quantity and unit of time from an existing Date object. It allows you to easily calculate dates in the past relative to a given date.

## Syntax
```
dateSubtract(Date, Number, String)
```

### Parameters
- `Date`: The date object to subtract time from.
- `Number`: The quantity of time to subtract.
- `String`: The unit of time to subtract. Supported units:
  * "years"
  * "months"
  * "weeks"
  * "days"
  * "hours"
  * "minutes"
  * "seconds"
  * "milliseconds"

## Examples

### Basic Example
```
dateSubtract(date(2023, 1, 1), 3, "years")
```
This will return a date representing January 1, 2020, which is 3 years before January 1, 2023.

```
dateSubtract(now(), 2, "months")
```
This will return a date that is 2 months before the current date and time.

### Intermediate Example
```
dateSubtract(startDate, durationValue, durationUnit)
```
This example subtracts a duration specified in fields from a start date. If `startDate` is "2023-05-15", `durationValue` is 14, and `durationUnit` is "days", it would return "2023-05-01", which is 14 days before May 15, 2023.

```
dateSubtract(dateSubtract(date(2023, 12, 31), 6, "months"), 15, "days")
```
This example demonstrates chaining multiple dateSubtract functions. It first subtracts 6 months from December 31, 2023 (resulting in June 30, 2023), and then subtracts 15 more days, resulting in June 15, 2023.

### Advanced Example
```
if(dateSubtract(dueDate, 30, "days") < now(), 
   "Invoice is due in less than 30 days", 
   "Invoice due date is more than 30 days away")
```
This complex example demonstrates using the `dateSubtract` function for date comparison:
1. It subtracts 30 days from a due date
2. Compares that date with the current date and time
3. If the current date is after the calculated date (30 days before the due date), it means the due date is less than 30 days away
4. Returns an appropriate message based on the comparison

This approach is useful for creating alerts or notifications based on approaching deadlines.

## Resources
- [Thomas J. Frank Documentation](https://thomasjfrank.com/notion-formula-cheat-sheet/#dateadd)

## Notes
- Unlike Excel, which doesn't have a direct equivalent to this function, `dateSubtract` provides a straightforward way to perform date arithmetic.
- When subtracting months or years, the function handles edge cases like month length differences and leap years appropriately.
- If subtracting months or years would result in an invalid date (e.g., subtracting 1 month from March 31 would try to create February 31), the function will adjust to the last valid day of the target month.