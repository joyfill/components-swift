//
//  SwiftUIView.swift
//
//
//  Created by Nand Kishore on 06/03/24.
//

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
                    .font(.title2)
                    .foregroundColor(valueElements.count == 0 ? .gray : .black)
                Text(valueElements.count == 0 ? "" : "+\(valueElements.count)")
                    .foregroundColor(.black)
            }
        })
        .onAppear(perform: {
            
        })
        .onAppear {
            valueElements = cellModel.data.images ?? []
        }
        .sheet(isPresented: $showMoreImages) {
            MoreImageView(valueElements: $valueElements, isMultiEnabled: true, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: false)
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
