//
//  FieldHeaderView.swift
//

import Foundation
import SwiftUI

struct FieldHeaderView: View {
    let fieldDependency: FieldDependency
    @State private var alertMessage: String? = nil
    @State private var alertDescription: String? = nil
    @State private var showAlert: Bool = false
    
    public init(_ fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        if let title = fieldDependency.fieldData?.title {
            HStack(alignment: .top) {
                Text("\(title)")
                    .font(.headline.bold())
                
                if fieldDependency.fieldData?.required == true {
                    Image(systemName: "asterisk")
                        .foregroundColor(.red)
                        .imageScale(.small)
                }
                
                Spacer()
                let tipDescription = fieldDependency.fieldData?.tipDescription ?? ""
                let tipTitle = fieldDependency.fieldData?.tipTitle ?? ""
                if let tipVisible = fieldDependency.fieldData?.tipVisible {
                    if tipVisible == true && !(tipDescription.isEmpty && tipTitle.isEmpty) {
                        Button(action: {
                            if let tipTitle = fieldDependency.fieldData?.tipTitle,
                               let tipDescription = fieldDependency.fieldData?.tipDescription {
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
