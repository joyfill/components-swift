//
//  WisdomTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 21/04/25.
//

import XCTest
import JoyfillFormulas
import JoyfillModel
import Joyfill
@testable import JoyfillExample

class WisdomTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        // Setup code if needed
    }
    
    override func tearDown() {
        // Teardown code if needed
        super.tearDown()
    }

    // MARK: - Basic Math Operations Tests
    
    func testBasicMathOperations() {
        let document = JoyDoc
            .addDocument()
            // Basic mathematical operators
            .addFormula(id: "add1", formula: "{num1} + {num2}")
            .addFormula(id: "subtract1", formula: "{num2} - {num1}")
            .addFormula(id: "multiply1", formula: "{num1} * {num2}")
            .addFormula(id: "divide1", formula: "{num2} / {num1}")
            
            // Operator precedence and parentheses
            .addFormula(id: "precedence1", formula: "{num1} + {num2} * 2")  // num1 + (num2 * 2)
            .addFormula(id: "precedence2", formula: "({num1} + {num2}) * 2") // (num1 + num2) * 2
            .addFormula(id: "complexExpression", formula: "({num1} + {num2}) * 3 - {num3} / 2")
            
            // Negative numbers
            .addFormula(id: "negative1", formula: "-{num1}")
            .addFormula(id: "negative2", formula: "{num2} * (-1)")
            .addFormula(id: "negativeResult", formula: "{num2} - {num1} * 3") // Can result in negative
            
            // Math functions
            .addFormula(id: "sum1", formula: "sum({num1}, {num2}, {num3})")
            .addFormula(id: "max1", formula: "max({num1}, {num2}, {num3})")
            .addFormula(id: "pow1", formula: "pow({num1}, 2)")  // Square of num1
            .addFormula(id: "sqrt1", formula: "sqrt({num3})")  // Square root of num3
            .addFormula(id: "mod1", formula: "mod({num3}, {num1})") // num3 % num1
            .addFormula(id: "round1", formula: "round({decimal})")
            .addFormula(id: "ceil1", formula: "ceil({decimal})")
            .addFormula(id: "floor1", formula: "floor({decimal})")
            
            // Field setup
            .addNumberField(identifier: "num1", value: 10, label: "Number 1")
            .addNumberField(identifier: "num2", value: 20, label: "Number 2")
            .addNumberField(identifier: "num3", value: 25, label: "Number 3")
            .addNumberField(identifier: "decimal", value: 7.65, label: "Decimal Number")
            
            // Basic operator results
            .addNumberField(identifier: "addResult", formulaRef: "add1", formulaKey: "value", label: "Addition Result")
            .addNumberField(identifier: "subtractResult", formulaRef: "subtract1", formulaKey: "value", label: "Subtraction Result")
            .addNumberField(identifier: "multiplyResult", formulaRef: "multiply1", formulaKey: "value", label: "Multiplication Result")
            .addNumberField(identifier: "divideResult", formulaRef: "divide1", formulaKey: "value", label: "Division Result")
            
            // Operator precedence results
            .addNumberField(identifier: "precedence1Result", formulaRef: "precedence1", formulaKey: "value", label: "Precedence Test 1")
            .addNumberField(identifier: "precedence2Result", formulaRef: "precedence2", formulaKey: "value", label: "Precedence Test 2")
            .addNumberField(identifier: "complexResult", formulaRef: "complexExpression", formulaKey: "value", label: "Complex Expression")
            
            // Negative number results
            .addNumberField(identifier: "negative1Result", formulaRef: "negative1", formulaKey: "value", label: "Negative Test 1")
            .addNumberField(identifier: "negative2Result", formulaRef: "negative2", formulaKey: "value", label: "Negative Test 2")
            .addNumberField(identifier: "negativeResultField", formulaRef: "negativeResult", formulaKey: "value", label: "Negative Result Test")
            
            // Math function results
            .addNumberField(identifier: "sumResult", formulaRef: "sum1", formulaKey: "value", label: "Sum Result")
            .addNumberField(identifier: "maxResult", formulaRef: "max1", formulaKey: "value", label: "Max Result")
            .addNumberField(identifier: "powResult", formulaRef: "pow1", formulaKey: "value", label: "Power Result")
            .addNumberField(identifier: "sqrtResult", formulaRef: "sqrt1", formulaKey: "value", label: "Sqrt Result")
            .addNumberField(identifier: "modResult", formulaRef: "mod1", formulaKey: "value", label: "Modulo Result")
            .addNumberField(identifier: "roundResult", formulaRef: "round1", formulaKey: "value", label: "Round Result")
            .addNumberField(identifier: "ceilResult", formulaRef: "ceil1", formulaKey: "value", label: "Ceiling Result")
            .addNumberField(identifier: "floorResult", formulaRef: "floor1", formulaKey: "value", label: "Floor Result")

        let documentEditor = DocumentEditor(document: document)
        
        // Test basic operators with initial values
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "addResult")?.number, 30)       // 10 + 20
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "subtractResult")?.number, 10)  // 20 - 10
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "multiplyResult")?.number, 200) // 10 * 20
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "divideResult")?.number, 2)     // 20 / 10
        
        // Test operator precedence and parentheses
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "precedence1Result")?.number, 50)      // 10 + (20 * 2)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "precedence2Result")?.number, 60)      // (10 + 20) * 2
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complexResult")?.number, 77.5)        // (10 + 20) * 3 - 25 / 2
        
        // Test negative numbers
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "negative1Result")?.number, -10)       // -10
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "negative2Result")?.number, -20)       // 20 * (-1)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "negativeResultField")?.number, -10)   // 20 - 10 * 3
        
        // Test math functions
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "sumResult")?.number, 55)        // 10 + 20 + 25
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "maxResult")?.number, 25)        // max(10, 20, 25)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "powResult")?.number, 100)       // 10^2
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "sqrtResult")?.number, 5)        // sqrt(25)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "modResult")?.number, 5)         // 25 % 10
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "roundResult")?.number, 8)       // round(7.65)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "ceilResult")?.number, 8)        // ceil(7.65)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "floorResult")?.number, 7)       // floor(7.65)
        
        // Test updating a value and seeing the formula recalculate
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "num1"), updateValue: ValueUnion.int(5)))
        
        // Check updated formula results after changing num1 to 5
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "addResult")?.number, 25)        // 5 + 20
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "subtractResult")?.number, 15)   // 20 - 5
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "multiplyResult")?.number, 100)  // 5 * 20
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "divideResult")?.number, 4)      // 20 / 5
        
        // Check updated precedence and complex expressions
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "precedence1Result")?.number, 45)      // 5 + (20 * 2)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "precedence2Result")?.number, 50)      // (5 + 20) * 2
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complexResult")?.number, 62.5)        // (5 + 20) * 3 - 25 / 2
        
        // Check updated negative numbers
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "negative1Result")?.number, -5)        // -5
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "negativeResultField")?.number, 5)     // 20 - 5 * 3
        
        // Check updated math functions
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "sumResult")?.number, 50)        // 5 + 20 + 25
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "maxResult")?.number, 25)        // max(5, 20, 25)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "powResult")?.number, 25)        // 5^2
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "modResult")?.number, 0)         // 25 % 5

        // Test updating a value and seeing the formula recalculate
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "num2"), updateValue: ValueUnion.int(25)))
        
        // Check updated formula results after changing num2 to 25
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "addResult")?.number, 30)        // 5 + 25
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "subtractResult")?.number, 20)   // 25 - 5
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "multiplyResult")?.number, 125)  // 5 * 25
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "divideResult")?.number, 5)      // 25 / 5
        
        // Update decimal value and test rounding functions
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "decimal"), updateValue: ValueUnion.double(3.25)))
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "roundResult")?.number, 3)       // round(3.25)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "ceilResult")?.number, 4)        // ceil(3.25)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "floorResult")?.number, 3)       // floor(3.25)
    }
}

extension DocumentEditor {
    func identifierModel(for identifier: String) -> FieldIdentifier {
        let field = self.field(for: identifier)
        return FieldIdentifier(fieldID: field!.id!, pageID: "", fileID: field!.file)
    }

    func value(ofFieldWithIdentifier identifier: String) -> ValueUnion? {
        self.field(for: identifier)?.value
    }
}


//XCTAssertEqual failed: ("Optional(JoyfillModel.ValueUnion.int(30))") is not equal to ("Optional(JoyfillModel.ValueUnion.int(30))")
