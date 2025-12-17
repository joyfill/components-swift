//
//  Utility.swift
//  Joyfill
//
//  Created by Vivek on 24/12/24.
//

import JoyfillModel
import SwiftUI

class Utility {

    static let DEBOUNCE_TIME_IN_NANOSECONDS: UInt64 = 00
    static let singleColumnWidth: CGFloat = 200
    
    static func getCellWidth(type: ColumnTypes, format: DateFormatType) -> CGFloat {
        switch type {
//        case .block:
//            let measuredWidth = measureTextWidth(text: text, font: UIFont.systemFont(ofSize: 15)) + 20
//            
//            return max(singleColumnWidth, min(measuredWidth, 2 * singleColumnWidth))
//        case .date:
//            return (type == .date) && (format == .dateTime || format == .empty) ? 270 : singleColumnWidth
        default:
            return singleColumnWidth
        }
    }
    
    static func getWidthForExpanderRow(columns: [FieldTableColumn], showSelector: Bool, showSingleClickEdit: Bool = false) -> CGFloat {
        let totalWidth = columns.reduce(0) { accumulator, column in
            // Get width based on column type and format
            let columnWidth = Utility.getCellWidth(
                type: column.type ?? .unknown,
                format: DateFormatType(rawValue: column.format ?? "") ?? .empty
            )
            return accumulator + columnWidth
        }
        let widthForTwoEmptyBox: CGFloat = 80
        let widthForThirdEmptyBox: CGFloat = showSelector ? 40 : 0
        let widthForEditButton: CGFloat = showSingleClickEdit ? 40 : 0
        return max(totalWidth, singleColumnWidth) + widthForTwoEmptyBox + widthForThirdEmptyBox + widthForEditButton
    }
    
    static func getTotalTableScrollWidth(level: Int) -> CGFloat {
        var width: CGFloat = 0
        if level != 0 {
            for _ in 0..<(2 * level - level) {
                width += 40
            }
        }
        return width
    }
        
    private static func measureTextWidth(text: String, font: UIFont) -> CGFloat {
        let constraintSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: font.lineHeight)
        let boundingBox = text.boundingRect(
            with: constraintSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.width)
    }
    
    static func getDateType(format: DateFormatType) -> DatePickerComponents {
        switch format {
        // Date Only (all date-only formats)
        case .dateOnly, .dateOnlyDDMMYYYY, .dateOnlyISO, .dateOnlyYYYYMMDD,
             .dateOnlyDashUS, .dateOnlyDashEU, .dateOnlyShortYear, .dateOnlyShortYearEU:
            return [.date]
            
        // Time Only (all time-only formats)
        case .timeOnly, .timeOnly24Hour, .timeOnlyWithSeconds, .timeOnly24HourWithSeconds:
            return [.hourAndMinute]
            
        // Date + Time (all combined formats)
        case .dateTime, .dateTime24, .dateTimeWithSeconds, .dateTime24WithSeconds,
             .dateTimeDDMMYYYY, .dateTimeDDMMYYYY12Hour, .dateTimeDDMMYYYYWithSeconds, .dateTimeDDMMYYYY12HourWithSeconds,
             .dateTimeISO, .dateTimeISOWithSeconds, .dateTimeYYYYMMDD,
             .dateTimeDashUS, .dateTimeDashEU,
             .empty:
            return [.date, .hourAndMinute]
        }
    }

    static func stringToDate(_ dateString: String, format: DateFormatType, tzId: String? = nil) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.dateFormat
        dateFormatter.timeZone = TimeZone(identifier: tzId ?? TimeZone.current.identifier)
        
        // Set locale based on format type to match timestampMillisecondsToDate
        if format.rawValue.contains("HH") {
            // Force 24-hour format
            dateFormatter.locale = Locale(identifier: "en_GB")
        } else if format == .empty || format.rawValue.contains("hh") {
            // For 12-hour format, use en_US_POSIX to ensure consistent 12-hour display
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        }
        
        return dateFormatter.date(from: dateString)
    }
    
    static func debounceTextChange(
        debounceTask: inout Task<Void, Never>?,
        updateFieldValue: @escaping () -> Void
    ) {
        debounceTask?.cancel() // Cancel any ongoing debounce task
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: DEBOUNCE_TIME_IN_NANOSECONDS)
            if !Task.isCancelled {
                await MainActor.run {
                    updateFieldValue()
                }
            }
        }
    }
    
    static func convertEpochBetweenTimezones(epochMillis: Double,
                                      from: TimeZone,
                                      to: TimeZone,
                                      format: DateFormatType?) -> Double {
        let sourceDate = Date(timeIntervalSince1970: epochMillis / 1000.0)

        var fromCalendar = Calendar(identifier: .gregorian)
        fromCalendar.timeZone = from

        var toCalendar = Calendar(identifier: .gregorian)
        toCalendar.timeZone = to

        if format == .dateOnly {
            let ymd = fromCalendar.dateComponents([.year, .month, .day], from: sourceDate)
            var atNoon = DateComponents()
            atNoon.year = ymd.year
            atNoon.month = ymd.month
            atNoon.day = ymd.day
            atNoon.hour = 12
            let targetLocalDate = toCalendar.date(from: atNoon) ?? sourceDate
            return dateToTimestampMilliseconds(date: targetLocalDate)
        }

        let comps = fromCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: sourceDate)
        let targetDate = toCalendar.date(from: comps) ?? sourceDate
        return dateToTimestampMilliseconds(date: targetDate)
    }
}

