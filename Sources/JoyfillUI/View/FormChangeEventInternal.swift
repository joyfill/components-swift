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
}

public struct ChartData {
    public var xTitle: String?
    public var yTitle: String?
    public var xMax: Double?
    public var xMin: Double?
    public var yMax: Double?
    public var yMin: Double?
}

protocol FieldChangeEvents {
    func onChange(event: FieldChangeData)
    func onFocus(event: FieldIdentifier)
    func onUpload(event: UploadEvent)
}
