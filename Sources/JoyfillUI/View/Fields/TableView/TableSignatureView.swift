import SwiftUI

struct TableSignatureView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var cellModel: TableCellModel
    @State var isEditable: Bool = false
    @State private var lines: [Line] = []
    @State private var savedLines: [Line] = []
    @State private var signatureImage: UIImage?
    @State private var showCanvasSignatureView: Bool = false
    @State var title: String = ""
    @State var showError: Bool = false
    
    init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false) {
        _cellModel = cellModel
        if !isUsedForBulkEdit {
            _title = State(initialValue: cellModel.wrappedValue.data.title ?? "")
        }
    }
    
    var body: some View {
        Button(action: {
            loadImageFromURL()
            showCanvasSignatureView = true
        }, label: {
            Image(systemName: "signature")
                .foregroundColor((title.isEmpty || title == nil) ? .gray : colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .center)
                .contentShape(Rectangle())
        })
        .accessibilityIdentifier("TableSignatureOpenSheetButton")
        .sheet(isPresented: $showCanvasSignatureView, onDismiss: {
            isEditable = false
        }) {
            CanvasSignatureView(lines: $lines, savedLines: $savedLines, signatureImage: $signatureImage, signatureURL: $title, showError: $showError, isEditable: $isEditable)
        }
        .onChange(of: signatureImage) { newImage in
            if let newImage = newImage, let data = newImage.pngData() {
                let base64String = data.base64EncodedString()
                title = "data:image/png;base64,\(base64String)"
                cellModel.data.title = "data:image/png;base64,\(base64String)"
            } else {
                cellModel.data.title = ""
                title = ""
            }
        }
        .onChange(of: title) { newValue in
            cellModel.data.title = newValue
            cellModel.didChange?(cellModel.data)
        }
    }
    
    func loadImageFromURL() {
        if !title.isEmpty {
            APIService.loadImage(from: title) { imageData in
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.signatureImage = image
                    }
                } else {
                    showError = true
                }
            }
        }
    }
}
