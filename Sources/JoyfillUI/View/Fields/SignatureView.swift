import SwiftUI
import Combine
import JoyfillModel

struct SignatureView: View {
    @State private var lines: [Line] = []
    @State var signatureImage: UIImage?
    @State private var savedLines: [Line] = []
    @State private var savedTypedSignature: String = ""
    @State var signatureURL: String = ""
    @State private var showCanvasSignatureView: Bool = false
    @State var isEditable: Bool = true
    
    @State var hasAppeared: Bool = false
    @State private var ignoreOnChangeOnDefaultImageLoad: Bool = false
    @State var showError: Bool = false

    @Environment(\.navigationFocusFieldId) private var navigationFocusFieldId
    @Environment(\.footerContainer) private var footerContainer
    private var signatureDataModel: SignatureDataModel
    let eventHandler: FieldChangeEvents

    public init(signatureDataModel: SignatureDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        self.signatureDataModel = signatureDataModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(signatureDataModel.fieldHeaderModel, isFilled: !signatureURL.isEmpty) { decorator in
                eventHandler.onDecoratorAction(event: signatureDataModel.fieldIdentifier, action: decorator.action ?? "")
            }
            RoundedRectangle(cornerRadius: 10)
                .stroke(navigationFocusFieldId == signatureDataModel.fieldIdentifier.fieldID ? Color.focusedFieldBorderColor : Color.allFieldBorderColor, lineWidth: 1)
                .frame(height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemGray5))
                )
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
                signatureDataModel.documentEditor?.setOpenNavigationFieldID(signatureDataModel.fieldIdentifier.fieldID)
                eventHandler.onFocus(event: signatureDataModel.fieldIdentifier)
            }, label: {
                Text("\(!signatureURL.isEmpty ? "Edit Signature" : "Add Signature")")
                    .darkLightThemeColor()
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(navigationFocusFieldId == signatureDataModel.fieldIdentifier.fieldID ? Color.focusedFieldBorderColor : Color.allFieldBorderColor, lineWidth: 1)
                    )
            })
            .accessibilityIdentifier("SignatureIdentifier")
            .padding(.top, 6)
            
            NavigationLink(destination: CanvasSignatureView(lines: $lines, savedLines: $savedLines, savedTypedSignature: $savedTypedSignature, signatureImage: $signatureImage, signatureURL: $signatureURL, showError: $showError, isEditable: $isEditable, documentEditor: signatureDataModel.documentEditor, fieldID: signatureDataModel.fieldIdentifier.fieldID).environment(\.footerContainer, footerContainer), isActive: $showCanvasSignatureView) {
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
            let newSignatureImageValue = ValueUnion.string(newValue)
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
        Color.black
    }
    var lineWidth: Double = 2.0
}

struct TypeToSign: View {
    @Binding var typeSign: String
    let fontName: String
    
    var body: some View {
        
        TextField("Type Signature", text: $typeSign)
            .font(.custom(fontName, size: 60))
            .foregroundColor(typeSign.isEmpty ? .gray.opacity(0.7) : .black.opacity(0.92))
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
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
            
            if showCanvasError, lines.isEmpty {
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
    @Binding var savedTypedSignature: String
    @Binding var signatureImage: UIImage?
    @State var signatureCanvasImage: UIImage?
    @State var showCanvasError: Bool = false
    @State var signatureInputMode: SignatureInputMode = .draw
    @State private var typedSignatureText: String = ""
    @Binding var signatureURL: String
    @Binding var showError: Bool
    @Binding var isEditable: Bool
    var documentEditor: DocumentEditor?
    var fieldID: String?
    @Environment(\.presentationMode) private var presentationMode
    let screenWidth = UIScreen.main.bounds.width
    private let typedSignatureFontName = "SignPainter-HouseScript Semibold"
    
    var body: some View {
        VStack(alignment: .leading) {
                Text("\(signatureImage != nil ? "Edit Signature" : "Add Signature")")
                    .fontWeight(.bold)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            HStack {
                if isEditable || signatureImage == nil {
                    Button(action: {
                        signatureInputMode = .draw
                    }, label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.tip")
                            Text("Draw")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundColor(signatureInputMode == .draw ? .white : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(signatureInputMode == .draw ? Color.accentColor : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                    })
                    Spacer().frame(width: 8)
                    Button(action: {
                        signatureInputMode = .type
                    }, label: {
                        HStack(spacing: 6) {
                            Image(systemName: "keyboard")
                            Text("Type")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundColor(signatureInputMode == .type ? .white : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(signatureInputMode == .type ? Color.accentColor : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                    })
                }
            }
            if isEditable {
                if signatureInputMode == .draw {
                    CanvasView(lines: $lines, signatureCanvasImage: $signatureCanvasImage, showCanvasError: $showCanvasError)
                        .frame(height: 150)
                        .cornerRadius(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                } else {
                    TypeToSign(typeSign: $typedSignatureText, fontName: typedSignatureFontName)
                        .frame(height: 150)
                        .cornerRadius(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                }
            } else {
                if let signatureImage = signatureImage {
                    ZStack(alignment: .bottomTrailing) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            .frame(height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemGray5))
                            )
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
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray5))
                        )
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
                        typedSignatureText = ""
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
                        if signatureInputMode == .draw{
                            if lines.isEmpty && signatureCanvasImage == nil && showCanvasError == false {
                                savedLines = []
                                savedTypedSignature = ""
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
                                showError = false
                            }
                            savedLines = lines
                            savedTypedSignature = ""
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            let trimmedTypedSignatureText = typedSignatureText.trimmingCharacters(in: .whitespacesAndNewlines)
                                if trimmedTypedSignatureText.isEmpty {
                                    savedLines = []
                                    savedTypedSignature = ""
                                    signatureImage = nil
                                    signatureURL = ""
                                    showError = false
                                    presentationMode.wrappedValue.dismiss()
                                    return
                                }
                                savedTypedSignature = trimmedTypedSignatureText
                                signatureImage = typedSignatureSnapshot(text: trimmedTypedSignatureText)
                                signatureCanvasImage = signatureImage
                                lines.removeAll()
                                savedLines = []
                                showCanvasError = false
                                showError = false
                                presentationMode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text("Save")
                            .foregroundColor(.white)
                            .frame(minWidth: 100, maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.accentColor)
                            )
                    })
                    .accessibilityIdentifier("SaveSignatureIdentifier")
                    Spacer()
                }
                .padding(.top, 10)
            }
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .onAppear {
            signatureCanvasImage = signatureImage
            showCanvasError = showError
            typedSignatureText = savedTypedSignature
        }
        .onDisappear {
            documentEditor?.setOpenNavigationFieldID(nil)
        }
        .onReceive(documentEditor?.dismissNavigationPublisher.eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()) { targetFieldID in
            if targetFieldID == fieldID {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .safeAreaInset(edge: .bottom) {
            FormFooterView()
        }
    }

    private func typedSignatureSnapshot(text: String) -> UIImage {
        TypedSignatureSnapshotView(text: text, fontName: typedSignatureFontName)
                .frame(width: screenWidth, height: 220)
                .snapshot()
    }
}

private struct TypedSignatureSnapshotView: View {
    let text: String
    let fontName: String

    var body: some View {
        ZStack {
            Color.clear
            Text(text)
                .font(.custom(fontName, size: 72))
                .foregroundColor(.black.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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

enum SignatureInputMode {
    case draw
    case type
}
