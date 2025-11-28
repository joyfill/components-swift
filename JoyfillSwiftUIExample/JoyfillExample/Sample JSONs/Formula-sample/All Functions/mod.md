# mod

## Description
The `mod` function returns the remainder after dividing the first operand by the second. It's used to perform modulo operations, which are useful for various calculations including determining if a number is divisible by another, cycling through ranges, and more.

## Syntax
```
mod(dividend, divisor)
```

### Parameters
- `dividend` (Number) - The number to be divided.
- `divisor` (Number) - The number to divide by.

### Return Value
Returns a number representing the remainder after division.

## Examples

### Basic Example
Finding the remainder when dividing 19 by 12:

```
mod(19, 12)
```

Output: `7`

This is because 19 divided by 12 equals 1 with a remainder of 7.

### Intermediate Example
Using `mod` with negative numbers:

```
mod(-19, 12)
```

Output: `-7`

When working with negative numbers, the sign of the result follows the sign of the dividend.

You can also use field references in your calculations:

```
mod(totalAmount, itemPrice)
```

If `totalAmount` is 50 and `itemPrice` is 12, this would return 2 (the remainder after dividing 50 by 12).

### Advanced Example
Using `mod` for cyclic operations, such as determining the day of the week:

```
mod(dayNumber + startingDay - 1, 7) + 1
```

If `dayNumber` is 15 (the 15th day of the month) and `startingDay` is 3 (the month starts on the 3rd day of the week), this formula would calculate which day of the week the 15th falls on.

Another practical application is creating alternating patterns:

```
if(mod(rowNumber, 2) === 0, "Even Row Style", "Odd Row Style")
```

This formula uses `mod` to determine if a row number is even or odd, and applies different styling accordingly.

## Resources
- [Microsoft Office MOD Function](https://support.microsoft.com/en-us/office/mod-function-9b6cd169-b6ee-406a-a97b-edf2a9dc24f3)
- [Thomas J Frank MOD Function](https://thomasjfrank.com/formulas/built-ins/mod/)