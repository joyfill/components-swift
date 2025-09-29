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
     @State var valueElements: [ValueElement] = []
     @State var images: [ImageState] = []
     let isMultiEnabled: Bool
     var viewModel: TableDataViewModelProtocol?

     public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false, viewModel: TableDataViewModelProtocol? = nil) {
         _cellModel = cellModel
         _showMoreImages = State(wrappedValue: 6)
         self.isUsedForBulkEdit = isUsedForBulkEdit
         if !isUsedForBulkEdit {
             _valueElements = State(initialValue: cellModel.wrappedValue.data.valueElements)
         }
         isMultiEnabled = cellModel.wrappedValue.data.multi ?? false
         self.viewModel = viewModel
     }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            HStack(spacing: 2) {
                Image(systemName: "photo")
                    .grayLightThemeColor()
                Text(cellModel.data.valueElements.count == 0 ? "" : "+\(cellModel.data.valueElements.count)")
                    .darkLightThemeColor()
            }
            .font(.system(size: 15))
            .frame(maxWidth: .infinity, alignment: .center)
            .contentShape(Rectangle())
        } else {
        if #available(iOS 16, *) {
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
                .frame(maxWidth: .infinity, alignment: .center)
                .contentShape(Rectangle())
            })
            .accessibilityIdentifier("TableImageIdentifier")
            .sheet(isPresented: $showMoreImages2) {
                MoreImageView(images: $images, valueElements: $valueElements, isMultiEnabled: isMultiEnabled, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: false)
                    .disabled(cellModel.editMode == .readonly)
            }
            .onChange(of: showMoreImages) { newValue in
                showMoreImages2 = true
            }
            .onChange(of: valueElements) { newValue in
                let valueElements = newValue
                var data = cellModel.data
                data.valueElements = valueElements
                cellModel.data = data
                cellModel.didChange?(cellModel.data)
            }
        } else {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            })
            .accessibilityIdentifier("TableImageIdentifier")
            .fullScreenCover(isPresented: $showMoreImages2) {
                MoreImageView(images: $images, valueElements: $valueElements, isMultiEnabled: isMultiEnabled, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: false)
                    .disabled(cellModel.editMode == .readonly)
            }
            .onChange(of: showMoreImages) { newValue in
                showMoreImages2 = true
            }
            .onChange(of: valueElements) { newValue in
                let valueElements = newValue
                var data = cellModel.data
                data.valueElements = valueElements
                cellModel.data = data
                cellModel.didChange?(cellModel.data)
            }
        }
        }
    }
     
     func uploadAction() {
         let result = viewModel?.getParenthPath(rowId: cellModel.rowID)
         var rowIds: [String] = [cellModel.rowID]
         if isUsedForBulkEdit {
             rowIds = viewModel?.tableDataModel.selectedRows ?? []
         }
         let uploadEvent = UploadEvent(fieldEvent: cellModel.fieldIdentifier, target: "field.update", multi: isMultiEnabled, schemaId: result?.1, parentPath: result?.0, rowIds: rowIds, columnId: cellModel.data.id) { urls in
             var urlsToProcess: [String] = []
             if !isMultiEnabled {
                 if let firstURL = urls.first {
                     urlsToProcess = [firstURL]
                 }
                 images = []
                 valueElements = []
                 cellModel.data.valueElements = []
             } else {
                 urlsToProcess = urls
             }
             
             for imageURL in urlsToProcess {
                 let valueElement = cellModel.data.valueElements.first { valueElement in
                     if valueElement.url == imageURL {
                         return true
                     }
                     return false
                 } ?? ValueElement(id: JoyfillModel.generateObjectId(), url: imageURL)
                 self.valueElements.append(valueElement)
                 cellModel.data.valueElements.append(valueElement)
             }
         }
         cellModel.documentEditor?.onUpload(event: uploadEvent)
     }
}
