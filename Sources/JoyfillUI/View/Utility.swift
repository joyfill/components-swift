//
//  Utility.swift
//  Joyfill
//
//  Created by Vivek on 24/12/24.
//

import JoyfillModel
import SwiftUI

class Utility {
    
    static let DEBOUNCE_TIME_IN_NANOSECONDS: UInt64 = 1_000_000_000
    
    static func getCellWidth(type: ColumnTypes, format: DateFormatType) -> CGFloat {
        return (type == .date) && (format == .dateTime || format == .empty) ? 270 : 170
    }

    static func getDateType(format: DateFormatType) -> DatePickerComponents {
        switch format {
        case .dateOnly:
            return [.date]
        case .timeOnly:
            return [.hourAndMinute]
        case .dateTime:
            return [.date, .hourAndMinute]
        case .empty:
            return [.date, .hourAndMinute]
        }
    }

    static func stringToDate(_ dateString: String, format: DateFormatType) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.dateFormat
        return dateFormatter.date(from: dateString)
    }
}

