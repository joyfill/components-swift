//
//  ImageView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService

// Logo or Graphic

struct ImageView: View {
    @State var imageURL: String?
    @State var profileImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var showMoreImages: Bool = false
    @State private var imageLoaded: Bool = false
    @State private var showProgressView : Bool = false
    @State private var imageCount: Int = 4
    @State var imagesArray: [UIImage] = []
    @State var imageURLs: [String] = []
    
    private let mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    
    public init(eventHandler: FieldEventHandler, fieldPosition: FieldPosition, fieldData: JoyDocField? = nil) {
        self.eventHandler = eventHandler
        self.fieldPosition = fieldPosition
        self.fieldData = fieldData
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Image")
                .fontWeight(.bold)
            
                if let profileImage = profileImage {
                    ZStack {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                        Button(action: {
                            showMoreImages = true
                        }, label: {
                            HStack {
                                Text("More > ")
                                
                                Text("+\(imageCount)")
                                    .foregroundColor(.black)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(Color.white)
                            .cornerRadius(10)
                        })
                        .padding(.top, 200)
                        .padding(.leading, 250)
                        .sheet(isPresented: $showMoreImages, content: {
                            MoreImageView(isUploadHidden: fieldPosition.primaryDisplayOnly ?? false, images: $imagesArray)
                        })
                    }
                } else {
                    Button(action: {
                        let uploadEvent = UploadEvent(field: fieldData!) { url in
                            imageURLs.append(url)
                            showProgressView = true
                            loadImageFromURL()
                        }
                        eventHandler.onUpload(event: uploadEvent)
                    }, label: {
                        ZStack {
                            Image("ImageUploadRectSmall")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                            Image("Upload_Icon")
                                .resizable()
                                .frame(width: 69,height: 18)
                            if showProgressView {
                                ProgressView()
                            }
                        }
                    })
                }
        }
        .padding(.horizontal, 16)
        .onAppear {
            if let imageURLs = fieldData?.value?.imageURLs {
                imageCount = imageURLs.count
                for imageURL in imageURLs {
                    self.imageURLs.append(imageURL)
                }
            }
            if !imageLoaded {
                loadImageFromURL()
            }
        }
    }
    func loadImageFromURL() {
        for imageURL in self.imageURLs {
            APIService().loadImage(from: imageURL ?? "") { imageData in
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        showProgressView = false
                        profileImage = image
                        imagesArray.append(image)
                        imageLoaded = true
                    }
                } else {
                    print("Failed to load image from URL: \(String(describing: imageURL))")
                }
            }
        }
    }
}
struct MoreImageView: View {
    var isUploadHidden: Bool
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) private var presentationMode
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
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                })
            }
            if isUploadHidden {
                UploadDeleteView()
                    .hidden()
            } else {
                UploadDeleteView()
            }
            ImageGridView(images: $images)
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16)
    }
}
struct UploadDeleteView: View {
    var body: some View {
        HStack {
            Button(action: {
                
            }, label: {
                    Image("UploadButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
            })
            
            Button(action: {
                
            }, label: {
                Image("DeleteButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 28)
            })
            Spacer()
        }
    }
}

struct ImageGridView:View {
    @Binding var images: [UIImage]
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
             ForEach(images, id: \.self) { image in
               Image(uiImage: image)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .cornerRadius(10)
             }
           }
    }
}

#Preview {
    UploadDeleteView()
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    var isCamera: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
//        imagePicker.cameraCaptureMode = .photo
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = isCamera ? .camera : .photoLibrary
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] {
                parent.selectedImage = image as? UIImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
