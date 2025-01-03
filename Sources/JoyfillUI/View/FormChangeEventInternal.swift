//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 21/11/24.
//

import JoyfillModel

public struct FieldChangeData {
    var fieldIdentifier: FieldIdentifier
    var updateValue: ValueUnion?
    var chartData: ChartData?
}

struct ChartData {
    var xTitle: String?
    var yTitle: String?
    var xMax: Double?
    var xMin: Double?
    var yMax: Double?
    var yMin: Double?
}

protocol FieldChangeEvents {
    func onChange(event: FieldChangeData)
    func onFocus(event: FieldIdentifier)
    func onUpload(event: UploadEvent)
}
