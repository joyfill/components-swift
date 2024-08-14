import SwiftUI




//onDeleteTap?()
//onDuplicateTap?()

//    .accessibilityIdentifier("TableDeleteRowIdentifier")
//    .accessibilityIdentifier("TableDuplicateRowIdentifier")


struct TableModalTopNavigationView: View {
    @Binding var showMoreButton: Bool
    var onDeleteTap: (() -> Void)?
    var onDuplicateTap: (() -> Void)?
    var onAddRowTap: (() -> Void)?
    @State private var showingPopover = false

    var body: some View {
        HStack {
            Text("Table Title")
                .lineLimit(1)
                .font(.headline.bold())
            
            Spacer()

            if showMoreButton {
                Button(action: {
                    showingPopover = true
                }) {
                    Text("More ^")
                        .foregroundStyle(.selection)
                        .font(.system(size: 14))
                        .frame(width: 80, height: 27)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.buttonBorderColor, lineWidth: 1))
                }
                .popover(isPresented: $showingPopover) {
                    if #available(iOS 16.4, *) {
                        VStack {
                            Button(action: {
                                onDuplicateTap?()
                            }) {
                                Text("Edit rows")
                                    .foregroundStyle(.selection)
                                    .font(.system(size: 14))
                                    .frame(width: 80, height: 27)
                                    .overlay(RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.buttonBorderColor, lineWidth: 1))
                            }
                            .accessibilityIdentifier("TableDuplicateRowIdentifier")

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
                        .padding()
                        .presentationCompactAdaptation(.popover)

                    } else {
                        // Fallback on earlier versions
                    }
                }
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

#Preview {
    TableModalTopNavigationView(showMoreButton: .constant(true))
}
