//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 17/12/24.
//
import SwiftUI
import JoyfillModel

struct TableDateView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate: Date? = nil
    @Binding var cellModel: TableCellModel
        
    public init(cellModel: Binding<TableCellModel>) {
        _cellModel = cellModel
        if let dateValue = cellModel.wrappedValue.data.date {
            if let dateString = dateValue.dateTime(format: "hh:mma") {
                if let date = stringToDate(dateString, format: "hh:mma") {
                    _selectedDate = State(initialValue: date)
                    _isDatePickerPresented = State(initialValue: true)
                }
            }
        }
    }
    
    private var dateBinding: Binding<Date> {
        Binding(
            get: { selectedDate ?? Date() },
            set: { selectedDate = $0 }
        )
    }
    
    var body: some View {
        Group {
            if isDatePickerPresented {
                HStack {
                    DatePicker("", selection: dateBinding, displayedComponents: getDateType(format: "hh:mma"))
                        .accessibilityIdentifier("DateIdenitfier")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .labelsHidden()
                        .padding(.all, 8)
                    
                    Image(systemName: "xmark.circle")
                        .onTapGesture {
                            isDatePickerPresented = false
                            selectedDate = nil
                        }
                }
            } else {
                Image(systemName: "calendar")
                    .frame(maxWidth: .infinity)
                    .padding(.all, 10)
                    .onTapGesture {
                        isDatePickerPresented = true
                        selectedDate = Date()
                    }
            }
        }
        .onChange(of: selectedDate) { newValue in
            
        }
    }
    
    func stringToDate(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType(rawValue: format)?.dateFormat ?? ""
        return dateFormatter.date(from: dateString)
    }
    
    func getDateType(format: String) -> DatePickerComponents {
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
}
