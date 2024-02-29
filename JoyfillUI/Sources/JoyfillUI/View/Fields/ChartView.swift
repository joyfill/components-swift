//
//  ChartView.swift
//  JoyFill
//
//

import SwiftUI

struct ChartView: View {
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property

    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    var body: some View {
        Text("Hello, World!")
    }
}
