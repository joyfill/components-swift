//
//  SignatureView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService

struct SignatureView: View {
    @State private var lines: [Line] = []
    @State var signatureImage: UIImage?
    @State var signatureURL: String = ""
    @State private var imageLoaded: Bool = false
    @State private var showCanvasSignatureView: Bool = false
    
    
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        _signatureURL = State(initialValue: fieldDependency.fieldData?.value?.signatureURL ?? "")
        if !imageLoaded {
            loadImageFromURL()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                HStack(alignment: .top) {
                    Text("\(title)")
                        .font(.headline.bold())
                    
                    if fieldDependency.fieldData?.fieldRequired == true && signatureImage == nil {
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                            .imageScale(.small)
                    }
                }
            }
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
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
            
            Button(action: {
                showCanvasSignatureView = true
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }, label: {
                Text("\(signatureImage != nil ? "Edit Signature" : "Add Signature")")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
            })
            .padding(.top, 6)
            
            NavigationLink(destination: CanvasSignatureView(lines: $lines, signatureImage: $signatureImage), isActive: $showCanvasSignatureView) {
                EmptyView()
            }
        }
        .onChange(of: signatureURL) { newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .string(newValue)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
    }
    func loadImageFromURL() {
        APIService().loadImage(from: signatureURL ?? "") { imageData in
            if let imageData = imageData, let image = UIImage(data: imageData) {
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
            Text("\(signatureImage != nil ? "Edit Signature" : "Add Signature")")
                .fontWeight(.bold)
            
            CanvasView(lines: $lines)
                .frame(height: 150)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
            
            HStack {
                Spacer()
                Button(action: {
                    self.lines = []
                }, label: {
                    Text("Clear")
                        .foregroundStyle(.black)
                        .frame(width: screenWidth * 0.3,height: 40)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                })
                
                Button(action: {
                    DispatchQueue.main.async {
                        signatureImage = CanvasView(lines: $lines)
                            .frame(width: screenWidth, height: 220)
                            .snapshot()
                    }
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Save")
                        .frame(minWidth: 100, maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding(.top, 10)
            Spacer()
        }
        .padding(.horizontal, 16.0)
    }
}
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
