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
    
    public init(fieldIdentifier: FieldIdentifier, updateValue: ValueUnion?, chartData: ChartData? = nil) {
        self.fieldIdentifier = fieldIdentifier
        self.updateValue = updateValue
        self.chartData = chartData
    }
}

public struct ChartData {
    var xTitle: String?
    var yTitle: String?
    var xMax: Double?
    var xMin: Double?
    var yMax: Double?
    var yMin: Double?
    
    public init(xTitle: String? = nil, yTitle: String? = nil, xMax: Double? = nil, xMin: Double? = nil, yMax: Double? = nil, yMin: Double? = nil) {
        self.xTitle = xTitle
        self.yTitle = yTitle
        self.xMax = xMax
        self.xMin = xMin
        self.yMax = yMax
        self.yMin = yMin
    }
}

protocol FieldChangeEvents {
    func onChange(event: FieldChangeData)
    func onFocus(event: FieldIdentifier)
    func onUpload(event: UploadEvent)
}
