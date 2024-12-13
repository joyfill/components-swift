//
//  FieldHeaderView.swift
//

import Foundation
import SwiftUI

struct FieldHeaderView: View {
    @State private var alertMessage: String? = nil
    @State private var alertDescription: String? = nil
    @State private var showAlert: Bool = false
    let fieldHeaderModel: FieldHeaderModel?
    
    public init(_ fieldHeaderModel: FieldHeaderModel?) {
        self.fieldHeaderModel = fieldHeaderModel
    }
    
    var body: some View {
        if let title = fieldHeaderModel?.title {
            HStack(alignment: .top) {
                Text("\(title)")
                    .font(.headline.bold())
                
                if fieldHeaderModel?.required == true {
                    Image(systemName: "asterisk")
                        .foregroundColor(.red)
                        .imageScale(.small)
                }
                
                Spacer()
                let tipDescription = fieldHeaderModel?.tipDescription ?? ""
                let tipTitle = fieldHeaderModel?.tipTitle ?? ""
                if let tipVisible = fieldHeaderModel?.tipVisible {
                    if tipVisible == true && !(tipDescription.isEmpty && tipTitle.isEmpty) {
                        Button(action: {
                            if let tipTitle = fieldHeaderModel?.tipTitle,
                               let tipDescription = fieldHeaderModel?.tipDescription {
                                alertMessage = tipTitle
                                alertDescription = tipDescription
                                showAlert = true
                            }
                        }, label: {
                            Image(systemName: "i.circle")
                        })
                        .accessibilityIdentifier("ToolTipIdentifier")
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text(alertMessage ?? ""),
                                message: Text(alertDescription ?? ""),
                                dismissButton: .default(Text("Dismiss"))
                            )
                        }
                    }
                }
            }
        }
    }
}

struct FieldHeaderModel {
    var title: String?
    var required: Bool?
    var tipDescription: String?
    var tipTitle: String?
    var tipVisible: Bool?
}
