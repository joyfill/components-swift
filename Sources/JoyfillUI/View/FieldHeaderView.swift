//
//  FieldHeaderView.swift
//

import Foundation
import SwiftUI

struct FieldHeaderView: View {
    let fieldDependency: FieldDependency
    
    public init(_ fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        if let title = fieldDependency.fieldData?.title {
            HStack(alignment: .top) {
                Text("\(title)")
                    .font(.headline.bold())
                
                if fieldDependency.fieldData?.fieldRequired == true {
                    Image(systemName: "asterisk")
                        .foregroundColor(.red)
                        .imageScale(.small)
                }
            }
        }
    }
}
