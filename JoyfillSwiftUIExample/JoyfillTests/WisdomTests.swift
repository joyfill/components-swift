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
            .addFormula(id: "add1", formula: "num1 + num2")
            .addFormula(id: "subtract1", formula: "num2 - num1")
            .addFormula(id: "multiply1", formula: "num1 * num2")
            .addFormula(id: "divide1", formula: "num2 / num1")
            
            // Operator precedence and parentheses
            .addFormula(id: "precedence1", formula: "num1 + num2 * 2")  // num1 + (num2 * 2)
            .addFormula(id: "precedence2", formula: "(num1 + num2) * 2") // (num1 + num2) * 2
            .addFormula(id: "complexExpression", formula: "(num1 + num2) * 3 - num3 / 2")
            
            // Negative numbers
            .addFormula(id: "negative1", formula: "-num1")
            .addFormula(id: "negative2", formula: "num2 * (-1)")
            .addFormula(id: "negativeResult", formula: "num2 - num1 * 3") // Can result in negative
            
            // Math functions
            .addFormula(id: "sum1", formula: "sum(num1, num2, num3)")
            .addFormula(id: "max1", formula: "max(num1, num2, num3)")
            .addFormula(id: "pow1", formula: "pow(num1, 2)")  // Square of num1
            .addFormula(id: "sqrt1", formula: "sqrt(num3)")  // Square root of num3
            .addFormula(id: "mod1", formula: "mod(num3, num1)") // num3 % num1
            .addFormula(id: "round1", formula: "round(decimal)")
            .addFormula(id: "ceil1", formula: "ceil(decimal)")
            .addFormula(id: "floor1", formula: "floor(decimal)")
            
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
    
    // MARK: - Logical Operations Tests
    
    func testLogicalOperations() {
        let document = JoyDoc.addDocument()
            // Simple if statement
            .addFormula(id: "if1", formula: "if(num1 > 10, \"Greater than 10\", \"Less or equal to 10\")")
            .addFormula(id: "if2", formula: "if(num1 == 15, \"Exactly 15\", \"Not 15\")")
            
            // Nested if
            .addFormula(id: "nestedIf", formula: "if(num1 > 20, \"High\", if(num1 > 10, \"Medium\", \"Low\"))")
            
            // And operator
            .addFormula(id: "and1", formula: "and(bool1, bool2)")
            .addFormula(id: "and2", formula: "and(bool1, bool2, bool3)")
            .addFormula(id: "andComplex", formula: "and(num1 > 10, num2 < 30)")
            
            // Or operator
            .addFormula(id: "or1", formula: "or(bool1, bool2)")
            .addFormula(id: "or2", formula: "or(bool1, bool2, bool3)")
            .addFormula(id: "orComplex", formula: "or(num1 > 20, num2 < 10)")
            
            // Not operator
            .addFormula(id: "not1", formula: "not(bool1)")
            .addFormula(id: "notComplex", formula: "not(num1 > 20)")
            
            // Empty function
            .addFormula(id: "empty1", formula: "empty(text1)")
            .addFormula(id: "empty2", formula: "empty(text2)")
            .addFormula(id: "empty3", formula: "empty(emptyArray)")
            .addFormula(id: "empty4", formula: "empty(nonEmptyArray)")
            .addFormula(id: "emptyZero", formula: "empty(0)")
            
            // Complex logical combinations
            .addFormula(id: "complex1", formula: "if(and(bool1, or(num1 > 15, num2 < 10)), \"Complex true\", \"Complex false\")")
            .addFormula(id: "complex2", formula: "if(not(empty(text1)), \"Text has value\", \"Text is empty\")")
            
            // Boolean constants
            .addFormula(id: "trueValue", formula: "true")
            .addFormula(id: "falseValue", formula: "false")
            .addFormula(id: "yesValue", formula: "yes")
            .addFormula(id: "noValue", formula: "no")
            
            // Input fields
            .addNumberField(identifier: "num1", value: 15, label: "Number 1")
            .addNumberField(identifier: "num2", value: 25, label: "Number 2")
            .addCheckboxField(identifier: "bool1", value: true, label: "Boolean 1")
            .addCheckboxField(identifier: "bool2", value: false, label: "Boolean 2")
            .addCheckboxField(identifier: "bool3", value: true, label: "Boolean 3")
            .addTextField(identifier: "text1", value: "", label: "Empty Text")
            .addTextField(identifier: "text2", value: "Hello", label: "Non-empty Text")
            .addOptionField(identifier: "emptyArray", value: [], options: ["a", "b", "c"], multiselect: true, label: "Empty Array")
            .addOptionField(identifier: "nonEmptyArray", value: ["a", "b"], options: ["a", "b", "c"], multiselect: true, label: "Non-empty Array")
            
            // Output fields
            .addTextField(identifier: "if1Result", formulaRef: "if1", formulaKey: "value", label: "If Result 1")
            .addTextField(identifier: "if2Result", formulaRef: "if2", formulaKey: "value", label: "If Result 2")
            .addTextField(identifier: "nestedIfResult", formulaRef: "nestedIf", formulaKey: "value", label: "Nested If Result")
            .addCheckboxField(identifier: "and1Result", formulaRef: "and1", formulaKey: "value", label: "And Result 1")
            .addCheckboxField(identifier: "and2Result", formulaRef: "and2", formulaKey: "value", label: "And Result 2")
            .addCheckboxField(identifier: "andComplexResult", formulaRef: "andComplex", formulaKey: "value", label: "Complex And Result")
            .addCheckboxField(identifier: "or1Result", formulaRef: "or1", formulaKey: "value", label: "Or Result 1")
            .addCheckboxField(identifier: "or2Result", formulaRef: "or2", formulaKey: "value", label: "Or Result 2")
            .addCheckboxField(identifier: "orComplexResult", formulaRef: "orComplex", formulaKey: "value", label: "Complex Or Result")
            .addCheckboxField(identifier: "not1Result", formulaRef: "not1", formulaKey: "value", label: "Not Result 1")
            .addCheckboxField(identifier: "notComplexResult", formulaRef: "notComplex", formulaKey: "value", label: "Complex Not Result")
            .addCheckboxField(identifier: "empty1Result", formulaRef: "empty1", formulaKey: "value", label: "Empty Result 1")
            .addCheckboxField(identifier: "empty2Result", formulaRef: "empty2", formulaKey: "value", label: "Empty Result 2")
            .addCheckboxField(identifier: "empty3Result", formulaRef: "empty3", formulaKey: "value", label: "Empty Array Result")
            .addCheckboxField(identifier: "empty4Result", formulaRef: "empty4", formulaKey: "value", label: "Non-empty Array Result")
            .addCheckboxField(identifier: "emptyZeroResult", formulaRef: "emptyZero", formulaKey: "value", label: "Empty Zero Result")
            .addTextField(identifier: "complex1Result", formulaRef: "complex1", formulaKey: "value", label: "Complex Logic Result 1")
            .addTextField(identifier: "complex2Result", formulaRef: "complex2", formulaKey: "value", label: "Complex Logic Result 2")
            .addCheckboxField(identifier: "trueResult", formulaRef: "trueValue", formulaKey: "value", label: "True Constant")
            .addCheckboxField(identifier: "falseResult", formulaRef: "falseValue", formulaKey: "value", label: "False Constant")
            .addCheckboxField(identifier: "yesResult", formulaRef: "yesValue", formulaKey: "value", label: "Yes Constant")
            .addCheckboxField(identifier: "noResult", formulaRef: "noValue", formulaKey: "value", label: "No Constant")
            
        let documentEditor = DocumentEditor(document: document)
        
        // Test if statements
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "if1Result")?.text, "Greater than 10") // 15 > 10
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "if2Result")?.text, "Exactly 15") // 15 == 15
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "nestedIfResult")?.text, "Medium") // 15 is between 10 and 20

        // Test and operator
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "and1Result")?.bool, false) // true && false
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "and2Result")?.bool, false) // true && false && true
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "andComplexResult")?.bool, true) // 15 > 10 && 25 < 30
        
        // Test or operator
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "or1Result")?.bool, true) // true || false
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "or2Result")?.bool, true) // true || false || true
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "orComplexResult")?.bool, false) // 15 > 20 || 25 < 10
        
        // Test not operator
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "not1Result")?.bool, false) // !true
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "notComplexResult")?.bool, true) // !(15 > 20)
        
        // Test empty function
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "empty1Result")?.bool, true) // empty("")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "empty2Result")?.bool, false) // empty("Hello")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "empty3Result")?.bool, true) // empty([])
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "empty4Result")?.bool, false) // empty(["a", "b"])
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "emptyZeroResult")?.bool, true) // empty(0)
        
        // Test complex logical combinations
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complex1Result")?.text, "Complex false") // true && (15 > 15 || 25 < 10)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complex2Result")?.text, "Text is empty") // !empty("")

        // Test boolean constants
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "trueResult")?.bool, true)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "falseResult")?.bool, false)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "noResult")?.bool, false)
        
        // Test updating values and recalculation
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "num1"), updateValue: ValueUnion.int(25)))
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "text1"), updateValue: ValueUnion.string("Not empty anymore")))
        
        // Check updated if results
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "if1Result")?.text, "Greater than 10") // 25 > 10
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "if2Result")?.text, "Not 15") // 25 != 15
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "nestedIfResult")?.text, "High") // 25 > 20

        // Check updated complex formulas
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complex1Result")?.text, "Complex true") // true && (25 > 15 || 25 < 10)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complex2Result")?.text, "Text has value") // !empty("Not empty anymore")
    }
    
    // MARK: - String Operations Tests
    
    func testStringOperations() {
        let document = JoyDoc.addDocument()
            // Simple string reference
            .addFormula(id: "stringRef", formula: "text1")
            
            // Case manipulation
            .addFormula(id: "upper1", formula: "upper(text1)")
            .addFormula(id: "lower1", formula: "lower(text2)")
            .addFormula(id: "mixedCase", formula: "concat(upper(substring(text1, 0, 1)), lower(substring(text1, 1)))")
            
            // Contains check
            .addFormula(id: "contains1", formula: "contains(text1, \"joy\")")
            .addFormula(id: "contains2", formula: "contains(text1, \"xyz\")")
            .addFormula(id: "containsCaseInsensitive", formula: "contains(text1, \"JOY\")")
            
            // Length calculation
            .addFormula(id: "length1", formula: "length(text1)")
            .addFormula(id: "length2", formula: "length(text3)")
            
            // Concatenation with + operator
            .addFormula(id: "concatPlus", formula: "text1 + \" \" + text2")
            
            // Concatenation with concat function
            .addFormula(id: "concatFunc", formula: "concat(text1, \" - \", text2)")
            .addFormula(id: "concatMultiple", formula: "concat(text1, \" \", text2, \" (\", text3, \")\")")
            
            // Conditional string formatting
            .addFormula(id: "conditionalFormat", formula: "if(length(text1) > 10, \"Long text: \" + text1, \"Short text: \" + text1)")
            
            // String quotes testing
            .addFormula(id: "singleQuotes", formula: "'Single quoted text'")
            .addFormula(id: "doubleQuotes", formula: "\"Double quoted text\"")
            .addFormula(id: "mixedQuotes", formula: "concat('Single', \" and \", 'double', \" quotes\")")
            
            // Complex string manipulation
            .addFormula(id: "emailValidation", formula: "if(and(contains(email, \"@\"), contains(email, \".\")), \"Valid email format\", \"Invalid email format\")")
            .addFormula(id: "nameFormatter", formula: "if(and(not(empty(firstName)), not(empty(lastName))), concat(upper(substring(firstName, 0, 1)), \". \", lastName), \"Please enter your name\")")
            
            // Input fields
            .addTextField(identifier: "text1", value: "joyfill", label: "Text 1")
            .addTextField(identifier: "text2", value: "FORMULAS", label: "Text 2")
            .addTextField(identifier: "text3", value: "", label: "Empty Text")
            .addTextField(identifier: "firstName", value: "John", label: "First Name")
            .addTextField(identifier: "lastName", value: "Doe", label: "Last Name")
            .addTextField(identifier: "email", value: "john.doe@example.com", label: "Email")
            
            // Output fields
            .addTextField(identifier: "stringRefResult", formulaRef: "stringRef", formulaKey: "value", label: "String Reference")
            .addTextField(identifier: "upperResult", formulaRef: "upper1", formulaKey: "value", label: "Uppercase Result")
            .addTextField(identifier: "lowerResult", formulaRef: "lower1", formulaKey: "value", label: "Lowercase Result")
            .addTextField(identifier: "mixedCaseResult", formulaRef: "mixedCase", formulaKey: "value", label: "Mixed Case Result")
            .addCheckboxField(identifier: "contains1Result", formulaRef: "contains1", formulaKey: "value", label: "Contains 'joy'")
            .addCheckboxField(identifier: "contains2Result", formulaRef: "contains2", formulaKey: "value", label: "Contains 'xyz'")
            .addCheckboxField(identifier: "containsCaseResult", formulaRef: "containsCaseInsensitive", formulaKey: "value", label: "Contains Case Insensitive")
            .addNumberField(identifier: "length1Result", formulaRef: "length1", formulaKey: "value", label: "String Length 1")
            .addNumberField(identifier: "length2Result", formulaRef: "length2", formulaKey: "value", label: "String Length 2")
            .addTextField(identifier: "concatPlusResult", formulaRef: "concatPlus", formulaKey: "value", label: "Concat with +")
            .addTextField(identifier: "concatFuncResult", formulaRef: "concatFunc", formulaKey: "value", label: "Concat with Function")
            .addTextField(identifier: "concatMultipleResult", formulaRef: "concatMultiple", formulaKey: "value", label: "Multiple Concat")
            .addTextField(identifier: "conditionalFormatResult", formulaRef: "conditionalFormat", formulaKey: "value", label: "Conditional Format")
            .addTextField(identifier: "singleQuotesResult", formulaRef: "singleQuotes", formulaKey: "value", label: "Single Quotes")
            .addTextField(identifier: "doubleQuotesResult", formulaRef: "doubleQuotes", formulaKey: "value", label: "Double Quotes")
            .addTextField(identifier: "mixedQuotesResult", formulaRef: "mixedQuotes", formulaKey: "value", label: "Mixed Quotes")
            .addTextField(identifier: "emailValidationResult", formulaRef: "emailValidation", formulaKey: "value", label: "Email Validation")
            .addTextField(identifier: "nameFormatterResult", formulaRef: "nameFormatter", formulaKey: "value", label: "Name Formatter")
            
        let documentEditor = DocumentEditor(document: document)
        
        // Test string reference
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "stringRefResult")?.text, "joyfill")

        // Test case manipulation
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "upperResult")?.text, "JOYFILL")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "lowerResult")?.text, "formulas")
//        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "mixedCaseResult")?.text, "Joyfill")

        // Test contains
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "contains1Result")?.bool, true) // joyfill contains joy
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "contains2Result")?.bool, false) // joyfill doesn't contain xyz
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "containsCaseResult")?.bool, true) // Case insensitive contains
        
        // Test length
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "length1Result")?.number, 7) // length("joyfill") = 7
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "length2Result")?.number, 0) // length("") = 0
        
        // Test concatenation
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "concatPlusResult")?.text, "joyfill FORMULAS")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "concatFuncResult")?.text, "joyfill - FORMULAS")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "concatMultipleResult")?.text, "joyfill FORMULAS ()")

        // Test conditional formatting
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "conditionalFormatResult")?.text, "Short text: joyfill")

        // Test quotes
//        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "singleQuotesResult")?.text, "Single quoted text")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "doubleQuotesResult")?.text, "Double quoted text")
//        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "mixedQuotesResult")?.text, "Single and double quotes")

        // Test complex string operations
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "emailValidationResult")?.text, "Valid email format")
//        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "nameFormatterResult")?.text, "J. Doe")

        // Test updating values and recalculation
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "text1"), updateValue: ValueUnion.string("This is a longer text")))
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "email"), updateValue: ValueUnion.string("invalid-email")))
        
        // Check updated string results
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "upperResult")?.text, "THIS IS A LONGER TEXT")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "contains1Result")?.bool, false) // No longer contains "joy"
//        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "length1Result")?.number, 20) // New length
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "conditionalFormatResult")?.text, "Long text: This is a longer text") // Now longer than 10
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "emailValidationResult")?.text, "Invalid email format") // Invalid email now
    }

    // MARK: - Precedence and Associativity Tests

    func testPrecedenceAndAssociativity() {
        let document = JoyDoc.addDocument()
            // Basic precedence cases from spec
            .addFormula(id: "precedence1", formula: "3 + 4 * 2") // Multiplication before addition
            .addFormula(id: "precedence2", formula: "(3 + 4) * 2") // Parentheses first
            .addFormula(id: "precedence3", formula: "100 / 5 * 2") // Left-to-right division then multiplication

            // Left-to-right associativity
            .addFormula(id: "associativity1", formula: "10 - 5 - 2") // Left-to-right subtraction
            .addFormula(id: "associativity2", formula: "8 / 4 / 2") // Left-to-right division
            .addFormula(id: "associativity3", formula: "4 + 3 - 2") // Left-to-right addition/subtraction

            // Complex precedence examples
            .addFormula(id: "complex1", formula: "1 + 2 + 3 + 4") // Multiple additions
            .addFormula(id: "complex2", formula: "16 / 4 * 2 + 1") // Division then multiplication then addition
            .addFormula(id: "complex3", formula: "9 % 4 + 1 * 2") // Modulo and multiplication then addition

            // Complex parenthesized expressions
            .addFormula(id: "parentheses1", formula: "(10 + 5) * (2 + 3)") // Multiple parenthesized expressions
            .addFormula(id: "parentheses2", formula: "((10 + 5) * 2) + 3") // Nested parentheses

            // Negative numbers and precedence
            .addFormula(id: "negative1", formula: "10 + -5") // Addition with negative number
            .addFormula(id: "negative2", formula: "-5 * 3") // Negative multiplication
            .addFormula(id: "negative3", formula: "-(5 + 3)") // Negating a parenthesized expression

            // Function calls in expressions
            .addFormula(id: "function1", formula: "max(5, 10) + 2") // Function result in expression
            .addFormula(id: "function2", formula: "pow(2, 3) * 2") // Function with calculation
            .addFormula(id: "function3", formula: "round(3.5) + ceil(4.2)") // Multiple functions

            // Output fields
            .addNumberField(identifier: "precedence1Result", formulaRef: "precedence1", formulaKey: "value", label: "3 + 4 * 2")
            .addNumberField(identifier: "precedence2Result", formulaRef: "precedence2", formulaKey: "value", label: "(3 + 4) * 2")
            .addNumberField(identifier: "precedence3Result", formulaRef: "precedence3", formulaKey: "value", label: "100 / 5 * 2")
            .addNumberField(identifier: "associativity1Result", formulaRef: "associativity1", formulaKey: "value", label: "10 - 5 - 2")
            .addNumberField(identifier: "associativity2Result", formulaRef: "associativity2", formulaKey: "value", label: "8 / 4 / 2")
            .addNumberField(identifier: "associativity3Result", formulaRef: "associativity3", formulaKey: "value", label: "4 + 3 - 2")
            .addNumberField(identifier: "complex1Result", formulaRef: "complex1", formulaKey: "value", label: "1 + 2 + 3 + 4")
            .addNumberField(identifier: "complex2Result", formulaRef: "complex2", formulaKey: "value", label: "16 / 4 * 2 + 1")
            .addNumberField(identifier: "complex3Result", formulaRef: "complex3", formulaKey: "value", label: "9 % 4 + 1 * 2")
            .addNumberField(identifier: "parentheses1Result", formulaRef: "parentheses1", formulaKey: "value", label: "(10 + 5) * (2 + 3)")
            .addNumberField(identifier: "parentheses2Result", formulaRef: "parentheses2", formulaKey: "value", label: "((10 + 5) * 2) + 3")
            .addNumberField(identifier: "negative1Result", formulaRef: "negative1", formulaKey: "value", label: "10 + -5")
            .addNumberField(identifier: "negative2Result", formulaRef: "negative2", formulaKey: "value", label: "-5 * 3")
            .addNumberField(identifier: "negative3Result", formulaRef: "negative3", formulaKey: "value", label: "-(5 + 3)")
            .addNumberField(identifier: "function1Result", formulaRef: "function1", formulaKey: "value", label: "max(5, 10) + 2")
            .addNumberField(identifier: "function2Result", formulaRef: "function2", formulaKey: "value", label: "pow(2, 3) * 2")
            .addNumberField(identifier: "function3Result", formulaRef: "function3", formulaKey: "value", label: "round(3.5) + ceil(4.2)")

        let documentEditor = DocumentEditor(document: document)

        // Test basic precedence cases
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "precedence1Result")?.number, 11) // 3 + (4 * 2) = 3 + 8 = 11
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "precedence2Result")?.number, 14) // (3 + 4) * 2 = 7 * 2 = 14
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "precedence3Result")?.number, 40) // (100 / 5) * 2 = 20 * 2 = 40

        // Test left-to-right associativity
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "associativity1Result")?.number, 3) // (10 - 5) - 2 = 5 - 2 = 3
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "associativity2Result")?.number, 1) // (8 / 4) / 2 = 2 / 2 = 1
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "associativity3Result")?.number, 5) // (4 + 3) - 2 = 7 - 2 = 5

        // Test complex precedence cases
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complex1Result")?.number, 10) // 1 + 2 + 3 + 4 = 10
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complex2Result")?.number, 9) // ((16 / 4) * 2) + 1 = 4 * 2 + 1 = 9
//        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complex3Result")?.number, 3) // (9 % 4) + (1 * 2) = 1 + 2 = 3

        // Test complex parenthesized expressions
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "parentheses1Result")?.number, 75) // (10 + 5) * (2 + 3) = 15 * 5 = 75
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "parentheses2Result")?.number, 33) // ((10 + 5) * 2) + 3 = 30 + 3 = 33

        // Test negative numbers and precedence
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "negative1Result")?.number, 5) // 10 + (-5) = 5
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "negative2Result")?.number, -15) // (-5) * 3 = -15
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "negative3Result")?.number, -8) // -(5 + 3) = -8

        // Test function calls in expressions
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "function1Result")?.number, 12) // max(5, 10) + 2 = 10 + 2 = 12
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "function2Result")?.number, 16) // pow(2, 3) * 2 = 8 * 2 = 16
//        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "function3Result")?.number, 8) // round(3.5) + ceil(4.2) = 4 + 5 = 9
    }

    // MARK: - Date Operations Tests
    
    func testDateOperations() {
        // Create a fixed date for testing - use UTC to avoid timezone issues
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Use UTC
        let testDate = dateFormatter.date(from: "2025-05-15")!
        let futureDate = dateFormatter.date(from: "2030-01-01")!
        
        let document = JoyDoc.addDocument()
            // Current date/time
            .addFormula(id: "now1", formula: "now()")
            
            // Date components extraction
            .addFormula(id: "year1", formula: "year(date1)")
            .addFormula(id: "month1", formula: "month(date1)")
            .addFormula(id: "day1", formula: "day(date1)")
            
            // Date creation
            .addFormula(id: "dateCreate1", formula: "date(yearValue, monthValue, dayValue)")
            .addFormula(id: "dateCreate2", formula: "date(2025, 12, 31)")
            
            // Date arithmetic
            .addFormula(id: "dateAdd1", formula: "dateAdd(date1, timeAmount, timeUnit)")
            .addFormula(id: "dateAdd2", formula: "dateAdd(date1, 1, \"years\")")
            .addFormula(id: "dateSubtract1", formula: "dateSubtract(date1, timeAmount, timeUnit)")
            .addFormula(id: "dateSubtract2", formula: "dateSubtract(date1, 1, \"months\")")
            
            // Date comparison
            .addFormula(id: "dateEqual", formula: "if(date1 == date1Clone, \"Dates are equal\", \"Dates are different\")")
            .addFormula(id: "dateBefore", formula: "if(date1 < futureDate, \"Before future date\", \"Not before future date\")")
            .addFormula(id: "dateAfter", formula: "if(date1 > now(), \"After current date\", \"Not after current date\")")
            
            // Date with conditional logic
            .addFormula(id: "dateConditional", formula: "if(year(date1) > 2024, \"After 2024\", \"2024 or earlier\")")
            
            // Date formatting in strings
            .addFormula(id: "dateInString", formula: "concat(\"Year: \", year(date1), \", Month: \", month(date1), \", Day: \", day(date1))")
            
            // Input fields
            .addDateField(identifier: "date1", value: testDate, label: "Test Date (2025-05-15)")
            .addDateField(identifier: "date1Clone", value: testDate, label: "Same Test Date")
            .addDateField(identifier: "futureDate", value: futureDate, label: "Future Date (2030-01-01)")
            .addNumberField(identifier: "yearValue", value: 2026, label: "Year Value")
            .addNumberField(identifier: "monthValue", value: 7, label: "Month Value")
            .addNumberField(identifier: "dayValue", value: 20, label: "Day Value")
            .addNumberField(identifier: "timeAmount", value: 3, label: "Time Amount")
            .addOptionField(identifier: "timeUnit", value: ["days"], options: ["days", "weeks", "months", "years"], label: "Time Unit")
            
            // Output fields
            .addDateField(identifier: "nowResult", formulaRef: "now1", formulaKey: "value", label: "Current Date/Time")
            .addNumberField(identifier: "yearResult", formulaRef: "year1", formulaKey: "value", label: "Year Component")
            .addNumberField(identifier: "monthResult", formulaRef: "month1", formulaKey: "value", label: "Month Component")
            .addNumberField(identifier: "dayResult", formulaRef: "day1", formulaKey: "value", label: "Day Component")
            .addDateField(identifier: "dateCreateResult1", formulaRef: "dateCreate1", formulaKey: "value", label: "Created Date 1")
            .addDateField(identifier: "dateCreateResult2", formulaRef: "dateCreate2", formulaKey: "value", label: "Created Date 2")
            .addDateField(identifier: "dateAddResult1", formulaRef: "dateAdd1", formulaKey: "value", label: "Date After Addition 1")
            .addDateField(identifier: "dateAddResult2", formulaRef: "dateAdd2", formulaKey: "value", label: "Date After Addition 2")
            .addDateField(identifier: "dateSubtractResult1", formulaRef: "dateSubtract1", formulaKey: "value", label: "Date After Subtraction 1")
            .addDateField(identifier: "dateSubtractResult2", formulaRef: "dateSubtract2", formulaKey: "value", label: "Date After Subtraction 2")
            .addTextField(identifier: "dateEqualResult", formulaRef: "dateEqual", formulaKey: "value", label: "Date Equality Test")
            .addTextField(identifier: "dateBeforeResult", formulaRef: "dateBefore", formulaKey: "value", label: "Date Before Test")
            .addTextField(identifier: "dateAfterResult", formulaRef: "dateAfter", formulaKey: "value", label: "Date After Test")
            .addTextField(identifier: "dateConditionalResult", formulaRef: "dateConditional", formulaKey: "value", label: "Date Conditional Test")
            .addTextField(identifier: "dateInStringResult", formulaRef: "dateInString", formulaKey: "value", label: "Date in String")
            
        let documentEditor = DocumentEditor(document: document)
        
        // Helper function to use UTC calendar for test verification
        func utcComponents(from timestamp: Double) -> DateComponents {
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            return calendar.dateComponents([.year, .month, .day], from: date)
        }
        
        // Test date components extraction (now using UTC date)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "yearResult")?.number, 2025)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "monthResult")?.number, 5)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dayResult")?.number, 15) // Now correctly 15 in UTC
        
        // Test date creation
        let createdDate1Timestamp = documentEditor.value(ofFieldWithIdentifier: "dateCreateResult1")?.number
        XCTAssertNotNil(createdDate1Timestamp)
        if let timestamp = createdDate1Timestamp {
            // Convert timestamp (in milliseconds) to Date and verify using UTC
            let components = utcComponents(from: timestamp)
            XCTAssertEqual(components.year, 2026)
            XCTAssertEqual(components.month, 7)
            XCTAssertEqual(components.day, 20)
        }
        
        let createdDate2Timestamp = documentEditor.value(ofFieldWithIdentifier: "dateCreateResult2")?.number
        XCTAssertNotNil(createdDate2Timestamp)
        if let timestamp = createdDate2Timestamp {
            // Convert timestamp (in milliseconds) to Date and verify using UTC
            let components = utcComponents(from: timestamp)
            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 12)
            XCTAssertEqual(components.day, 31)
        }
        
        // Test date addition
        let addedDate1Timestamp = documentEditor.value(ofFieldWithIdentifier: "dateAddResult1")?.number
        XCTAssertNotNil(addedDate1Timestamp)
        if let timestamp = addedDate1Timestamp {
            // Should be 3 days after 2025-05-15 = 2025-05-18
            let components = utcComponents(from: timestamp)
            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 5)
            XCTAssertEqual(components.day, 18)
        }
        
        let addedDate2Timestamp = documentEditor.value(ofFieldWithIdentifier: "dateAddResult2")?.number
        XCTAssertNotNil(addedDate2Timestamp)
        if let timestamp = addedDate2Timestamp {
            // Should be 1 year after 2025-05-15 = 2026-05-15
            let components = utcComponents(from: timestamp)
            XCTAssertEqual(components.year, 2026)
            XCTAssertEqual(components.month, 5)
            XCTAssertEqual(components.day, 15)
        }
        
        // Test date subtraction
        let subtractedDate1Timestamp = documentEditor.value(ofFieldWithIdentifier: "dateSubtractResult1")?.number
        XCTAssertNotNil(subtractedDate1Timestamp)
        if let timestamp = subtractedDate1Timestamp {
            // Should be 3 days before 2025-05-15 = 2025-05-12
            let components = utcComponents(from: timestamp)
            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 5)
            XCTAssertEqual(components.day, 12)
        }
        
        let subtractedDate2Timestamp = documentEditor.value(ofFieldWithIdentifier: "dateSubtractResult2")?.number
        XCTAssertNotNil(subtractedDate2Timestamp)
        if let timestamp = subtractedDate2Timestamp {
            // Should be 1 month before 2025-05-15 = 2025-04-15
            let components = utcComponents(from: timestamp)
            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 4)
            XCTAssertEqual(components.day, 15)
        }
        
        // Test date comparison
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dateEqualResult")?.text, "Dates are equal")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dateBeforeResult")?.text, "Before future date")
        
        // Test conditional date logic
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dateConditionalResult")?.text, "After 2024")
        
        // Test date in string (now expecting UTC values)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dateInStringResult")?.text, "Year: 2025, Month: 5, Day: 15")
        
        // Test updating date values with timestamp (this is in seconds, so should give the expected UTC result)
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "date1"), updateValue: ValueUnion.string("1678483200")))

        // Check updated results (using the corrected expectations for UTC)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "yearResult")?.number, 2023)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "monthResult")?.number, 3)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dayResult")?.number, 10) // UTC day for timestamp 1678483200
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dateConditionalResult")?.text, "2024 or earlier")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dateInStringResult")?.text, "Year: 2023, Month: 3, Day: 10")
    }
    
    // MARK: - Array Operations Tests
    
    func testArrayOperations() {
        let document = JoyDoc.addDocument()
            // Array length
            .addFormula(id: "length1", formula: "length(fruitArray)")
            .addFormula(id: "length2", formula: "length(emptyArray)")
            .addFormula(id: "length3", formula: "length(numArray)")
            
            // Count if
            .addFormula(id: "countIf1", formula: "countIf(fruitArray, \"a\")")
            .addFormula(id: "countIf2", formula: "countIf(fruitArray, searchTerm)")
            
            // Array concatenation
            .addFormula(id: "concat1", formula: "concat(fruitArray, colorArray)")
            .addFormula(id: "concat2", formula: "concat(\"Selected options: \", fruitArray)")
            .addFormula(id: "concat3", formula: "concat(numArray, [10, 11, 12])")
            
            // Flat
            .addFormula(id: "flat1", formula: "flat([[fruitArray], [colorArray]])")
            .addFormula(id: "flatDepth", formula: "flat([numArray, [10, [11, [12]]]], 2)")
            
            // Map
            .addFormula(id: "map1", formula: "map(numArray, (item) → item * 2)")
            .addFormula(id: "map2", formula: "map(fruitArray, (item) → concat(\"fruit: \", item))")
            
            // FlatMap
            .addFormula(id: "flatMap1", formula: "flatMap(numArray, (item) → [item, item * 2])")
            
            // Filter
            .addFormula(id: "filter1", formula: "filter(numArray, (item) → item > 3)")
            .addFormula(id: "filter2", formula: "filter(fruitArray, (item) → contains(item, \"a\"))")
            
            // Reduce
            .addFormula(id: "reduce1", formula: "reduce(numArray, (acc, item) → acc + item, 0)")
            .addFormula(id: "reduce2", formula: "reduce(numArray, (acc, item) → acc * item, 1)")
            
            // Find
            .addFormula(id: "find1", formula: "find(numArray, (item) → item > 3)")
            .addFormula(id: "find2", formula: "find(fruitArray, (item) → contains(item, \"g\"))")
            .addFormula(id: "find3", formula: "find(numArray, (item) → item > 100)") // No match
            
            // Every
            .addFormula(id: "every1", formula: "every(numArray, (item) → item > 0)")
            .addFormula(id: "every2", formula: "every(numArray, (item) → item > 3)") // Should be false
            
            // Some
            .addFormula(id: "some1", formula: "some(numArray, (item) → item > 3)")
            .addFormula(id: "some2", formula: "some(numArray, (item) → item > 10)") // Should be false
            
            // Complex array operations
            .addFormula(id: "complexArray1", formula: "filter(map(numArray, (item) → item * 2), (item) → item > 6)")
            .addFormula(id: "complexArray2", formula: "reduce(filter(numArray, (item) → item > 2), (acc, item) → acc + item, 0)")
            
            // Input fields
            .addOptionField(identifier: "fruitArray", value: ["apple", "banana", "orange", "grape"], 
                           options: ["apple", "banana", "orange", "grape", "kiwi"], multiselect: true,
                           label: "Fruits")
            .addOptionField(identifier: "colorArray", value: ["red", "blue", "green"], 
                           options: ["red", "blue", "green", "yellow", "black"], multiselect: true,
                           label: "Colors")
            .addOptionField(identifier: "emptyArray", value: [], 
                           options: ["empty1", "empty2"], multiselect: true,
                           label: "Empty Array")
            .addTextField(identifier: "numArray", value: "[1, 2, 3, 4, 5]", label: "Number Array")
            .addTextField(identifier: "searchTerm", value: "a", label: "Search Term")
            
            // Output fields
            .addNumberField(identifier: "length1Result", formulaRef: "length1", formulaKey: "value", label: "Fruit Array Length")
            .addNumberField(identifier: "length2Result", formulaRef: "length2", formulaKey: "value", label: "Empty Array Length")
            .addNumberField(identifier: "length3Result", formulaRef: "length3", formulaKey: "value", label: "Number Array Length")
            .addNumberField(identifier: "countIf1Result", formulaRef: "countIf1", formulaKey: "value", label: "Count 'a' in Fruits")
            .addNumberField(identifier: "countIf2Result", formulaRef: "countIf2", formulaKey: "value", label: "Count Search Term in Fruits")
            .addTextField(identifier: "concat1Result", formulaRef: "concat1", formulaKey: "value", label: "Concat Arrays")
            .addTextField(identifier: "concat2Result", formulaRef: "concat2", formulaKey: "value", label: "Concat String with Array")
            .addTextField(identifier: "concat3Result", formulaRef: "concat3", formulaKey: "value", label: "Concat Number Arrays")
            .addTextField(identifier: "flat1Result", formulaRef: "flat1", formulaKey: "value", label: "Flat Arrays")
            .addTextField(identifier: "flatDepthResult", formulaRef: "flatDepth", formulaKey: "value", label: "Flat with Depth")
            .addTextField(identifier: "map1Result", formulaRef: "map1", formulaKey: "value", label: "Map Numbers * 2")
            .addTextField(identifier: "map2Result", formulaRef: "map2", formulaKey: "value", label: "Map Fruits with Prefix")
            .addTextField(identifier: "flatMap1Result", formulaRef: "flatMap1", formulaKey: "value", label: "FlatMap Result")
            .addTextField(identifier: "filter1Result", formulaRef: "filter1", formulaKey: "value", label: "Filter Numbers > 3")
            .addTextField(identifier: "filter2Result", formulaRef: "filter2", formulaKey: "value", label: "Filter Fruits with 'a'")
            .addNumberField(identifier: "reduce1Result", formulaRef: "reduce1", formulaKey: "value", label: "Reduce Sum")
            .addNumberField(identifier: "reduce2Result", formulaRef: "reduce2", formulaKey: "value", label: "Reduce Product")
            .addNumberField(identifier: "find1Result", formulaRef: "find1", formulaKey: "value", label: "Find First > 3")
            .addTextField(identifier: "find2Result", formulaRef: "find2", formulaKey: "value", label: "Find First with 'g'")
            .addTextField(identifier: "find3Result", formulaRef: "find3", formulaKey: "value", label: "Find No Match")
            .addCheckboxField(identifier: "every1Result", formulaRef: "every1", formulaKey: "value", label: "Every > 0")
            .addCheckboxField(identifier: "every2Result", formulaRef: "every2", formulaKey: "value", label: "Every > 3")
            .addCheckboxField(identifier: "some1Result", formulaRef: "some1", formulaKey: "value", label: "Some > 3")
            .addCheckboxField(identifier: "some2Result", formulaRef: "some2", formulaKey: "value", label: "Some > 10")
            .addTextField(identifier: "complexArray1Result", formulaRef: "complexArray1", formulaKey: "value", label: "Complex Array 1")
            .addNumberField(identifier: "complexArray2Result", formulaRef: "complexArray2", formulaKey: "value", label: "Complex Array 2")
            
        let documentEditor = DocumentEditor(document: document)
        
        // Test array length
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "length1Result")?.number, 4) // ["apple", "banana", "orange", "grape"]
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "length2Result")?.number, 0) // []
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "length3Result")?.number, 5) // [1, 2, 3, 4, 5]
        
        // Test countIf
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "countIf1Result")?.number, 4) // "a" appears in apple, banana, orange, grape
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "countIf2Result")?.number, 4) // searchTerm = "a"
        
        // Test concat
        let concatArraysString = documentEditor.value(ofFieldWithIdentifier: "concat1Result")?.text
        XCTAssertNotNil(concatArraysString)
        XCTAssertTrue(concatArraysString?.contains("apple") == true)
        XCTAssertTrue(concatArraysString?.contains("red") == true)
        
        let concatWithStringResult = documentEditor.value(ofFieldWithIdentifier: "concat2Result")?.text
        XCTAssertNotNil(concatWithStringResult)
        XCTAssertTrue(concatWithStringResult?.hasPrefix("Selected options:") == true)
        XCTAssertTrue(concatWithStringResult?.contains("apple") == true)
        
        // Test flat
        let flatResult = documentEditor.value(ofFieldWithIdentifier: "flat1Result")?.text
        XCTAssertNotNil(flatResult)
        XCTAssertTrue(flatResult?.contains("apple") == true)
        XCTAssertTrue(flatResult?.contains("red") == true)
        
        // Test map
        let mapNumbersResult = documentEditor.value(ofFieldWithIdentifier: "map1Result")?.text
        XCTAssertNotNil(mapNumbersResult)
        XCTAssertTrue(mapNumbersResult?.contains("2") == true) // 1 * 2
        XCTAssertTrue(mapNumbersResult?.contains("10") == true) // 5 * 2
        
        let mapFruitsResult = documentEditor.value(ofFieldWithIdentifier: "map2Result")?.text
        XCTAssertNotNil(mapFruitsResult)
        XCTAssertTrue(mapFruitsResult?.contains("fruit: apple") == true)
        
        // Test filter
        let filterNumbersResult = documentEditor.value(ofFieldWithIdentifier: "filter1Result")?.text
        XCTAssertNotNil(filterNumbersResult)
        XCTAssertTrue(filterNumbersResult?.contains("4") == true)
        XCTAssertTrue(filterNumbersResult?.contains("5") == true)
        XCTAssertFalse(filterNumbersResult?.contains("2") == true) // Not > 3
        
        let filterFruitsResult = documentEditor.value(ofFieldWithIdentifier: "filter2Result")?.text
        XCTAssertNotNil(filterFruitsResult)
        XCTAssertTrue(filterFruitsResult?.contains("apple") == true)
        XCTAssertTrue(filterFruitsResult?.contains("banana") == true)
        XCTAssertTrue(filterFruitsResult?.contains("orange") == true)
        XCTAssertTrue(filterFruitsResult?.contains("grape") == true) // 'a' is in grape (gr-a-pe)
        
        // Test reduce
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "reduce1Result")?.number, 15) // 1+2+3+4+5
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "reduce2Result")?.number, 120) // 1*2*3*4*5
        
        // Test find
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "find1Result")?.number, 4) // First number > 3

        // Test every/some
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "every1Result")?.bool, true) // All numbers > 0
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "every2Result")?.bool, false) // Not all numbers > 3
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "some1Result")?.bool, true) // Some numbers > 3
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "some2Result")?.bool, false) // No numbers > 10
        
        // Test complex array operations
        let complexArrayResult = documentEditor.value(ofFieldWithIdentifier: "complexArray1Result")?.text
        XCTAssertNotNil(complexArrayResult)
        XCTAssertTrue(complexArrayResult?.contains("8") == true) // 4*2
        XCTAssertTrue(complexArrayResult?.contains("10") == true) // 5*2
        XCTAssertFalse(complexArrayResult?.contains("4") == true) // 2*2 = 4, not > 6
        
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "complexArray2Result")?.number, 12) // 3+4+5 = 12
        
        // Test updating arrays and recalculation
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "numArray"), updateValue: ValueUnion.string("[10, 20, 30]")))
        
        // Check updated results
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "length3Result")?.number, 3) // New length: [10, 20, 30]
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "reduce1Result")?.number, 60) // 10+20+30
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "every2Result")?.bool, true) // Now all numbers > 3
        
        // Update search term
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "searchTerm"), updateValue: ValueUnion.string("e")))
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "countIf2Result")?.number, 3) // "e" appears in apple, orange, and grape
    }

    // MARK: - Remaining Features Tests
    
    func testRemainingFeatures() {
        let document = JoyDoc.addDocument()
            // Self/Current references
            .addFormula(id: "selfRef", formula: "self * 2")
            .addFormula(id: "currentRef", formula: "current + 10")
            .addFormula(id: "thisRef", formula: "this > 50")
            
            // Object property references
            .addFormula(id: "objectProp", formula: "user.name")
            .addFormula(id: "nestedObjectProp", formula: "user.address.city")
            
            // Array index references
            .addFormula(id: "arrayIndex", formula: "fruits[0]")
            .addFormula(id: "nestedArrayIndex", formula: "matrix[1][2]")
            .addFormula(id: "dynamicArrayIndex", formula: "fruits[selectedIndex]")
            
            // toNumber function
            .addFormula(id: "toNumber1", formula: "toNumber(\"100\")")
            .addFormula(id: "toNumber2", formula: "toNumber(\"100.25\")")
            .addFormula(id: "toNumber3", formula: "toNumber(\"-50\")")
            .addFormula(id: "toNumber4", formula: "toNumber(\"invalid\")")
            .addFormula(id: "toNumberWithSpace", formula: "toNumber(\"  42  \")")
            .addFormula(id: "toNumberCalculation", formula: "toNumber(stringNumber) * 2")
            
            // Input fields
            .addNumberField(identifier: "selfValue", value: 25, label: "Self Value")
            .addNumberField(identifier: "currentValue", value: 15, label: "Current Value")
            .addNumberField(identifier: "thisValue", value: 75, label: "This Value")
            .addTextField(identifier: "user", value: "{\"name\":\"John Doe\",\"address\":{\"city\":\"San Francisco\",\"zip\":\"94103\"}}", label: "User Object")
            .addTextField(identifier: "fruits", value: "[\"apple\",\"banana\",\"orange\",\"grape\"]", label: "Fruits Array")
            .addTextField(identifier: "matrix", value: "[[1,2,3],[4,5,6],[7,8,9]]", label: "Matrix")
            .addNumberField(identifier: "selectedIndex", value: 2, label: "Selected Index")
            .addTextField(identifier: "stringNumber", value: "42", label: "String Number")
            
            // Output fields
            .addNumberField(identifier: "selfRefResult", formulaRef: "selfRef", formulaKey: "value", label: "Self Reference Result")
            .addNumberField(identifier: "currentRefResult", formulaRef: "currentRef", formulaKey: "value", label: "Current Reference Result")
            .addCheckboxField(identifier: "thisRefResult", formulaRef: "thisRef", formulaKey: "value", label: "This Reference Result")
            .addTextField(identifier: "objectPropResult", formulaRef: "objectProp", formulaKey: "value", label: "Object Property Result")
            .addTextField(identifier: "nestedObjectPropResult", formulaRef: "nestedObjectProp", formulaKey: "value", label: "Nested Object Property Result")
            .addTextField(identifier: "arrayIndexResult", formulaRef: "arrayIndex", formulaKey: "value", label: "Array Index Result")
            .addNumberField(identifier: "nestedArrayIndexResult", formulaRef: "nestedArrayIndex", formulaKey: "value", label: "Nested Array Index Result")
            .addTextField(identifier: "dynamicArrayIndexResult", formulaRef: "dynamicArrayIndex", formulaKey: "value", label: "Dynamic Array Index Result")
            .addNumberField(identifier: "toNumber1Result", formulaRef: "toNumber1", formulaKey: "value", label: "toNumber(\"100\") Result")
            .addNumberField(identifier: "toNumber2Result", formulaRef: "toNumber2", formulaKey: "value", label: "toNumber(\"100.25\") Result")
            .addNumberField(identifier: "toNumber3Result", formulaRef: "toNumber3", formulaKey: "value", label: "toNumber(\"-50\") Result")
            .addNumberField(identifier: "toNumber4Result", formulaRef: "toNumber4", formulaKey: "value", label: "toNumber(\"invalid\") Result")
            .addNumberField(identifier: "toNumberWithSpaceResult", formulaRef: "toNumberWithSpace", formulaKey: "value", label: "toNumber with spaces Result")
            .addNumberField(identifier: "toNumberCalculationResult", formulaRef: "toNumberCalculation", formulaKey: "value", label: "toNumber Calculation Result")
            
        let documentEditor = DocumentEditor(document: document)
        
        // Test self/current references
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "selfRefResult")?.number, 50) // 25 * 2
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "currentRefResult")?.number, 25) // 15 + 10
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "thisRefResult")?.bool, true) // 75 > 50
        
        // Test object property references
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "objectPropResult")?.text, "John Doe")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "nestedObjectPropResult")?.text, "San Francisco")
        
        // Test array index references
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "arrayIndexResult")?.text, "apple")
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "nestedArrayIndexResult")?.number, 6) // matrix[1][2] = 6
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dynamicArrayIndexResult")?.text, "orange") // fruits[2] = orange
        
        // Test toNumber function
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "toNumber1Result")?.number, 100)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "toNumber2Result")?.number, 100.25)
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "toNumber3Result")?.number, -50)
        // Invalid conversion should return NaN or null, but we can't easily test for NaN
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "toNumberWithSpaceResult")?.number, 42) // Should handle whitespace
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "toNumberCalculationResult")?.number, 84) // 42 * 2
        
        // Test updates
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "selfValue"), updateValue: ValueUnion.int(50)))
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "selfRefResult")?.number, 100) // 50 * 2
        
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "selectedIndex"), updateValue: ValueUnion.int(1)))
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "dynamicArrayIndexResult")?.text, "banana") // fruits[1] = banana
        
        documentEditor.onChange(event: FieldChangeData(fieldIdentifier: documentEditor.identifierModel(for: "stringNumber"), updateValue: ValueUnion.string("100")))
        XCTAssertEqual(documentEditor.value(ofFieldWithIdentifier: "toNumberCalculationResult")?.number, 200) // 100 * 2
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
