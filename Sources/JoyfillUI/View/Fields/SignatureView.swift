import SwiftUI
import JoyfillModel

struct SignatureView: View {
    @State private var lines: [Line] = []
    @State var signatureImage: UIImage?
    @State private var savedLines: [Line] = []
    @State var signatureURL: String = ""
    @State private var showCanvasSignatureView: Bool = false

    @State var hasAppeared: Bool = false
    @State private var ignoreOnChangeOnDefaultImageLoad: Bool = false

    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(fieldDependency)
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                .frame(height: 150)
                .overlay(content: {
                    if let signatureImage = signatureImage {
                        Image(uiImage: signatureImage)
                            .resizable()
                            .scaledToFit()
                    }
                })
            
            Button(action: {
                showCanvasSignatureView = true
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }, label: {
                Text("\(signatureImage != nil ? "Edit Signature" : "Add Signature")")
                    .darkLightThemeColor()
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
            })
            .accessibilityIdentifier("SignatureIdentifier")
            .padding(.top, 6)
            
            NavigationLink(destination: CanvasSignatureView(lines: $lines, savedLines: $savedLines, signatureImage: $signatureImage), isActive: $showCanvasSignatureView) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
        .onAppear{
            if !hasAppeared {
                self.signatureURL = fieldDependency.fieldData?.value?.signatureURL ?? ""
                hasAppeared = true
                loadImageFromURL()
            }
        }
        .onChange(of: signatureImage) { newValue in
            guard !ignoreOnChangeOnDefaultImageLoad else {
                ignoreOnChangeOnDefaultImageLoad = false
                return
            }
            DispatchQueue.global().async {
                var url = ""
                if let signatureImage = signatureImage {
                    url = "data:image/png;base64,\(convertImageToBase64(signatureImage)!)"
                }
                let newSignatureImageValue = ValueUnion.string(url ?? "")
                guard fieldDependency.fieldData?.value != newSignatureImageValue else { return }
                guard var fieldData = fieldDependency.fieldData else {
                    fatalError("FieldData should never be null")
                }
                fieldData.value = newSignatureImageValue
                DispatchQueue.main.async {
                    fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
                }
            }
        }
    }
    
    func loadImageFromURL() {
        APIService.loadImage(from: signatureURL ?? "") { imageData in
            if let imageData = imageData, let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.signatureImage = image
                    ignoreOnChangeOnDefaultImageLoad = true
                }
            } else {
                print("\(String(describing: signatureURL))")
            }
        }
    }
    func convertImageToBase64(_ image: UIImage) -> String? {
        guard let imageData = image.pngData() else {
            print("Failed to convert UIImage to Data.")
            return nil
        }
        return imageData.base64EncodedString()
    }
}

struct Line: Equatable {
    var points = [CGPoint]()
    var color: Color {
        Color.primary
    }
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
            .accessibilityIdentifier("CanvasIdentifier")
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
    @Binding var savedLines: [Line]
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
                        .darkLightThemeColor()
                        .frame(width: screenWidth * 0.3,height: 40)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                })
                .accessibilityIdentifier("ClearSignatureIdentifier")
                
                Button(action: {
                    guard !lines.isEmpty else {
                        savedLines = []
                        signatureImage = nil
                        presentationMode.wrappedValue.dismiss()
                        return
                    }
                    signatureImage = CanvasView(lines: $lines)
                        .frame(width: screenWidth, height: 220)
                        .snapshot()
                    savedLines = lines
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Save")
                        .frame(minWidth: 100, maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("SaveSignatureIdentifier")
                Spacer()
            }
            .padding(.top, 10)
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .onAppear {
            if lines.isEmpty {
                lines = savedLines
            }
        }
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
