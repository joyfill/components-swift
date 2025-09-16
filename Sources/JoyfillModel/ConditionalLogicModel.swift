//
//  File.swift
//  
//

import Foundation
import JoyfillModel
import SwiftUI

public struct LogicModel {
    public var id: String?
    public var action: String?
    public var eval: String?
    public var conditions: [ConditionModel]?

    public init(
        id: String? = nil,
        action: String? = nil,
        eval: String? = nil,
        conditions: [ConditionModel]? = nil
    ) {
        self.id = id
        self.action = action
        self.eval = eval
        self.conditions = conditions
    }

    public func isValid(conditionsResults: [Bool]) -> Bool {
        if eval == "and" {
            return conditionsResults.andConditionIsTrue
        } else if eval == "or" {
            return conditionsResults.orConditionIsTrue
        }
        return false
    }
}

public struct ConditionModel {
    public let value: ValueUnion?
    public var fieldType: FieldTypes
    public var condition: String?
    public var fieldValue: ValueUnion?

    public init(
        fieldValue: ValueUnion? = nil,
        fieldType: FieldTypes,
        condition: String? = nil,
        value: ValueUnion? = nil
    ) {
        self.fieldValue = fieldValue
        self.fieldType = fieldType
        self.condition = condition
        self.value = value
    }
}

public struct ConditionalLogicModel {
    public let logic: LogicModel?
    public let itemCount: Int

    public init(logic: LogicModel?, isItemHidden: Bool?, itemCount: Int) {
        self.logic = logic
        self.itemCount = itemCount
    }
}
