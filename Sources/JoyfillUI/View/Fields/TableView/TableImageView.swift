//
//  SwiftUIView.swift
import SwiftUI
import JoyfillModel

 struct TableImageView: View {
     @State private var showMoreImages: Bool = false
     private var cellModel: TableCellModel
     @State private var valueElements: [ValueElement] = []
     @State var showToast: Bool = false

     public init(cellModel: TableCellModel) {
         self.cellModel = cellModel
     }
    
    var body: some View {
        Button(action: {
            showMoreImages = true
        }, label: {
            HStack(spacing: 2) {
                Image(systemName: "photo")
                    .grayLightThemeColor()
                Text(valueElements.count == 0 ? "" : "+\(valueElements.count)")
                    .darkLightThemeColor()
            }
            .font(.system(size: 15))
        })
        .accessibilityIdentifier("TableImageIdentifier")
        .onAppear {
            valueElements = cellModel.data.images ?? []
        }
        .sheet(isPresented: $showMoreImages) {
            MoreImageView(valueElements: $valueElements, isMultiEnabled: true, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: false)
                .disabled(cellModel.editMode == .readonly)
        }
        .onChange(of: valueElements) { newValue in
            var editedCell = cellModel.data
            editedCell.images = valueElements
            cellModel.didChange?(editedCell)
        }
    }
     
     func uploadAction() {
         let uploadEvent = UploadEvent(field: cellModel.fieldData!) { urls in
             for imageURL in urls {
                 let valueElement = valueElements.first { valueElement in
                     if valueElement.url == imageURL {
                         return true
                     }
                     return false
                 } ?? ValueElement(id: JoyfillModel.generateObjectId(), url: imageURL)
                 valueElements.append(valueElement)
             }
             var editedCell = cellModel.data
             editedCell.images = valueElements
             cellModel.didChange?(editedCell)
         }
         cellModel.eventHandler.onUpload(event: uploadEvent)
     }
}
