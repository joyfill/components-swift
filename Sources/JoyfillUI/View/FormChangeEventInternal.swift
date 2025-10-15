//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 21/11/24.
//

import JoyfillModel

/// Payload describing a field-level change emitted by the Joyfill UI layer.
public struct FieldChangeData {
    /// Identifier describing which field triggered the event.
    public var fieldIdentifier: FieldIdentifier
    /// Updated value provided by the field, if any.
    public var updateValue: ValueUnion?
    /// Updated chart metadata when the change originates from a chart field.
    public var chartData: ChartData?

    public init(fieldIdentifier: FieldIdentifier, updateValue: ValueUnion? = nil, chartData: ChartData? = nil) {
        self.fieldIdentifier = fieldIdentifier
        self.updateValue = updateValue
        self.chartData = chartData
    }
}

/// Supplemental chart information included with field change events.
public struct ChartData {
    /// X-axis title supplied by the chart editor.
    public var xTitle: String?
    /// Y-axis title supplied by the chart editor.
    public var yTitle: String?
    /// Maximum value of the X-axis.
    public var xMax: Double?
    /// Minimum value of the X-axis.
    public var xMin: Double?
    /// Maximum value of the Y-axis.
    public var yMax: Double?
    /// Minimum value of the Y-axis.
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
