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
    static let singleColumnWidth: CGFloat = 170
    
    static func getCellWidth(type: ColumnTypes, format: DateFormatType, text: String) -> CGFloat {
        switch type {
        case .block:
            let measuredWidth = measureTextWidth(text: text, font: UIFont.systemFont(ofSize: 15))
            
            return max(singleColumnWidth, min(measuredWidth, 2 * singleColumnWidth))
        case .date:
            return (type == .date) && (format == .dateTime || format == .empty) ? 270 : singleColumnWidth
        default:
            return singleColumnWidth
        }
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

