//
//  ImageView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI

// Logo or Graphic

struct ImageView: View {
    var imageURL: String?
    @State var profileImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var imageLoaded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Image")
            
            Button(action: {
                    showImagePicker = true
            }, label: {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                } else {
                    Image("UploadImageBorder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                }
            })
            .onAppear{
                if !imageLoaded {
                    loadImageFromURL()
                }
            }
            .padding(.horizontal, 16)
            
            NavigationLink(destination: ImagePickerView(selectedImage: $profileImage, isCamera: false), isActive: $showImagePicker) {
                EmptyView()
            }
        }
        .padding(.horizontal, 16)
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
    ImageView(profileImage: UIImage())
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
