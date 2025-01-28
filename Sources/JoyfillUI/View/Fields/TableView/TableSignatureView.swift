import SwiftUI

struct TableSignatureView: View {
    @Binding var cellModel: TableCellModel
    @State var isEditable: Bool = false
    
    @State private var lines: [Line] = []
    @State private var savedLines: [Line] = []
    @State private var signatureImage: UIImage?
    @State private var showCanvasSignatureView: Bool = false
    
    var body: some View {
        Button(action: {
            loadImageFromURL()
            showCanvasSignatureView = true
            
        }, label: {
            Image(systemName: "signature")
                .foregroundColor((cellModel.data.title.isEmpty || cellModel.data.title == nil) ? .gray : .black)
        })
        .sheet(isPresented: $showCanvasSignatureView, onDismiss: {
            isEditable = false
        }) {
            CanvasSignatureView(lines: $lines, savedLines: $savedLines, signatureImage: $signatureImage, isEditable: $isEditable)
        }
        .onChange(of: signatureImage) { newImage in
            if let newImage = newImage, let data = newImage.pngData() {
                let base64String = data.base64EncodedString()
                cellModel.data.title = "data:image/png;base64,\(base64String)"
            } else {
                cellModel.data.title = ""
            }
            cellModel.didChange?(cellModel.data)
        }
    }
    
    func loadImageFromURL() {
        APIService.loadImage(from: cellModel.data.title ?? "") { imageData in
            if let imageData = imageData, let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.signatureImage = image
                }
            } else {
                print("\(String(describing: cellModel.data.title))")
            }
        }
    }
}
