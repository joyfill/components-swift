//
//  SwiftUIView.swift
import SwiftUI
import JoyfillModel

 struct TableImageView: View {
     @State var showMoreImages: Int = 5
     @State var showMoreImages2: Bool = false
     @State var showToast: Bool = false
     @Binding var cellModel: TableCellModel
     private var isUsedForBulkEdit = false

     public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false) {
         _cellModel = cellModel
         _showMoreImages = State(wrappedValue: 6)
         self.isUsedForBulkEdit = isUsedForBulkEdit
     }
    
    var body: some View {
        if #available(iOS 16, *) {
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
                    .frame(width: isUsedForBulkEdit ? nil : UIScreen.main.bounds.width)
                    .disabled(cellModel.editMode == .readonly)
            }
            .onChange(of: showMoreImages) { newValue in
                showMoreImages2 = true
            }
            .onChange(of: cellModel.data.valueElements) { newValue in
                let valueElements = newValue
                var data = cellModel.data
                data.valueElements = valueElements
                cellModel.data = data
                cellModel.didChange?(cellModel.data)
            }
        }
        else {
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
            .fullScreenCover(isPresented: $showMoreImages2) {
                MoreImageView(valueElements: $cellModel.data.valueElements, isMultiEnabled: true, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: false)
                    .frame(width: isUsedForBulkEdit ? nil : UIScreen.main.bounds.width)
                    .disabled(cellModel.editMode == .readonly)
            }
            .onChange(of: showMoreImages) { newValue in
                showMoreImages2 = true
            }
            .onChange(of: cellModel.data.valueElements) { newValue in
                cellModel.didChange?(cellModel.data)
            }
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
