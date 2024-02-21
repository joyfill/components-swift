//
//  SignatureView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI

struct SignatureView: View {
    @State private var lines: [Line] = []
    @State var signatureImage: UIImage?
    var signatureURL: String?
    @State private var imageLoaded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Signature")
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
                .frame(height: 150)
                .overlay(
                    signatureImage != nil ?
                    Image(uiImage: signatureImage!)
                        .resizable()
                        .scaledToFit()
                    :
                        Image("")
                        .resizable()
                        .scaledToFit()
                )
            
            NavigationLink {
                CanvasSignatureView(lines: $lines, signatureImage: $signatureImage)
            } label: {
                Text("Sign")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .padding(.top, 10)
        }
        .onAppear{
            if !imageLoaded {
                loadImageFromURL()
            }
        }
        .padding(.horizontal, 16)
    }
    func loadImageFromURL() {
        JoyDocViewModel().loadImage(from: signatureURL ?? "") { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.signatureImage = image
                    imageLoaded = true
                }
            } else {
                print("Failed to load image from URL: \(String(describing: signatureURL))")
            }
        }
    }
}

struct Line {
    var points = [CGPoint]()
    var color: Color = Color.black
    var lineWidth: Double = 2.0
}

struct CanvasView: View {
    @State var currentLine = Line()
    @Binding var lines: [Line]

    var body: some View {
            ZStack {
                Canvas{context ,size in
                    for line in lines {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(line.color),style:StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                    }
                }
                .gesture(DragGesture(minimumDistance: 0,coordinateSpace: .local)
                    .onChanged({value in
                        let newPoint = value.location
                        currentLine.points.append(newPoint)
                        self.lines.append(currentLine)
                    })
                        .onEnded({value in
                            self.currentLine = Line(points: [])
                        }))
            }
        }
        
    private func getDigits(number: Int) -> [Int] {
        guard number > 0 else { return [number] }
        var firstDigit = number
        var digits = [Int]()
        while firstDigit > 0 {
            digits.append(firstDigit%10)
            firstDigit = firstDigit / 10
        }
        return digits.reversed()
    }
  
}

struct CanvasSignatureView: View {
    @State private var enterYourSignName: String = ""
    @Binding var lines: [Line]
    @Binding var signatureImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Signature")
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
            
            CanvasView(lines: $lines)
                .frame(height: 200)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
        
        
            HStack {
                TextField("Type to sign", text: $enterYourSignName)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(10)
                
                Button(action: {
                    self.lines = []
                }, label: {
                    Text("Clear")
                        .foregroundStyle(.black)
                        .frame(width: screenWidth * 0.3,height: 40)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                })
                
            }
            .padding(.top, 10)
            HStack {
                Spacer()
                Button(action: {
                    DispatchQueue.main.async {
                        signatureImage = CanvasView(lines: $lines)
                             .snapshot()
                    }
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Save")
                })
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .navigationBarBackButtonHidden()
        
    }
}
// UIImage Extension
//extension UIImage {
//    func rotate(radians: CGFloat) -> UIImage {
//        let rotatedSize = CGRect(origin: .zero, size: size)
//            .applying(CGAffineTransform(rotationAngle: radians))
//            .integral.size
//        UIGraphicsBeginImageContext(rotatedSize)
//        if let context = UIGraphicsGetCurrentContext() {
//            let origin = CGPoint(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
//            context.translateBy(x: origin.x, y: origin.y)
//            context.rotate(by: radians)
//            draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))
//            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            return rotatedImage ?? self
//        }
//        return self
//    }
//    
//    convenience init(view: any View) {
//        UIGraphicsBeginImageContext(view.frame())
//        view.layer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        self.init(cgImage: (image?.cgImage)!)
//    }
//}
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        let view = controller.view
        
        let renderer = UIGraphicsImageRenderer(size: view!.bounds.size)
        let image = renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}
