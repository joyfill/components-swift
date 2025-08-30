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
    @State private var selectedDate: Date = Date()
    @Binding var cellModel: TableCellModel
    private var isUsedForBulkEdit = false
    let datePickerComponent: DatePickerComponents
        
    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        if !isUsedForBulkEdit {
            if let dateValue = cellModel.wrappedValue.data.date {
                if let dateString = ValueUnion.double(dateValue).dateTime(format: cellModel.wrappedValue.data.format ?? .empty) {
                    if let date = Utility.stringToDate(dateString, format: cellModel.wrappedValue.data.format ?? .empty) {
                        _selectedDate = State(initialValue: date)
                        _isDatePickerPresented = State(initialValue: true)
                    }
                }
            }
        }
        datePickerComponent = Utility.getDateType(format: cellModel.wrappedValue.data.format ?? .empty)
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            if let dateValue = cellModel.data.date {
                if let dateString = ValueUnion.double(dateValue).dateTime(format: cellModel.data.format ?? .empty) {
                    Text(dateString)
                        .padding(.horizontal, 8)
                        .font(.system(size: 15))
                        .lineLimit(1)
                }
            } else {
                Image(systemName: "calendar")
            }
        } else {
            Group {
                if isDatePickerPresented {
                    HStack {
                        Spacer()
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: datePickerComponent)
                            .accessibilityIdentifier("TableDateIdentifier")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .labelsHidden()
                            .scaleEffect(isUsedForBulkEdit ? 0.85 : 1, anchor: .leading)
                        
                        Spacer()
                        
                        Button {
                            isDatePickerPresented = false
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                        .accessibilityIdentifier("SetDateToNilIdentifier")
                        
                        Spacer()
                    }
                } else {
                    Image(systemName: "calendar")
                        .accessibilityIdentifier("CalendarImageIdentifier")
                        .frame(maxWidth: .infinity)
                        .padding(.all, 10)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isDatePickerPresented = true
                selectedDate = Date()
            }
            .onChange(of: selectedDate) { newValue in
                var cellDataModel = cellModel.data
                cellDataModel.date = dateToTimestampMilliseconds(date: newValue)
                cellModel.didChange?(cellDataModel)
                cellModel.data = cellDataModel
            }
        }
    }
}
