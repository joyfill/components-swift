import XCTest
@testable import JoyfillModel

/// Unit tests for date formatting, covering the fix where an invalid/empty
/// ISO8601 string used to fall back to `Date()` (the current time) instead of
/// producing an empty result.
final class DateFormattingTests: XCTestCase {

    // MARK: - getTimeFromISO8601Format

    func testInvalidISO8601StringReturnsNil() {
        // Previously these fell back to Date() and rendered the current time.
        XCTAssertNil(getTimeFromISO8601Format(iso8601String: "", format: .dateOnlyISO, tzId: "UTC"))
        XCTAssertNil(getTimeFromISO8601Format(iso8601String: "garbage", format: .dateOnlyISO, tzId: "UTC"))
        // Date-only without time component is not a valid full ISO8601 date-time.
        XCTAssertNil(getTimeFromISO8601Format(iso8601String: "2024-03-15", format: .dateOnlyISO, tzId: "UTC"))
    }

    func testValidISO8601StringIsFormattedWithGivenFormat() {
        let result = getTimeFromISO8601Format(iso8601String: "2024-03-15T13:30:00Z",
                                              format: .dateTime24,
                                              tzId: "UTC")
        XCTAssertEqual(result, "03/15/2024 13:30")
    }

    func testValidISO8601StringHonorsDateOnlyFormat() {
        let result = getTimeFromISO8601Format(iso8601String: "1970-01-01T00:00:00Z",
                                              format: .dateOnlyISO,
                                              tzId: "UTC")
        XCTAssertEqual(result, "1970-01-01")
    }

    // MARK: - ValueUnion.dateTime

    func testEmptyStringValueReturnsNil() {
        // The empty-string date value must not render a date.
        XCTAssertNil(ValueUnion.string("").dateTime(format: .empty, tzId: "UTC"))
    }

    func testGarbageStringValueReturnsNil() {
        XCTAssertNil(ValueUnion.string("not-a-date").dateTime(format: .dateTime, tzId: "UTC"))
    }

    func testNullValueReturnsNil() {
        XCTAssertNil(ValueUnion.null.dateTime(format: .empty, tzId: "UTC"))
    }

    func testDoubleTimestampValueIsFormatted() {
        // epoch 0 ms == 1970-01-01 00:00:00 UTC
        XCTAssertEqual(ValueUnion.double(0).dateTime(format: .dateOnlyISO, tzId: "UTC"), "1970-01-01")
    }

    func testIntTimestampValueIsFormatted() {
        XCTAssertEqual(ValueUnion.int(0).dateTime(format: .dateOnlyISO, tzId: "UTC"), "1970-01-01")
    }
}
