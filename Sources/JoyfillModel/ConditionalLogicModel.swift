//
//  File.swift
//  
//

import Foundation
import JoyfillModel
import SwiftUI

/// Describes a single conditional logic block that can be attached to a page or field.
public struct LogicModel {
    /// Identifier used to reference the logic block.
    public var id: String?
    /// Action to perform when the logic evaluates to `true` (for example `"show"`/`"hide"`).
    public var action: String?
    /// Aggregation operator applied to `conditions` (`"and"` or `"or"`).
    public var eval: String?
    /// Individual conditions that participate in the evaluation.
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

    /// Evaluates the logic block using the supplied condition results.
    /// - Parameter conditionsResults: Boolean results for each condition in the same order as `conditions`.
    /// - Returns: `true` when the block passes for the configured operator.
    public func isValid(conditionsResults: [Bool]) -> Bool {
        if eval == "and" {
            return conditionsResults.andConditionIsTrue
        } else if eval == "or" {
            return conditionsResults.orConditionIsTrue
        }
        return false
    }
}

/// Represents a single condition within a logic block.
public struct ConditionModel {
    /// The comparison value used when evaluating the condition.
    public let value: ValueUnion?
    /// Field type that dictates how comparisons should be performed.
    public var fieldType: FieldTypes
    /// Operator used for evaluation (e.g. `"equals"`, `"gt"`).
    public var condition: String?
    /// Current value of the referenced field.
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

/// Wrapper that combines logic metadata with the item count being evaluated.
public struct ConditionalLogicModel {
    /// Logic definition being applied to the item.
    public let logic: LogicModel?
    /// Total number of items (pages/fields) participating in the logic evaluation.
    public let itemCount: Int

    public init(logic: LogicModel?, isItemHidden: Bool?, itemCount: Int) {
        self.logic = logic
        self.itemCount = itemCount
    }
}
