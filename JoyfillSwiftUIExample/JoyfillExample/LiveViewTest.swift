//
//  LiveViewTest.swift
//  JoyfillExample
//
//  Created by Vishnu Dutt on 21/04/25.
//

import Foundation
import JoyfillModel
import Joyfill
import JoyfillFormulas
import SwiftUI

struct LiveViewTest: View {
    @State private var selectedTest: FormulaTest = .basic
    
    var body: some View {
        VStack {
            Picker("Select Test", selection: $selectedTest) {
                ForEach(FormulaTest.allCases, id: \.self) { test in
                    Text(test.displayName).tag(test)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            selectedTest.view
                .padding(.horizontal)
        }
        .navigationTitle("Formula Tests")
    }
    
    enum FormulaTest: CaseIterable {
        case basic
        case logicalFormulas
        case stringFormulas
        case mathFormulas
        case dateFormulas
        case arrayFormulas
        case complexFormulas
        case conversionFormulas

        var displayName: String {
            switch self {
            case .basic: return "Basic Test"
            case .logicalFormulas: return "Logical Formulas"
            case .stringFormulas: return "String Formulas"
            case .mathFormulas: return "Math Formulas"
            case .dateFormulas: return "Date Formulas"
            case .arrayFormulas: return "Array Formulas"
            case .complexFormulas: return "Complex Formulas"
            case .conversionFormulas: return "Conversion Formulas"
            }
        }

        @ViewBuilder
        var view: some View {
            VStack {
                switch self {
                case .basic:
                    BasicFormulaTest()
                case .logicalFormulas:
                    LogicalFormulaTest()
                case .stringFormulas:
                    StringFormulaTest()
                case .mathFormulas:
                    MathFormulaTest()
                case .dateFormulas:
                    DateFormulaTest()
                case .arrayFormulas:
                    ArrayFormulaTest()
                case .complexFormulas:
                    ComplexFormulaTest()
                case .conversionFormulas:
                    ConversionFormulaTest()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Force stack style
        }
    }
}

// Basic original test
struct BasicFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        let document = JoyDoc.addDocument()
            .addFormula(id: "f1", formula: "if({num2} > 25, true, false)")
            .addFormula(id: "f2", formula: "{num3} + 1")
            .addFormula(id: "f3", formula: "{num4} + 1")
            .addFormula(id: "f4", formula: "{num5} + 1")
            .addFormula(id: "f5", formula: "{num6} + 1")
            .addFormula(id: "f6", formula: "{num7} + 1")

            // Basic mathematical operators
            .addFormula(id: "add1", formula: "{num1} + {num2}")
            .addFormula(id: "subtract1", formula: "{num2} - {num1}")
            .addFormula(id: "multiply1", formula: "{num1} * {num2}")
            .addFormula(id: "divide1", formula: "{num2} / {num1}")
            
            // Basic comparison operators
            .addFormula(id: "equal1", formula: "if({num1} == 10, \"Equal\", \"Not Equal\")")
            .addFormula(id: "notEqual1", formula: "if({num1} != 20, \"Not Equal\", \"Equal\")")
            .addFormula(id: "greaterThan1", formula: "if({num2} > {num1}, \"Greater\", \"Not Greater\")")
            .addFormula(id: "greaterThanEqual1", formula: "if({num2} >= {num1}, \"Greater or Equal\", \"Less\")")
            .addFormula(id: "lessThan1", formula: "if({num1} < {num2}, \"Less\", \"Not Less\")")
            .addFormula(id: "lessThanEqual1", formula: "if({num1} <= {num2}, \"Less or Equal\", \"Greater\")")

            .addNumberField(identifier: "num1", value: 10, label: "Number 1")
            .addNumberField(identifier: "num2", value: 20, label: "Number 2")
            .addNumberField(identifier: "num3", formulaRef: "f3", formulaKey: "value", label: "Number 3")
            .addNumberField(identifier: "num4", formulaRef: "f4", formulaKey: "value", label: "Number 4")
            .addNumberField(identifier: "num5", formulaRef: "f5", formulaKey: "value", label: "Number 5")
            .addNumberField(identifier: "num6", formulaRef: "f6", formulaKey: "value", label: "Number 6")
            .addNumberField(identifier: "num7", value: 22, label: "Number 7")
            
            // Basic operator results
            .addNumberField(identifier: "addResult", formulaRef: "add1", formulaKey: "value", label: "Addition Result")
            .addNumberField(identifier: "subtractResult", formulaRef: "subtract1", formulaKey: "value", label: "Subtraction Result")
            .addNumberField(identifier: "multiplyResult", formulaRef: "multiply1", formulaKey: "value", label: "Multiplication Result")
            .addNumberField(identifier: "divideResult", formulaRef: "divide1", formulaKey: "value", label: "Division Result")
            
            // Comparison results
            .addTextField(identifier: "equalResult", formulaRef: "equal1", formulaKey: "value", label: "Equal Test")
            .addTextField(identifier: "notEqualResult", formulaRef: "notEqual1", formulaKey: "value", label: "Not Equal Test")
            .addTextField(identifier: "greaterThanResult", formulaRef: "greaterThan1", formulaKey: "value", label: "Greater Than Test")
            .addTextField(identifier: "greaterThanEqualResult", formulaRef: "greaterThanEqual1", formulaKey: "value", label: "Greater Than or Equal Test")
            .addTextField(identifier: "lessThanResult", formulaRef: "lessThan1", formulaKey: "value", label: "Less Than Test")
            .addTextField(identifier: "lessThanEqualResult", formulaRef: "lessThanEqual1", formulaKey: "value", label: "Less Than or Equal Test")

        self.documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

// Logical formulas test case
struct LogicalFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        let document = JoyDoc.addDocument()
            // Simple if statement
            .addFormula(id: "if1", formula: "if({num1} > 10, \"Greater than 10\", \"Less or equal to 10\")")
            
            // Nested if
            .addFormula(id: "if2", formula: "if({num1} > 20, \"High\", if({num1} > 10, \"Medium\", \"Low\"))")
            
            // And, Or, Not combination
            .addFormula(id: "logical1", formula: "if(and({num1} > 5, {num1} < 15), \"Between 5 and 15\", \"Outside range\")")
            .addFormula(id: "logical2", formula: "if(or({num1} < 5, {num1} > 20), \"Either small or large\", \"Medium sized\")")
            .addFormula(id: "logical3", formula: "if(not({check1}), \"Unchecked\", \"Checked\")")
            
            // Empty function
            .addFormula(id: "empty1", formula: "if(empty({text1}), \"No text provided\", \"Text is: \" + {text1})")
            
            // Boolean values
            .addFormula(id: "trueValue", formula: "true")
            .addFormula(id: "falseValue", formula: "false")
            .addFormula(id: "yesValue", formula: "yes")
            .addFormula(id: "noValue", formula: "no")
            .addFormula(id: "onValue", formula: "on")
            .addFormula(id: "offValue", formula: "off")
            .addFormula(id: "enabledValue", formula: "enabled")
            .addFormula(id: "disabledValue", formula: "disabled")
            .addFormula(id: "checkedValue", formula: "checked")
            .addFormula(id: "uncheckedValue", formula: "unchecked")
            
            // Fields
            .addNumberField(identifier: "num1", value: 12, label: "Test Number")
            .addCheckboxField(identifier: "check1", value: false, label: "Test Checkbox")
            .addTextField(identifier: "text1", value: "", label: "Enter some text")
            
            // Output fields
            .addTextField(identifier: "result1", formulaRef: "if1", formulaKey: "value", label: "If Statement Result")
            .addTextField(identifier: "result2", formulaRef: "if2", formulaKey: "value", label: "Nested If Result")
            .addTextField(identifier: "result3", formulaRef: "logical1", formulaKey: "value", label: "AND Result")
            .addTextField(identifier: "result4", formulaRef: "logical2", formulaKey: "value", label: "OR Result")
            .addTextField(identifier: "result5", formulaRef: "logical3", formulaKey: "value", label: "NOT Result")
            .addTextField(identifier: "result6", formulaRef: "empty1", formulaKey: "value", label: "Empty Check Result")
            
            // Boolean value results
            .addCheckboxField(identifier: "trueResult", formulaRef: "trueValue", formulaKey: "value", label: "TRUE Value")
            .addCheckboxField(identifier: "falseResult", formulaRef: "falseValue", formulaKey: "value", label: "FALSE Value")
            .addCheckboxField(identifier: "yesResult", formulaRef: "yesValue", formulaKey: "value", label: "YES Value")
            .addCheckboxField(identifier: "noResult", formulaRef: "noValue", formulaKey: "value", label: "NO Value")
            .addCheckboxField(identifier: "onResult", formulaRef: "onValue", formulaKey: "value", label: "ON Value")
            .addCheckboxField(identifier: "offResult", formulaRef: "offValue", formulaKey: "value", label: "OFF Value")
            .addCheckboxField(identifier: "enabledResult", formulaRef: "enabledValue", formulaKey: "value", label: "ENABLED Value")
            .addCheckboxField(identifier: "disabledResult", formulaRef: "disabledValue", formulaKey: "value", label: "DISABLED Value")
            .addCheckboxField(identifier: "checkedResult", formulaRef: "checkedValue", formulaKey: "value", label: "CHECKED Value")
            .addCheckboxField(identifier: "uncheckedResult", formulaRef: "uncheckedValue", formulaKey: "value", label: "UNCHECKED Value")
        
        self.documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

// String formulas test case
struct StringFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        let document = JoyDoc.addDocument()
            // Simple reference
            .addFormula(id: "debug1", formula: "{textInput}")
            
            // Contains check
            .addFormula(id: "contains1", formula: "contains({textInput}, {searchText})")
            
            // Case manipulation
            .addFormula(id: "upper1", formula: "upper({textInput})")
            .addFormula(id: "lower1", formula: "lower({textInput})")
            
            // Length calculation
            .addFormula(id: "length1", formula: "length({textInput})")
            
            // Concatenation
            .addFormula(id: "concat1", formula: "concat({firstName}, \" \", {lastName})")
            .addFormula(id: "concatWithPlus", formula: "{firstName} + \" \" + {lastName}")
            
            // Conditional formatting
            .addFormula(id: "conditionalFormat", formula: "if(length({textInput}) > 10, \"Text is too long (\"+length({textInput})+\" chars)\", \"Text is acceptable\")")
            
            // Email validation pattern
            .addFormula(id: "emailValidation", formula: "if(and(contains({email}, \"@\"), contains({email}, \".\")), \"Valid email format\", \"Invalid email format\")")
            
            // String slicing example using contains and conditionals
            .addFormula(id: "domainExtractor", formula: "if(contains({email}, \"@\"), \"Domain: \" + {email}, \"No domain found\")")
            
            // Complex string transformation
            .addFormula(id: "nameFormatter", formula: "if(and(not(empty({firstName})), not(empty({lastName}))), concat(upper(concat(substring({firstName}, 0, 1), \". \")), {lastName}), \"Please enter your name\")")
            
            // Custom text validation with multiple conditions
            .addFormula(id: "passwordStrength", formula: 
                "if(length({password}) < 8, \"Too short\", " +
                "if(not(contains({password}, \"[0-9]\")), \"Need numbers\", " +
                "if(not(or(contains({password}, \"!\"), contains({password}, \"@\"), contains({password}, \"#\"))), \"Need special chars\", \"Strong password\")))")
            
            // String tests with quote variants
            .addFormula(id: "singleQuotes", formula: "'Single quoted string'")
            .addFormula(id: "doubleQuotes", formula: "\"Double quoted string\"")
            .addFormula(id: "mixedQuotes", formula: "concat('Single', \" and \", 'double', \" quotes\")")
            
            // Input fields
            .addTextField(identifier: "textInput", value: "Sample Text", label: "Input Text")
            .addTextField(identifier: "searchText", value: "Text", label: "Search Term")
            .addTextField(identifier: "firstName", value: "John", label: "First Name")
            .addTextField(identifier: "lastName", value: "Doe", label: "Last Name")
            .addTextField(identifier: "email", value: "example@email.com", label: "Email Address")
            .addTextField(identifier: "password", value: "Password1!", label: "Password")
            
            // Output fields showing formula results
            .addTextField(identifier: "debugOutput", formulaRef: "debug1", formulaKey: "value", label: "Original Text")
            .addTextField(identifier: "containsResult", formulaRef: "contains1", formulaKey: "value", label: "Contains Search Term")
            .addTextField(identifier: "upperResult", formulaRef: "upper1", formulaKey: "value", label: "Uppercase")
            .addTextField(identifier: "lowerResult", formulaRef: "lower1", formulaKey: "value", label: "Lowercase")
            .addNumberField(identifier: "lengthResult", formulaRef: "length1", formulaKey: "value", label: "Text Length")
            .addTextField(identifier: "concatResult", formulaRef: "concat1", formulaKey: "value", label: "Full Name (concat)")
            .addTextField(identifier: "plusConcatResult", formulaRef: "concatWithPlus", formulaKey: "value", label: "Full Name (+ operator)")
            .addTextField(identifier: "formatResult", formulaRef: "conditionalFormat", formulaKey: "value", label: "Length Check")
            .addTextField(identifier: "emailResult", formulaRef: "emailValidation", formulaKey: "value", label: "Email Validation")
            .addTextField(identifier: "domainResult", formulaRef: "domainExtractor", formulaKey: "value", label: "Domain Info")
            .addTextField(identifier: "nameFormatResult", formulaRef: "nameFormatter", formulaKey: "value", label: "Formatted Name")
            .addTextField(identifier: "passwordResult", formulaRef: "passwordStrength", formulaKey: "value", label: "Password Strength")
            .addTextField(identifier: "singleQuotesResult", formulaRef: "singleQuotes", formulaKey: "value", label: "Single Quotes")
            .addTextField(identifier: "doubleQuotesResult", formulaRef: "doubleQuotes", formulaKey: "value", label: "Double Quotes")
            .addTextField(identifier: "mixedQuotesResult", formulaRef: "mixedQuotes", formulaKey: "value", label: "Mixed Quotes")
        
        self.documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

// Math formulas test case
struct MathFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        let document = JoyDoc.addDocument()
            // Sum
            .addFormula(id: "sum1", formula: "sum({num1}, {num2}, {num3})")
            .addFormula(id: "sumArray", formula: "sum([{num1}, {num2}, {num3}])")
            .addFormula(id: "sumMixed", formula: "sum([{num1}], {num2}, {num3})")
            
            // Power
            .addFormula(id: "pow1", formula: "pow({base}, {exponent})")
            
            // Rounding functions
            .addFormula(id: "round1", formula: "round({decimal})")
            .addFormula(id: "roundWithPlaces", formula: "round({decimal}, {places})")
            .addFormula(id: "ceil1", formula: "ceil({decimal})")
            .addFormula(id: "floor1", formula: "floor({decimal})")
            
            // Mod and sqrt
            .addFormula(id: "mod1", formula: "mod({dividend}, {divisor})")
            .addFormula(id: "modNegative", formula: "mod(-{dividend}, {divisor})")
            .addFormula(id: "sqrt1", formula: "sqrt({number})")
            
            // Max value
            .addFormula(id: "max1", formula: "max({num1}, {num2}, {num3})")
            .addFormula(id: "maxArray", formula: "max([{num1}, {num2}, {num3}])")
            .addFormula(id: "maxMixed", formula: "max({num1}, [{num2}, {num3}])")
            
            // Negative numbers
            .addFormula(id: "negative1", formula: "-{num1}")
            .addFormula(id: "negativeParens", formula: "(-{num1})")
            .addFormula(id: "negativeMultiply", formula: "{num1} * (-1)")
            
            // Input fields
            .addNumberField(identifier: "num1", value: 10, label: "Number 1")
            .addNumberField(identifier: "num2", value: 20, label: "Number 2")
            .addNumberField(identifier: "num3", value: 30, label: "Number 3")
            .addNumberField(identifier: "base", value: 2, label: "Base")
            .addNumberField(identifier: "exponent", value: 3, label: "Exponent")
            .addNumberField(identifier: "decimal", value: 3.75, label: "Decimal for Rounding")
            .addNumberField(identifier: "places", value: 1, label: "Decimal Places")
            .addNumberField(identifier: "dividend", value: 17, label: "Dividend")
            .addNumberField(identifier: "divisor", value: 5, label: "Divisor")
            .addNumberField(identifier: "number", value: 16, label: "Number for Square Root")
            
            // Output fields
            .addNumberField(identifier: "sumResult", formulaRef: "sum1", formulaKey: "value", label: "Sum Result")
            .addNumberField(identifier: "sumArrayResult", formulaRef: "sumArray", formulaKey: "value", label: "Sum Array Result")
            .addNumberField(identifier: "sumMixedResult", formulaRef: "sumMixed", formulaKey: "value", label: "Sum Mixed Result")
            .addNumberField(identifier: "powResult", formulaRef: "pow1", formulaKey: "value", label: "Power Result")
            .addNumberField(identifier: "roundResult", formulaRef: "round1", formulaKey: "value", label: "Rounded Value (no places)")
            .addNumberField(identifier: "roundWithPlacesResult", formulaRef: "roundWithPlaces", formulaKey: "value", label: "Rounded Value (with places)")
            .addNumberField(identifier: "ceilResult", formulaRef: "ceil1", formulaKey: "value", label: "Ceiling Value")
            .addNumberField(identifier: "floorResult", formulaRef: "floor1", formulaKey: "value", label: "Floor Value")
            .addNumberField(identifier: "modResult", formulaRef: "mod1", formulaKey: "value", label: "Modulo Result")
            .addNumberField(identifier: "modNegativeResult", formulaRef: "modNegative", formulaKey: "value", label: "Negative Modulo Result")
            .addNumberField(identifier: "sqrtResult", formulaRef: "sqrt1", formulaKey: "value", label: "Square Root")
            .addNumberField(identifier: "maxResult", formulaRef: "max1", formulaKey: "value", label: "Maximum Value")
            .addNumberField(identifier: "maxArrayResult", formulaRef: "maxArray", formulaKey: "value", label: "Max Array Result")
            .addNumberField(identifier: "maxMixedResult", formulaRef: "maxMixed", formulaKey: "value", label: "Max Mixed Result")
            .addNumberField(identifier: "negativeResult", formulaRef: "negative1", formulaKey: "value", label: "Negative Number")
            .addNumberField(identifier: "negativeParensResult", formulaRef: "negativeParens", formulaKey: "value", label: "Negative with Parens")
            .addNumberField(identifier: "negativeMultiplyResult", formulaRef: "negativeMultiply", formulaKey: "value", label: "Negative via Multiply")
        
        self.documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

// Date formulas test case
struct DateFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        // Create a timestamp for testing (January 15, 2025)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let testDate = dateFormatter.date(from: "2025-01-15")!
        let timestamp = testDate.timeIntervalSince1970 * 1000 // Convert to milliseconds
        
        let document = JoyDoc.addDocument()
            // Current date/time
            .addFormula(id: "now1", formula: "now()")
            
            // Create date from timestamp
            .addFormula(id: "timestampToDate", formula: "timestamp({dateTimestamp})")
            
            // Date components
            .addFormula(id: "year1", formula: "year(timestamp({dateTimestamp}))")
            .addFormula(id: "month1", formula: "month(timestamp({dateTimestamp}))")
            .addFormula(id: "day1", formula: "day(timestamp({dateTimestamp}))")
            
            // Date creation
            .addFormula(id: "date1Creation", formula: "date({year}, {month}, {day})")
            
            // Date additions
            .addFormula(id: "dateAdd1", formula: "dateAdd(timestamp({dateTimestamp}), {amount}, {unit})")
            .addFormula(id: "dateSubtract1", formula: "dateSubtract(timestamp({dateTimestamp}), {amount}, {unit})")
            
            // Date comparisons
            .addFormula(id: "dateEqual", formula: "if(date({year}, {month}, {day}) == date({year}, {month}, {day}), \"Dates Equal\", \"Dates Not Equal\")")
            .addFormula(id: "dateBefore", formula: "if(timestamp({dateTimestamp}) < now(), \"Selected date is in the past\", \"Selected date is not in the past\")")
            .addFormula(id: "dateAfter", formula: "if(timestamp({dateTimestamp}) > now(), \"Selected date is in the future\", \"Selected date is not in the future\")")
            
            // Input fields
            .addNumberField(identifier: "dateTimestamp", value: Double(timestamp), label: "Date Timestamp (milliseconds)")
            .addNumberField(identifier: "year", value: 2025, label: "Year")
            .addNumberField(identifier: "month", value: 5, label: "Month")
            .addNumberField(identifier: "day", value: 15, label: "Day")
            .addNumberField(identifier: "amount", value: 7, label: "Amount")
            .addOptionField(identifier: "unit", value: ["days"], options: ["days", "weeks", "months", "years"], label: "Time Unit")

            // Output fields
            .addDateField(identifier: "currentDate", formulaRef: "now1", formulaKey: "value", label: "Current Date/Time")
            .addDateField(identifier: "timestampDateResult", formulaRef: "timestampToDate", formulaKey: "value", label: "Date from Timestamp")
            .addNumberField(identifier: "yearResult", formulaRef: "year1", formulaKey: "value", label: "Year Component")
            .addNumberField(identifier: "monthResult", formulaRef: "month1", formulaKey: "value", label: "Month Component")
            .addNumberField(identifier: "dayResult", formulaRef: "day1", formulaKey: "value", label: "Day Component")
            .addDateField(identifier: "createdDate", formulaRef: "date1Creation", formulaKey: "value", label: "Created Date")
            .addDateField(identifier: "dateAddResult", formulaRef: "dateAdd1", formulaKey: "value", label: "Date After Addition")
            .addDateField(identifier: "dateSubtractResult", formulaRef: "dateSubtract1", formulaKey: "value", label: "Date After Subtraction")
            .addTextField(identifier: "dateEqualResult", formulaRef: "dateEqual", formulaKey: "value", label: "Date Equality Test")
            .addTextField(identifier: "dateBeforeResult", formulaRef: "dateBefore", formulaKey: "value", label: "Date Before Test")
            .addTextField(identifier: "dateAfterResult", formulaRef: "dateAfter", formulaKey: "value", label: "Date After Test")
        
        self.documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

// Array formulas test case
struct ArrayFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        let document = JoyDoc.addDocument()
            // Array length
            .addFormula(id: "arrayLength", formula: "length({options})")
            
            // Count if
            .addFormula(id: "countIf1", formula: "countIf({options}, {searchText})")
            
            // Array concat
            .addFormula(id: "arrayConcat", formula: "concat(\"Selected options: \", {options})")
            .addFormula(id: "arrayConcatArrays", formula: "concat({options}, [\", more items\"])")
            
            // Advanced array operations
            .addFormula(id: "flat1", formula: "flat([[{options}], [\"nested\"]])")
            .addFormula(id: "flatWithDepth", formula: "flat([[{options}], [[\"deeply\"], [\"nested\"]]], 2)")
            .addFormula(id: "map1", formula: "map({numArray}, (item) → item * 2)")
            .addFormula(id: "flatMap1", formula: "flatMap({numArray}, (item) → [item, item * 2])")
            .addFormula(id: "filter1", formula: "filter({numArray}, (item) → item > 2)")
            .addFormula(id: "reduce1", formula: "reduce({numArray}, (acc, item) → acc + item, 0)")
            .addFormula(id: "find1", formula: "find({numArray}, (item) → item > 3)")
            .addFormula(id: "every1", formula: "every({numArray}, (item) → item > 0)")
            .addFormula(id: "some1", formula: "some({numArray}, (item) → item > 3)")
            
            // Input fields
            .addOptionField(identifier: "options", 
                           value: ["apple"],
                            options: ["apple", "banana", "cherry", "date", "elderberry"], multiselect: true,
                           label: "Select Fruits")
            .addTextField(identifier: "searchText", value: "a", label: "Search Text")
            .addTextField(identifier: "numArray", value: "[1, 2, 3, 4, 5]", label: "Number Array (1,2,3,4,5)")
            
            // Output fields
            .addNumberField(identifier: "lengthResult", formulaRef: "arrayLength", formulaKey: "value", label: "Number of Selections")
            .addNumberField(identifier: "countIfResult", formulaRef: "countIf1", formulaKey: "value", label: "Options Containing Search Text")
            .addTextField(identifier: "concatResult", formulaRef: "arrayConcat", formulaKey: "value", label: "Selected Options String")
            .addTextField(identifier: "arrayConcatResult", formulaRef: "arrayConcatArrays", formulaKey: "value", label: "Array Concatenation")
            .addTextField(identifier: "flatResult", formulaRef: "flat1", formulaKey: "value", label: "Flattened Array")
            .addTextField(identifier: "flatDepthResult", formulaRef: "flatWithDepth", formulaKey: "value", label: "Flattened With Depth")
            .addTextField(identifier: "mapResult", formulaRef: "map1", formulaKey: "value", label: "Mapped Array (doubled)")
            .addTextField(identifier: "flatMapResult", formulaRef: "flatMap1", formulaKey: "value", label: "FlatMapped Array")
            .addTextField(identifier: "filterResult", formulaRef: "filter1", formulaKey: "value", label: "Filtered Array (> 2)")
            .addNumberField(identifier: "reduceResult", formulaRef: "reduce1", formulaKey: "value", label: "Reduced Array (sum)")
            .addNumberField(identifier: "findResult", formulaRef: "find1", formulaKey: "value", label: "Find Result (> 3)")
            .addCheckboxField(identifier: "everyResult", formulaRef: "every1", formulaKey: "value", label: "Every Result (all > 0)")
            .addCheckboxField(identifier: "someResult", formulaRef: "some1", formulaKey: "value", label: "Some Result (any > 3)")
        
        self.documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

// Complex formula combinations
struct ComplexFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        // Create timestamp for 2030-01-01
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let futureDate = dateFormatter.date(from: "2030-01-01")!
        let futureTimestamp = futureDate.timeIntervalSince1970 * 1000 // Convert to milliseconds

        let document = JoyDoc.addDocument()
            // Complex formula using multiple functions and operations
            .addFormula(id: "complex1", formula: "if(and(length({text1}) > 5, contains(lower({text1}), \"test\")), concat(\"Valid: \", upper({text1})), \"Invalid input\")")
            
            // Math + string formula
            .addFormula(id: "mathString1", formula: "concat(\"Result: \", round(pow({num1}, {num2}), 2))")
            
            // Date + math formula
            .addFormula(id: "dateCalc1", formula: "concat(\"Days until 2030: \", round((timestamp({futureTimestamp}) - now()) / (1000 * 60 * 60 * 24)))")
            
            // Array + string + logical formula
            .addFormula(id: "arrayLogic1", formula: "if(some({options}, (item) → contains(item, \"a\")), concat(\"Contains 'a': \", filter({options}, (item) → contains(item, \"a\"))), \"No items with 'a'\")")
            
            // Nested functions and operators
            .addFormula(id: "nested1", formula: "if({num1} > 10, pow(sum({num1}, {num2}), 2), sqrt(max({num1}, {num2})))")
            
            // Self referencing example
            .addFormula(id: "selfRef1", formula: "if({selfInput} > 100, 100, {selfInput})")
            
            // Formula with different data types
            .addFormula(id: "mixedTypes1", formula: "concat(\"Text: \", {text1}, \", Number: \", {num1}, \", Date: \", timestamp({currentTimestamp}))")
            
            // Input fields
            .addTextField(identifier: "text1", value: "Test String", label: "Text Input")
            .addNumberField(identifier: "num1", value: 5, label: "Number 1")
            .addNumberField(identifier: "num2", value: 3, label: "Number 2")
            .addNumberField(identifier: "currentTimestamp", value: Date().timeIntervalSince1970 * 1000, label: "Current Timestamp")
            .addNumberField(identifier: "futureTimestamp", value: futureTimestamp, label: "Future Timestamp (2030-01-01)")
            .addOptionField(identifier: "options", value: ["apple", "banana"], options: ["apple", "banana", "cherry", "date"], multiselect: true, label: "Options")
            .addNumberField(identifier: "selfInput", value: 50, label: "Self-Reference Input")
            
            // Output fields
            .addTextField(identifier: "complexResult", formulaRef: "complex1", formulaKey: "value", label: "Complex Formula Result")
            .addTextField(identifier: "mathStringResult", formulaRef: "mathString1", formulaKey: "value", label: "Math + String Result")
            .addTextField(identifier: "dateCalcResult", formulaRef: "dateCalc1", formulaKey: "value", label: "Date Calculation Result")
            .addTextField(identifier: "arrayLogicResult", formulaRef: "arrayLogic1", formulaKey: "value", label: "Array + Logic Result")
            .addNumberField(identifier: "nestedResult", formulaRef: "nested1", formulaKey: "value", label: "Nested Functions Result")
            .addNumberField(identifier: "selfRefResult", formulaRef: "selfRef1", formulaKey: "value", label: "Self Reference Result")
            .addTextField(identifier: "mixedTypesResult", formulaRef: "mixedTypes1", formulaKey: "value", label: "Mixed Types Result")
            
        self.documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

// Type conversion formulas
struct ConversionFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        let document = JoyDoc.addDocument()
            // String to Number conversion
            .addFormula(id: "toNumber1", formula: "toNumber({stringNumber})")
            .addFormula(id: "toNumberDecimal", formula: "toNumber({stringDecimal})")
            .addFormula(id: "toNumberNegative", formula: "toNumber({stringNegative})")
            .addFormula(id: "toNumberInvalid", formula: "toNumber({stringInvalid})")
            
            // Result of calculations on converted values
            .addFormula(id: "calcOnConverted", formula: "toNumber({stringNumber}) + toNumber({stringDecimal})")
            
            // Type checking with conditionals
            .addFormula(id: "typeCheck1", formula: "if(toNumber({stringNumber}) == {stringNumber}, \"Same value\", \"Different value\")")
            
            // Input fields
            .addTextField(identifier: "stringNumber", value: "100", label: "String Number (100)")
            .addTextField(identifier: "stringDecimal", value: "100.11", label: "String Decimal (100.11)")
            .addTextField(identifier: "stringNegative", value: "-1", label: "String Negative (-1)")
            .addTextField(identifier: "stringInvalid", value: "n100", label: "Invalid String (n100)")
            
            // Output fields
            .addNumberField(identifier: "toNumberResult", formulaRef: "toNumber1", formulaKey: "value", label: "toNumber Result")
            .addNumberField(identifier: "toNumberDecimalResult", formulaRef: "toNumberDecimal", formulaKey: "value", label: "toNumber Decimal Result")
            .addNumberField(identifier: "toNumberNegativeResult", formulaRef: "toNumberNegative", formulaKey: "value", label: "toNumber Negative Result")
            .addTextField(identifier: "toNumberInvalidResult", formulaRef: "toNumberInvalid", formulaKey: "value", label: "toNumber Invalid Result")
            .addNumberField(identifier: "calcOnConvertedResult", formulaRef: "calcOnConverted", formulaKey: "value", label: "Calculation on Converted")
            .addTextField(identifier: "typeCheckResult", formulaRef: "typeCheck1", formulaKey: "value", label: "Type Check Result")
        
        self.documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

#Preview {
    LiveViewTest()
}
