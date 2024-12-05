//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 05/12/24.
//

import JoyfillModel
import Foundation

extension DocumentEditor {

    func fieldIndexMapValue(pageID: String, index: Int) -> String {
        return "\(pageID)|\(index)"
    }

    func mapWebViewToMobileView(fieldPositions: [FieldPosition]) -> [FieldPosition] {
        let sortedFieldPositions = fieldPositions.sorted { fp1, fp2 in
            guard let y1 = fp1.y, let y2 = fp2.y else { return false }
            return Int(y1) < Int(y2)
        }
        var uniqueFields = Set<String>()
        var resultFieldPositions = [FieldPosition]()
        resultFieldPositions.reserveCapacity(sortedFieldPositions.count)

        for fp in sortedFieldPositions {
            if let field = fp.field, uniqueFields.insert(field).inserted {
                resultFieldPositions.append(fp)
            }
        }
        return resultFieldPositions
    }

    private func pageIDAndIndex(key: String) -> (String, Int) {
        let components = key.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
        let pageID = components.first.map(String.init) ?? ""
        let index = components.last.map { Int(String($0))! }!
        return (pageID, index)
    }

    func updateValue(event: FieldChangeEvent) {
        if var field = field(fieldID: event.fieldID) {
            field.value = event.updateValue
            if let chartData = event.chartData {
                field.xMin = chartData.xMin
                field.yMin = chartData.yMin
                field.xMax = chartData.xMax
                field.yMax = chartData.yMax
                field.xTitle = chartData.xTitle
                field.yTitle = chartData.yTitle
            }
            updatefield(field: field)
            document.fields = allFields
            refreshDependent(fieldID: event.fieldID)
        }
    }

    func refreshField(fieldId: String) {
        let pageIDIndexValue = fieldIndexMap[fieldId]!
        let (pageID, index) = pageIDAndIndex(key: pageIDIndexValue)
        pageFieldModels[pageID]!.fields[index].refreshID = UUID()
    }

    private func valueElements(fieldID: String) -> [ValueElement]? {
        return field(fieldID: fieldID)?.valueToValueElements
    }
}
