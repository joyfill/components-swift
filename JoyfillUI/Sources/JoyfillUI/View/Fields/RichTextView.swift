//
//  ChartView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI

struct RichTextView: View {
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property

    init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    var body: some View {
        Text("Hello, World!")
    }
}
