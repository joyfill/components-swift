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
    @State var imagesArray: [UIImage] = []
    @State var imageURLs: [String] = []
    private let data: FieldTableColumn
    @State private var valueElements: [ValueElement] = []
    private var didChange: ((_ cell: FieldTableColumn) -> Void)?
    @State var showToast: Bool = false
     var uploadAction: () -> Void

     public init(data: FieldTableColumn, _ delegate: ((_ cell: FieldTableColumn) -> Void)? = nil) {
        self.data = data
         self.didChange = delegate
    }
    
    var body: some View {
        Button(action: {
            showMoreImages = true
        }, label: {
            HStack(spacing: 2) {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(imagesArray.count == 0 ? .gray : .black)
                Text(imagesArray.count == 0 ? "" : "+\(imagesArray.count)")
                    .foregroundColor(.black)
            }
        })
        .onChange(of: imagesArray) { arr in
            var editedCell = data
            editedCell.images = valueElements
            didChange?(editedCell)
        }
        .sheet(isPresented: $showMoreImages) {
            MoreImageView(valueElements: $valueElements, isMultiEnabled: true, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: false)

        }
    }
     
     func uploadAction() {
 //         let uploadEvent = UploadEvent(field: fieldDependency.fieldData!) { urls in
 //             for imageURL in urls {
 //                 showProgressView = true
 //                 imageViewModel.loadSingleURL(imageURL: imageURL, completion: { image in
 //                     let valueElement = valueElements.first { valueElement in
 //                         if valueElement.url == imageURL {
 //                             return true
 //                         }
 //                         return false
 //                     } ?? ValueElement(id: JoyfillModel.generateObjectId(), url: imageURL)
 //                     self.imageDictionary[valueElement] = image
 //                     valueElements.append(valueElement)
 //                     // valueElements upade
 //                     self.uiImagesArray.append(image)
 //                     showProgressView = false
 //                     print("imageDictionary \(urls)")
 //                 })
 //             }
 //         }
          fieldDependency.eventHandler.onUpload(event: uploadEvent)
     }
}

struct TableMoreImageView: View {
    var isUploadHidden: Bool
    @Binding var images: [UIImage]
    @State var selectedImages: Set<UIImage> = Set()
    
    @Environment(\.presentationMode) private var presentationMode
    
    private let mode: Mode = .fill

    private var data: FieldTableColumn
    
    public init(isUploadHidden: Bool, imagesArray: Binding<[UIImage]>, data: FieldTableColumn) {
        self.isUploadHidden = isUploadHidden
        _images = imagesArray
        self.data = data
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("More Images")
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.black)
                        .imageScale(.large)
                })
            }
            
            TableUploadDeleteView(imagesArray: $images, selectedImages: $selectedImages, data: data)
            
            ImageGridView(primaryDisplayOnly: false, images: $images, selectedImages: $selectedImages)
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16)
    }
}
struct TableUploadDeleteView: View {
    @Binding var imagesArray: [UIImage]
    @Binding var selectedImages: Set<UIImage>
    
    private let mode: Mode = .fill
    private var data: FieldTableColumn
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    public init(imagesArray: Binding<[UIImage]>,
                selectedImages: Binding<Set<UIImage>>,
                data: FieldTableColumn) {
        _imagesArray = imagesArray
        _selectedImages = selectedImages
        self.data = data
    }
    var body: some View {
        HStack {
            Button(action: {
                loadImagesFromURLs(imageURLs: ["https://png.pngtree.com/png-vector/20191121/ourmid/pngtree-blue-bird-vector-or-color-illustration-png-image_2013004.jpg"])
            }, label: {
                Image("UploadButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 28)
            })
            
            Button(action: {
                deleteSelectedImages()
            }, label: {
                Image(selectedImages.count > 0 ? "DeleteButton" : "")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 28)
            })
            Spacer()
        }
    }
    func loadImagesFromURLs(imageURLs: [String]) {
        imageViewModel.loadImageFromURL(imageURLs: imageURLs) { images in
            imagesArray.append(contentsOf: images)
        }
    }
    func deleteSelectedImages() {
        imagesArray = imagesArray.filter { !selectedImages.contains($0) }
        selectedImages.removeAll()
    }
}
