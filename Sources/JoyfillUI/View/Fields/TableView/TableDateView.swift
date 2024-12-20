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
    private var isUsedForBulkEdit = false
        
    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false) {
        _cellModel = cellModel
        if !isUsedForBulkEdit {
            if let dateValue = cellModel.wrappedValue.data.date {
                if let dateString = ValueUnion.double(dateValue).dateTime(format: cellModel.wrappedValue.data.format ?? "") {
                    if let date = stringToDate(dateString, format: cellModel.wrappedValue.data.format ?? "") {
                        _selectedDate = State(initialValue: date)
                        _isDatePickerPresented = State(initialValue: true)
                    }
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
        if cellModel.viewMode == .quickView {
            if let dateValue = cellModel.data.date {
                if let dateString = ValueUnion.double(dateValue).dateTime(format: cellModel.data.format ?? "") {
                    Text(dateString)
                        .padding(.horizontal, 8)
                        .font(.system(size: 15))
                        .lineLimit(1)
                }
            } else {
                Image(systemName: "calendar")
                    .frame(maxWidth: .infinity)
                    .padding(.all, 10)
            }
        } else {
            Group {
                if isDatePickerPresented {
                    HStack {
                        Spacer()
                        
                        DatePicker("", selection: dateBinding, displayedComponents: getDateType(format: $cellModel.wrappedValue.data.format ?? ""))
                            .accessibilityIdentifier("DateIdenitfier")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .labelsHidden()
                        
                        Spacer()
                        
                        Button {
                            isDatePickerPresented = false
                            selectedDate = nil
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                        
                        Spacer()
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
                var cellDataModel = cellModel.data
                cellDataModel.date = newValue.map { dateToTimestampMilliseconds(date: $0) }
                cellModel.didChange?(cellDataModel)
                cellModel.data = cellDataModel
            }
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
