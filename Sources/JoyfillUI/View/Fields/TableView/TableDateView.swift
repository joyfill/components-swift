import SwiftUI
import JoyfillModel

struct TableDateView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate: Date?
    var cellModel: TableCellModel
        
    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
        if let value = cellModel.data.date {
            let dateString = value.dateTime(format: cellModel.data.format ?? "") ?? ""
            if let date = stringToDate(dateString, format: cellModel.data.format ?? "") {
                _selectedDate = State(initialValue: date)
                _isDatePickerPresented = State(initialValue: true)
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter
    }()
    
    var body: some View {
        Group {
            if isDatePickerPresented {
                HStack {
                    if let unwrappedSelectedDate = selectedDate {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { unwrappedSelectedDate },
                                set: { selectedDate = $0 }
                            ),
                            displayedComponents: getDateType(format: cellModel.data.format ?? "")
                        )
                        .dynamicTypeSize(.xSmall)
                        .accessibilityIdentifier("DateIdentifier")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .labelsHidden()
                        .padding(.all, 8)
                    }
                    
                    Button(action: {
                        isDatePickerPresented = false
                        selectedDate = nil
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                    .padding(.trailing, 10)
                    .darkLightThemeColor()
                }
            } else {
                HStack {
                    Text("Select a Date -")
                        .font(.system(size: 15))
                    Spacer()
                    Image(systemName: "calendar")
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 10)
                .onTapGesture {
                    isDatePickerPresented = true
                    selectedDate = Date()
                }
            }
        }
        .onChange(of: selectedDate) { newValue in
            if let date = selectedDate {
                let convertDateToInt = dateToTimestampMilliseconds(date: date)
                let newDateValue = ValueUnion.double(convertDateToInt)
                
                var editedCell = cellModel.data
                editedCell.date = newDateValue
                cellModel.didChange?(editedCell)
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
