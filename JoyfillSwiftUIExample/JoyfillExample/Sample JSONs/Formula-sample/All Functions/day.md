# day

## Description
The `day` function extracts the day component from a date value. It returns the day of the month as an integer ranging from 1 to 31, making it useful for date calculations, filtering, and formatting.

## Syntax
```
day(date)
```

### Parameters
- `date` (Date) - The date from which to extract the day.

### Return Value
Returns a number (1-31) representing the day of the month of the provided date.

## Examples

### Basic Example
Extracting the day from a specific date:

```
day(date(2023, 5, 15))
```

Output: `15`

You can also use it with the current date:

```
day(now())
```

This would return the current day of the month (e.g., `23` if today is the 23rd).

### Intermediate Example
Using the `day` function with field references:

```
day(invoiceDate)
```

If `invoiceDate` is "2023-03-15", this would return `15`.

You can also use it to determine if a date is in the first half or second half of a month:

```
if(day(date) <= 15, "First half of month", "Second half of month")
```

This checks if the day is in the first 15 days or the last days of the month.

### Advanced Example
Using `day` in conditional logic for business rules:

```
if(day(dueDate) == day(now()) && month(dueDate) == month(now()) && year(dueDate) == year(now()), "Due today!", "Not due today")
```

This checks if a payment is due on the current day.

You can also use it for more complex date filtering:

```
if(day(date) == 1, "First day of month", if(day(date) > 25, "Last week of month", "Middle of month"))
```

This categorizes a date based on its position within the month.

Another practical application is creating recurring schedules:

```
if(day(now()) % 7 == 0, "Weekly task due today", "No weekly task today")
```

This creates a weekly schedule that repeats every 7 days.

## Resources
- [Microsoft Office DAY Function](https://support.microsoft.com/en-us/office/day-function-8a7d1cbb-6c7d-4ba1-8aea-25c134d03101)

## Notes
The `day` function in Joyfill returns the day of the month, not the day of the week. This differs from some other platforms like Notion, which uses "day" to refer to the day of the week.

The function works with any valid date object. If the input is not a valid date, the function may return an error or unexpected results.