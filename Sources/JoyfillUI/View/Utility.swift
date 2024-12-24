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
    
    static func getCellWidth(type: String, format: String) -> CGFloat {
        return (type == "date") && (format == "MM/DD/YYYY hh:mma" || format == "") ? 270 : 170
    }

    static func getDateType(format: String) -> DatePickerComponents {
        switch DateFormatType(rawValue: format) {
        case .dateOnly:
            return [.date]
        case .timeOnly:
            return [.hourAndMinute]
        case .dateTime:
            return [.date, .hourAndMinute]
        case .none:
            return [.date, .hourAndMinute]
        case .some(.empty):
            return [.date, .hourAndMinute]
        }
    }

    static func stringToDate(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType(rawValue: format)?.dateFormat ?? ""
        return dateFormatter.date(from: dateString)
    }
}

