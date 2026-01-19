---
title: "Release Notes"
description: "Complete changelog of Joyfill iOS SDK releases"
icon: "notes"
---

> Source: https://github.com/joyfill/components-swift/releases  

---

## 3.0.0-rc8

**Release Date:** December 19, 2025

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

* Single-click option to open a row form for Collection and Table fields.
* “Select All” rows functionality for filtered collections and tables.
* Ability to delete rows while filters are active in Collection fields.
* Page deletion support.
* Enhanced Page List UI.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

* Color handling updated to support RGBA color format.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

* Issue where the Date field did not update on the first change due to double parsing.
* Ensured the last page always remains visible, regardless of hidden state or conditional logic.

***

## 3.0.0-rc7

**Release Date:** November 28, 2025

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

* Support for inserting a row while filters or sorting are active — both Insert Below and Add Row now behave intuitively.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

* Updated the default format for date fields and corrected 24-hour format handling.
* Signature field layout — Clear and Save buttons are now aligned to the same height for a more consistent UI.
* Performance optimizations for Table/Collection.
* Added space between the Add button and the required field indicator in Collection fields for improved clarity.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

* Crash caused by on-change handler when side-by-side form changes were misaligned.
* SDK crash when selecting a date due to device-level 24-hour format settings.
* Bulk edit creating unwanted empty changelog entries.
* Field parsing issue where “deleted” property was interpreted as a double instead of a boolean.
* Various issues found in the example project.

***

## 3.0.0-rc6

**Release Date:** November 13, 2025

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

* Row navigation now keeps the target row in view when closing the row form in Collection and Table fields.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

* Fixed UI empty space in collection quick view after expanding a single row and navigating back.
* Fixed the date field clear (X) button by increasing its tap area for more reliable interaction.
* Fixed the validation helper bug for required collection fields.

***

## 3.0.0-rc5

**Release Date:** October 30, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/3.0.0-rc5).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Support for custom date and time formats.
- Highlighting for the selected row in Table and Collection fields to improve user visibility.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Required field validation — added page ID to validation status object for more accurate field tracking.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Multi-selection text-to-box image alignment issue.
- Crash in Table Quick View in change handler.
- Handling of decimal numbers without a leading zero in formulas.

---

## 3.0.0-rc4

**Release Date:** October 10, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/3.0.0-rc4).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Scrolling support in table column titles to ensure visibility when titles are very large.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Disabled editing of text and barcode column cells in Table/Collection when in read-only mode.
- Disabled duplicate page functionality in read-only mode.
- Disabled all event handlers while in read-only mode to prevent unintended interactions.
- Adjusted Table/Collection colors for proper appearance in dark mode.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Table/Collection image cell triggering `onChange` twice.
- Date field calling `onFocus` before the `onChange` event.
- Memory leak and retain cycle between `DocumentEditor` and `JoyfillDocContext`.
- Block field appearance when color value is empty.
- Filtering number columns with `0` returned empty rows.
- Include timezone (`tz`) property in changelog when updating date columns in tables to ensure accurate time handling.

---

## 3.0.0-rc3

**Release Date:** September 25, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/3.0.0-rc3).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>CHANGED</span>

- Updated README documentation.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Multithreading crash related to collection field initialization.
- `onBlur` events not being called.
- Collection field quick view image column count not updating.

---

## 3.0.0-rc2

**Release Date:** September 19, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/3.0.0-rc2).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>CHANGED</span>

- Updated README documentation.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Changes made by change handler being discarded on page switch.

---

## 3.0.0-rc1

**Release Date:** September 17, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/3.0.0-rc1).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Collection field.
- Formula support.
- License-based collection field enforcement.
- Support for new table column types in Table and Collection field.
- Collection sort and filter.
- Collection conditional logic.
- Collection field validation.
- Support for Change handler to modify the form externally/programmatically.
- Date time zone support.
- Image field URL replacement.
- Block field additional styling.
- Insensitive conditional logic for texts.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Updated README and related docs.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Crash issues by removing force unwraps.
- Field ordering.

---

## 2.0.6

**Release Date:** July 6, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/2.0.6).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Support for block field styles.
- Support for updating image URLs from outside via document editor with live UI refreshing.
- Support for single and multiple images for table image column.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Showing image picker in already presented sheets.
- Random crashes by removing force unwraps across the project.
- Issues related to image field (image reset bug on re-upload of same image in single-selection).
- Case sensitivity in conditional logic (removed case sensitivity for text).
- Title visibility when converting web view to mobile view.
- Checkbox issue related to multi property.
- Add empty cells object when inserting new rows in table.
- Memory leaks by using `weak self` in table closures.

---

## 2.0.5

**Release Date:** April 25, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/2.0.5).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>FIXED</span>

- Image getting replaced in image field if upload handler is not called when upload button tapped.
- `int64` parsing issue in model.

---

## 2.0.4

**Release Date:** April 17, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/2.0.4).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Page duplication.
- User access token handling in example project.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Table image view UI on iPad.
- Field ordering in validations.
- Crash on invalid JSON.
- Missing `int` case in `valueUnion` in model (crash fix).

---

## 2.0.3

**Release Date:** February 26, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/2.0.3).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>CHANGED</span>

- Made dictionaries public in the `JoyDoc` Model.

---

## 2.0.2

**Release Date:** February 19, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/2.0.2).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>FIXED</span>

- Form content being obscured by the keyboard for text fields.
- Extra space in the Table field on iOS 15.
- Keyboard auto-dismiss on table text cell for the first row on iOS 15.

---

## 2.0.1

**Release Date:** February 14, 2024

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/2.0.1).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>CHANGED</span>

- Applied conditional logic to the current `pageId` passed in `Form` init.
- Improved web → mobile view conversion when multiple fields share the same Y position.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Logical `AND` / `OR` corner cases in conditional logic.
- iPad rotation issue in UIKit Sample Project.

---

## 2.0.0

**Release Date:** December 24, 2023

Learn more in the [release notes](https://github.com/joyfill/components-swift/releases/tag/2.0.0).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Support hidden property for the fields header.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Improved table field performance and overall form performance for large forms.
- Updated conditional logic APIs.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Unsupported column type.
- Table navigation on iPad.

---

## 1.2.2

**Release Date:** November 12, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Insert below & move row in table field.

---

## 1.2.1

**Release Date:** November 9, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>FIXED</span>

- Model version issues.

---

## 1.2.0

**Release Date:** October 15, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Only validate current visible view for field validator.
- Cocoapods support.

---

## 1.1.0

**Release Date:** September 25, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Table field search, filter, sort, bulk update, and more.
- Test cases for selection field.
- Unit test cases for validation fields.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Improved performance for large tables (1,000+ rows) to prevent crashes.
- Handled unsupported field types gracefully.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Table title display issue.
- Padding for fields in form view.

---

## 1.0.6

**Release Date:** July 26, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- UI test case for selection fields.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Updated README documentation for validation.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Validation not working properly with conditional logic.
- Drop-down field showing deleted options.

---

## 1.0.5

**Release Date:** July 24, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- New validation APIs for improved form handling.
- Support for duplicating rows in table fields.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Conditional logic not working for single-select and multi-select fields.
- Crash when adding a new row in an empty table view.

---

## 1.0.4

**Release Date:** July 9, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Conditional logic functionality.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Multiple choice issue where deleted options were still showing.

---

## 1.0.3

**Release Date:** June 6, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>FIXED</span>

- Page navigation now hidden when page count is 1.
- Tooltip visibility issue when explicitly set to hidden.

---

## 1.0.2

**Release Date:** June 5, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Page navigation functionality.
- Field tooltip for better usability.
- Documentation for public APIs.
- UI test cases in the example project.
- Unit test cases in the example project.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Improved overall performance and minor stability enhancements.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Issues related to the signature field.  
---

## 1.0.1

**Release Date:** May 13, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>FIXED</span>

- An issue in the `JoyDoc` model where the app was crashing when values in some of the fields were nil.

---

## 1.0.0

**Release Date:** May 7, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- JoyDoc model to be JSON/dictionary-backed for future-proofing.
- Data can now be accessed via `document.dictionary`, and initialization can be done using a dictionary input.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Improved overall performance and resolved minor issues.
- No changes to public APIs (getters/setters).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Empty form appearing for newly created documents.
- Table row addition not triggering updates correctly.
- Chart coordinate values not updating.
- Signature filled on mobile not displaying on web.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #ef4444', borderRadius: '6px', color: '#ef4444', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>REMOVED</span>

- Deprecated API service dependency.

---

## 0.2.17

**Release Date:** April 16, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Support for the `disabled` field across the entire form.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Updated model with newly added fields to fix parsing issues and missing data when saving documents.
- Improved code structure through cleanup and general performance optimizations.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- UI alignment issues in the `Date` field.

---

## 0.2.16

**Release Date:** April 4, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>CHANGED</span>

- Updated public API — `JoyFillView` renamed to `Form`, and `currentPageID` renamed to `pageID` for consistency with Android SDK naming conventions.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Image alignment issue in image view.
- Console warnings.
- Table editing changes not reflecting in the Table Quick View.

---

## 0.2.15

**Release Date:** April 1, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>CHANGED</span>

- Improved overall performance and stability.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Various minor bugs and issues.

---

## 0.2.14

**Release Date:** March 27, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #ef4444', borderRadius: '6px', color: '#ef4444', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>REMOVED</span>

- Unused dependency `SwiftUICharts`.

---

## 0.2.13

**Release Date:** March 26, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Chart field.
- Rich Text field.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Improved overall performance and stability.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>FIXED</span>

- Minor bugs and issues.  

---

## 0.2.12

**Release Date:** March 18, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>FIXED</span>

- Minor bugs and issues.

---

## 0.2.11

**Release Date:** March 15, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Implementation of all field types with full support.
- Full light mode support (dark mode coming soon).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Improved change handlers for each field to provide proper variable support (see docs/readme).
- This is a beta release; some bugs may occur — please report them to the Joyfill team.
- Refer to [official documentation](https://docs.joyfill.io/docs/swift) for more details.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #ef4444', borderRadius: '6px', color: '#ef4444', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>REMOVED</span>

- Previous SDK — now fully replaced by the new implementation.

---

## 0.2.10

**Release Date:** March 15, 2023

🎉 **First public version of the Joyfill Swift SDK.**

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Implementation of all field types with full support.
- Full light mode support (dark mode coming soon).

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>CHANGED</span>

- Improved change handlers for each field — now provide proper variable support (see docs/readme).
- This is a beta release — occasional bugs may occur; please report them to the Joyfill team.
- Refer to the [official documentation](https://docs.joyfill.io/docs/swift) for more details.

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #ef4444', borderRadius: '6px', color: '#ef4444', fontWeight: '600', fontSize: '13px', marginBottom: '12px', marginTop: '16px'}}>REMOVED</span>

- Previous SDK — fully replaced by the new Swift SDK.

---

## 0.2.9

**Release Date:** March 15, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #f97316', borderRadius: '6px', color: '#f97316', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>FIXED</span>

- Minor bugs and issues.

---

## 0.2.8

**Release Date:** March 14, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Pre-release version for testing as the main release.

---

## 0.2.7

**Release Date:** March 14, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Handle TableView onFocus.

---

## 0.2.3

**Release Date:** March 14, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Handle TableView onFocus.

---

## 0.2.3-beta

**Release Date:** March 14, 2023

<span style={{display: 'inline-block', padding: '4px 12px', border: '1.5px solid #10b981', borderRadius: '6px', color: '#10b981', fontWeight: '600', fontSize: '13px', marginBottom: '12px'}}>ADDED</span>

- Handle TableView onFocus.

