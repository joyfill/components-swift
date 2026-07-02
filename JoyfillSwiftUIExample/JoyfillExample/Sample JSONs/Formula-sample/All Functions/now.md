# now

## Description
The `now` function returns the current date and time. It's useful for timestamping, calculating durations, and creating dynamic date-based content.

## Syntax
```
now()
```

### Parameters
This function doesn't take any parameters.

### Return Value
Returns a Date object representing the current date and time.

## Examples

### Basic Example
Getting the current date and time:

```
now()
```

Output: The current date and time, for example: `2023-05-15T14:30:45.123Z`

### Intermediate Example
Using the `now` function to create a timestamp:

```
"Document created on: " + now()
```

This concatenates a string with the current date and time to create a timestamp message.

You can also use it with other date functions to extract specific parts of the current date:

```
year(now())
```

This would return the current year.

```
month(now())
```

This would return the current month as a number (1-12).

### Advanced Example
Using `now` to calculate time differences:

```
dateSubtract(now(), 7, "days")
```

This returns a date that is 7 days before the current date and time.

You can also use `now` in conditional logic to display different content based on the current time:

```
if(hour(now()) < 12, "Good morning!", if(hour(now()) < 18, "Good afternoon!", "Good evening!"))
```

This displays a greeting based on the time of day.

Another practical application is calculating durations:

```
(now() - startDate) / (1000 * 60 * 60 * 24)
```

This calculates the number of days between a start date and the current date.

## Resources
- [Thomas J Frank NOW Function](https://thomasjfrank.com/formulas/functions/now/)
- [Microsoft Office NOW Function](https://support.microsoft.com/en-us/office/now-function-3337fd29-145a-4347-b2e6-20c904739c46)

## Notes
The exact format of the returned date and time may vary depending on the system's locale and settings. When displayed, the date is typically formatted according to the user's preferences.