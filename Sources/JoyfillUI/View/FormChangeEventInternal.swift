//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 21/11/24.
//

import JoyfillModel

public struct FieldChangeData {
    public var fieldIdentifier: FieldIdentifier
    public var updateValue: ValueUnion?
    public var chartData: ChartData?

    public init(fieldIdentifier: FieldIdentifier, updateValue: ValueUnion? = nil, chartData: ChartData? = nil) {
        self.fieldIdentifier = fieldIdentifier
        self.updateValue = updateValue
        self.chartData = chartData
    }
}

public struct ChartData {
    public var xTitle: String?
    public var yTitle: String?
    public var xMax: Double?
    public var xMin: Double?
    public var yMax: Double?
    public var yMin: Double?

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
