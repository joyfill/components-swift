import SwiftUI
import JoyfillModel

struct TableDateView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    var cellModel: TableCellModel
        
    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
        if let value = cellModel.data.date {
            let dateString = value.dateTime(format: "MM/DD/YYYY") ?? ""
            if let date = stringToDate(dateString, format: "MM/DD/YYYY") {
                _selectedDate = State(initialValue: date)
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
                DatePicker("", selection: $selectedDate, displayedComponents: getDateType(format: ""))
                    .accessibilityIdentifier("DateIdenitfier")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .labelsHidden()
                    .padding(.all, 8)
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
