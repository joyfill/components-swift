import SwiftUI
import JoyfillModel

struct SignatureView: View {
    @State private var lines: [Line] = []
    @State var signatureImage: UIImage?
    @State private var savedLines: [Line] = []
    @State var signatureURL: String = ""
    @State private var showCanvasSignatureView: Bool = false
    @State var isEditable: Bool = true
    
    @State var hasAppeared: Bool = false
    @State private var ignoreOnChangeOnDefaultImageLoad: Bool = false
    @State var showError: Bool = false

    private var signatureDataModel: SignatureDataModel
    let eventHandler: FieldChangeEvents

    public init(signatureDataModel: SignatureDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        self.signatureDataModel = signatureDataModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(signatureDataModel.fieldHeaderModel)
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                .frame(height: 150)
                .overlay(content: {
                    if let signatureImage = signatureImage {
                        Image(uiImage: signatureImage)
                            .resizable()
                            .scaledToFit()
                    }
                    if showError {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.red)
                            Text("Failed to load signature")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                })
            
            Button(action: {
                showCanvasSignatureView = true
                eventHandler.onFocus(event: signatureDataModel.fieldIdentifier)
            }, label: {
                Text("\(!signatureURL.isEmpty ? "Edit Signature" : "Add Signature")")
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
            
            NavigationLink(destination: CanvasSignatureView(lines: $lines, savedLines: $savedLines, signatureImage: $signatureImage, signatureURL: $signatureURL, showError: $showError, isEditable: $isEditable), isActive: $showCanvasSignatureView) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
        .onAppear{
            if !hasAppeared {
                self.signatureURL = signatureDataModel.signatureURL ?? ""
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
                    guard let base64EncodedString = convertImageToBase64(signatureImage) else {
                        Log("Unable to convert image to base64", type: .error)
                        return
                    }
                    url = "data:image/png;base64,\(base64EncodedString)"
                }
                DispatchQueue.main.async {
                    signatureURL = url
                }
            }
        }
        .onChange(of: signatureURL) { newValue in
            let newSignatureImageValue = ValueUnion.string(newValue ?? "")
            let fieldEvent = FieldChangeData(fieldIdentifier: signatureDataModel.fieldIdentifier, updateValue: newSignatureImageValue)
            eventHandler.onChange(event: fieldEvent)
        }
    }
    
    func loadImageFromURL() {
        if !signatureURL.isEmpty {
            APIService.loadImage(from: signatureURL) { imageData in
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.signatureImage = image
                        ignoreOnChangeOnDefaultImageLoad = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showError = true
                    }
                    Log("Invalid signature URL or failed to load image: \(String(describing: signatureURL))", type: .warning)
                }
            }
        }
    }
    func convertImageToBase64(_ image: UIImage) -> String? {
        guard let imageData = image.pngData() else {
            Log("Failed to convert UIImage to Data.", type: .error)
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
    @Binding var signatureCanvasImage: UIImage?
    @Binding var showCanvasError: Bool
    
    var body: some View {
        ZStack {
            if let signatureImage = signatureCanvasImage, lines.isEmpty {
                Image(uiImage: signatureImage)
                    .resizable()
                    .scaledToFit()
            }
            
            if showCanvasError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                    Text("Failed to load signature")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            
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
                    self.signatureCanvasImage = nil
                    self.showCanvasError = false
                    let newPoint = value.location
                    currentLine.points.append(newPoint)
                    self.lines.append(currentLine)
                })
                    .onEnded({value in
                        self.currentLine = Line(points: [])
                    }))
        }
    }
}

struct CanvasSignatureView: View {
    @Binding var lines: [Line]
    @Binding var savedLines: [Line]
    @Binding var signatureImage: UIImage?
    @State var signatureCanvasImage: UIImage?
    @State var showCanvasError: Bool = false
    @Binding var signatureURL: String
    @Binding var showError: Bool
    @Binding var isEditable: Bool
    @Environment(\.presentationMode) private var presentationMode
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(signatureImage != nil ? "Edit Signature" : "Add Signature")")
                .fontWeight(.bold)
                .padding(.top, 12)
            
            if isEditable {
                CanvasView(lines: $lines, signatureCanvasImage: $signatureCanvasImage, showCanvasError: $showCanvasError)
                    .frame(height: 150)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
            } else {
                if let signatureImage = signatureImage {
                    ZStack(alignment: .bottomTrailing) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            .frame(height: 150)
                            .overlay {
                                Image(uiImage: signatureImage)
                                    .resizable()
                                    .scaledToFit()
                            }
                        
                        Button(action: {
                            isEditable = true
                        }, label: {
                            HStack {
                                Text("Edit")
                                    .darkLightThemeColor()
                                Image(systemName: "pencil")
                                    .foregroundStyle(.black)
                            }
                            .frame(width: 80,height: 30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            )
                        })
                        .padding(.all, 10)
                        .accessibilityIdentifier("TableSignatureEditButton")
                    }
                    .onAppear {
                        signatureCanvasImage = signatureImage
                        showCanvasError = showError
                    }
                } else {
                    CanvasView(lines: $lines, signatureCanvasImage: $signatureCanvasImage, showCanvasError: $showCanvasError)
                        .frame(height: 150)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                }
            }
            
            if isEditable || signatureImage == nil {
                HStack {
                    Spacer()
                    Button(action: {
                        lines.removeAll()
                        signatureCanvasImage = nil
                        showCanvasError = false
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
                        if lines.isEmpty && signatureCanvasImage == nil && showCanvasError == false {
                            savedLines = []
                            signatureImage = nil
                            signatureURL = ""
                            showError = false
                            presentationMode.wrappedValue.dismiss()
                            return
                        }
                        if !showCanvasError {
                            signatureImage = CanvasView(lines: $lines, signatureCanvasImage: $signatureCanvasImage, showCanvasError: $showCanvasError)
                                .frame(width: screenWidth, height: 220)
                                .snapshot()
                        }
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
            }
            Spacer()
        }
        .onAppear {
            signatureCanvasImage = signatureImage
            showCanvasError = showError
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

