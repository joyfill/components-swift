//
//  SwiftUIView.swift
import SwiftUI
import JoyfillModel

 struct TableImageView: View {
     @State var showMoreImages: Int = 5
     @State var showMoreImages2: Bool = false
     @State private var valueElements: [ValueElementLocal] = []
     @State var showToast: Bool = false
     private var cellModel: TableCellModel

     public init(cellModel: TableCellModel) {
         self.cellModel = cellModel
         _showMoreImages = State(wrappedValue: 6)
     }
    
    var body: some View {
        Button(action: {
            showMoreImages = Int.random(in: 0...100)
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
            valueElements = cellModel.data.valueElements ?? []
        }
        .sheet(isPresented: $showMoreImages2) {
            MoreImageView(valueElements: $valueElements, isMultiEnabled: true, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: false)
                .disabled(cellModel.editMode == .readonly)
        }
        .onChange(of: showMoreImages) { newValue in
            showMoreImages2 = true
        }
        .onChange(of: valueElements) { newValue in
            var editedCell = cellModel.data
            editedCell.valueElements = valueElements
            cellModel.didChange?(editedCell)
        }
    }
     
     func uploadAction() {
         let fieldEvent = FieldEvent(fieldID: cellModel.fieldId, pageID: cellModel.pageId , fileID: cellModel.fileid)
         let uploadEvent = UploadEvent(fieldEvent: fieldEvent) { urls in
             for imageURL in urls {
                 let valueElement = valueElements.first { valueElement in
                     if valueElement.url == imageURL {
                         return true
                     }
                     return false
                 } ?? ValueElementLocal(id: JoyfillModel.generateObjectId(), url: imageURL)
                 valueElements.append(valueElement)
             }
             var editedCell = cellModel.data
             editedCell.valueElements = valueElements
             cellModel.didChange?(editedCell)
         }
         cellModel.documentEditor?.onUpload(event: uploadEvent)
     }
}
