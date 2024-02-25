//
//  ImageView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel

// Logo or Graphic

struct ImageView: View {
    @State var imageURL: String?
    @State var profileImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var imageLoaded: Bool = false
    @State private var imageCount: Int = 4
    
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
            
            Button(action: {
                    showImagePicker = true
            }, label: {
                if let profileImage = profileImage {
                    ZStack {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                        HStack{
                            Text("More > ")
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                            Text("+\(imageCount)")
                                .tint(.black)
                                .padding(.vertical, 10)
                                .padding(.trailing, 10)
                        }
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.leading, 50)
                        .padding(.top, 50)
                    }
                } else {
                    ZStack {
                        Image("ImageUploadRectSmall")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                        HStack() {
                            Text("Upload")
                                .tint(.black)
                            Image("Upload_Icon")
                                .resizable()
                                .frame(width: 18,height: 18)
                        }
                    }
                }
            })
            .padding(.horizontal, 16)
            .sheet(isPresented: $showImagePicker, content: {
                ImagePickerView(selectedImage: $profileImage, isCamera: false)
            })
            
        }
        .padding(.horizontal, 16)
        .onAppear {
            if let value = fieldData?.value?.imageURLs {
                self.imageURL = value[0]
                imageCount = value.count
            }
            
            if !imageLoaded {
                loadImageFromURL()
            }
        }
    }
    func loadImageFromURL() {
        JoyDocViewModel().loadImage(from: imageURL ?? "") { image in
            if let image = image {
                DispatchQueue.main.async {
                    profileImage = image
                    imageLoaded = true
                }
            } else {
                print("Failed to load image from URL: \(String(describing: imageURL))")
            }
        }
    }
}

#Preview {
    ImageView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
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
