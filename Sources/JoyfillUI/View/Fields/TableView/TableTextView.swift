//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 20/03/24.
//

import SwiftUI

struct TableTextView: View {
    private var cellModel: TableCellModel
    @State private var text = ""
    @State private var isTextFieldFocused: Bool = false
    @State private var textHeight: CGFloat = 50
    
    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            Text(cellModel.data.title ?? "")
        } else {
            ExpandingTextView(text: $text, height: $textHeight, isFocused: $isTextFieldFocused, mode: cellModel.viewMode)
                .frame(height: textHeight)
                .onChange(of: text) { newText in
                    if cellModel.data.title != text {
                        var editedCell = cellModel.data
                        editedCell.title = text
                        cellModel.didChange?(editedCell)
                    }
                }
                .onAppear {
                    text = cellModel.data.title ?? ""
                }
        }
    }
}

struct ExpandingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var isFocused: Bool
    let mode: TableViewMode
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        if isFocused {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
        DispatchQueue.main.async {
            height = uiView.sizeThatFits(uiView.frame.size).height
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: ExpandingTextView
        
        init(_ parent: ExpandingTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.height = textView.sizeThatFits(textView.frame.size).height
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
        }
    }
}
