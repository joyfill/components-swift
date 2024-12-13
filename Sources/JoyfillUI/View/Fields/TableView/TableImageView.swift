//
//  SwiftUIView.swift
import SwiftUI
import JoyfillModel

 struct TableImageView: View {
     @State var showMoreImages: Int = 5
     @State var showMoreImages2: Bool = false
     @State var showToast: Bool = false
     @Binding var cellModel: TableCellModel

     public init(cellModel: Binding<TableCellModel>) {
         _cellModel = cellModel
         _showMoreImages = State(wrappedValue: 6)
     }
    
    var body: some View {
        Button(action: {
            showMoreImages = Int.random(in: 0...100)
        }, label: {
            HStack(spacing: 2) {
                Image(systemName: "photo")
                    .grayLightThemeColor()
                Text(cellModel.data.valueElements.count == 0 ? "" : "+\(cellModel.data.valueElements.count)")
                    .darkLightThemeColor()
            }
            .font(.system(size: 15))
        })
        .accessibilityIdentifier("TableImageIdentifier")
        .sheet(isPresented: $showMoreImages2) {
            MoreImageView(valueElements: $cellModel.data.valueElements, isMultiEnabled: true, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: false)
                .disabled(cellModel.editMode == .readonly)
        }
        .onChange(of: showMoreImages) { newValue in
            showMoreImages2 = true
        }
        .onChange(of: cellModel.data.valueElements) { newValue in
            cellModel.didChange?(cellModel.data)
        }
    }
     
     func uploadAction() {
         let uploadEvent = UploadEvent(fieldEvent: cellModel.fieldIdentifier) { urls in
             for imageURL in urls {
                 let valueElement = cellModel.data.valueElements.first { valueElement in
                     if valueElement.url == imageURL {
                         return true
                     }
                     return false
                 } ?? ValueElement(id: JoyfillModel.generateObjectId(), url: imageURL)
                 cellModel.data.valueElements.append(valueElement)
             }
             cellModel.didChange?(cellModel.data)
         }
         cellModel.documentEditor?.onUpload(event: uploadEvent)
     }
}
