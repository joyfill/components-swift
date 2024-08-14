import SwiftUI

struct TableModalTopNavigationView: View {
    @Binding var isDeleteButtonVisible: Bool
    let fieldDependency: FieldDependency
    var onDeleteTap: (() -> Void)?
    var onDuplicateTap: (() -> Void)?
    var onAddRowTap: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top) {
            if let title = fieldDependency.fieldData?.title {
                Text("\(title)")
                    .font(.headline.bold())
            }
            
            Spacer()
            if isDeleteButtonVisible {
                Button(action: {
                    onDeleteTap?()
                }) {
                    Text("Delete")
                        .foregroundStyle(.red)
                        .font(.system(size: 14))
                        .frame(width: 80, height: 27)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.red, lineWidth: 1))
                }
                .accessibilityIdentifier("TableDeleteRowIdentifier")
            }

            if isDeleteButtonVisible {
                Button(action: {
                    onDuplicateTap?()
                }) {
                    Text("Duplicate")
                        .foregroundStyle(.selection)
                        .font(.system(size: 14))
                        .frame(width: 80, height: 27)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.buttonBorderColor, lineWidth: 1))
                }
                .accessibilityIdentifier("TableDuplicateRowIdentifier")
            }

            Button(action: {
                onAddRowTap?()
            }) {
                Text("Add Row +")
                    .foregroundStyle(.selection)
                    .font(.system(size: 14))
                    .frame(width: 94, height: 27)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.buttonBorderColor, lineWidth: 1))
            }
            .accessibilityIdentifier("TableAddRowIdentifier")
        }
    }
}
