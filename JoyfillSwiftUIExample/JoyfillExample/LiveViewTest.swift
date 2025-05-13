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
        NavigationView {
            VStack {
                Picker("Select Test", selection: $selectedTest) {
                    ForEach(FormulaTest.allCases, id: \.self) { test in
                        Text(test.displayName).tag(test)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                selectedTest.view
            }
            .navigationTitle("Formula Tests")
        }
    }
    
    enum FormulaTest: CaseIterable {
        case basic
        case logicalFormulas
        case stringFormulas
        case mathFormulas
        case dateFormulas
        case arrayFormulas
        
        var displayName: String {
            switch self {
            case .basic: return "Basic Test"
            case .logicalFormulas: return "Logical Formulas"
            case .stringFormulas: return "String Formulas"
            case .mathFormulas: return "Math Formulas"
            case .dateFormulas: return "Date Formulas"
            case .arrayFormulas: return "Array Formulas"
            }
        }
        
        @ViewBuilder
        var view: some View {
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
            }
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

            .addNumberField(identifier: "num1", formulaRef: "f1", formulaKey: "value")
            .addNumberField(identifier: "num2", formulaRef: "f2", formulaKey: "value")
            .addNumberField(identifier: "num3", formulaRef: "f3", formulaKey: "value")
            .addNumberField(identifier: "num4", formulaRef: "f4", formulaKey: "value")
            .addNumberField(identifier: "num5", formulaRef: "f5", formulaKey: "value")
            .addNumberField(identifier: "num6", formulaRef: "f6", formulaKey: "value")
            .addNumberField(identifier: "num7", value: 22)

        self.documentEditor = DocumentEditor(document: document)
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
        
        self.documentEditor = DocumentEditor(document: document)
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
            .addTextField(identifier: "concatResult", formulaRef: "concat1", formulaKey: "value", label: "Full Name")
            .addTextField(identifier: "formatResult", formulaRef: "conditionalFormat", formulaKey: "value", label: "Length Check")
            .addTextField(identifier: "emailResult", formulaRef: "emailValidation", formulaKey: "value", label: "Email Validation")
            .addTextField(identifier: "domainResult", formulaRef: "domainExtractor", formulaKey: "value", label: "Domain Info")
            .addTextField(identifier: "nameFormatResult", formulaRef: "nameFormatter", formulaKey: "value", label: "Formatted Name")
            .addTextField(identifier: "passwordResult", formulaRef: "passwordStrength", formulaKey: "value", label: "Password Strength")
        
        self.documentEditor = DocumentEditor(document: document)
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
            
            // Power
            .addFormula(id: "pow1", formula: "pow({base}, {exponent})")
            
            // Rounding functions
            .addFormula(id: "round1", formula: "round({decimal}, {places})")
            .addFormula(id: "ceil1", formula: "ceil({decimal})")
            .addFormula(id: "floor1", formula: "floor({decimal})")
            
            // Mod and sqrt
            .addFormula(id: "mod1", formula: "mod({dividend}, {divisor})")
            .addFormula(id: "sqrt1", formula: "sqrt({number})")
            
            // Max value
            .addFormula(id: "max1", formula: "max({num1}, {num2}, {num3})")
            
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
            .addNumberField(identifier: "powResult", formulaRef: "pow1", formulaKey: "value", label: "Power Result")
            .addNumberField(identifier: "roundResult", formulaRef: "round1", formulaKey: "value", label: "Rounded Value")
            .addNumberField(identifier: "ceilResult", formulaRef: "ceil1", formulaKey: "value", label: "Ceiling Value")
            .addNumberField(identifier: "floorResult", formulaRef: "floor1", formulaKey: "value", label: "Floor Value")
            .addNumberField(identifier: "modResult", formulaRef: "mod1", formulaKey: "value", label: "Modulo Result")
            .addNumberField(identifier: "sqrtResult", formulaRef: "sqrt1", formulaKey: "value", label: "Square Root")
            .addNumberField(identifier: "maxResult", formulaRef: "max1", formulaKey: "value", label: "Maximum Value")
        
        self.documentEditor = DocumentEditor(document: document)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

// Date formulas test case
struct DateFormulaTest: View {
    let documentEditor: DocumentEditor
    
    init() {
        let document = JoyDoc.addDocument()
            // Current date/time
            .addFormula(id: "now1", formula: "now()")
            
            // Date components
            .addFormula(id: "year1", formula: "year({date1})")
            .addFormula(id: "month1", formula: "month({date1})")
            .addFormula(id: "day1", formula: "day({date1})")
            
            // Date creation
            .addFormula(id: "date1Creation", formula: "date({year}, {month}, {day})")
            
            // Date additions
            .addFormula(id: "dateAdd1", formula: "dateAdd({date1}, {amount}, {unit})")
            .addFormula(id: "dateSubtract1", formula: "dateSubtract({date1}, {amount}, {unit})")
            
            // Input fields
            .addDateField(identifier: "date1", value: nil, label: "Select Date")
            .addNumberField(identifier: "year", value: 2025, label: "Year")
            .addNumberField(identifier: "month", value: 5, label: "Month")
            .addNumberField(identifier: "day", value: 15, label: "Day")
            .addNumberField(identifier: "amount", value: 7, label: "Amount")
            .addOptionField(identifier: "unit", value: "days", options: ["days", "weeks", "months", "years"], label: "Time Unit")
            
            // Output fields
            .addDateField(identifier: "currentDate", formulaRef: "now1", formulaKey: "value", label: "Current Date/Time")
            .addNumberField(identifier: "yearResult", formulaRef: "year1", formulaKey: "value", label: "Year Component")
            .addNumberField(identifier: "monthResult", formulaRef: "month1", formulaKey: "value", label: "Month Component")
            .addNumberField(identifier: "dayResult", formulaRef: "day1", formulaKey: "value", label: "Day Component")
            .addDateField(identifier: "createdDate", formulaRef: "date1Creation", formulaKey: "value", label: "Created Date")
            .addDateField(identifier: "dateAddResult", formulaRef: "dateAdd1", formulaKey: "value", label: "Date After Addition")
            .addDateField(identifier: "dateSubtractResult", formulaRef: "dateSubtract1", formulaKey: "value", label: "Date After Subtraction")
        
        self.documentEditor = DocumentEditor(document: document)
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
            
            // Input fields
            .addOptionField(identifier: "options", 
                           value: "apple",
                            options: ["apple", "banana", "cherry", "date", "elderberry"], multiselect: true,
                           label: "Select Fruits")
            .addTextField(identifier: "searchText", value: "a", label: "Search Text")
            
            // Output fields
            .addNumberField(identifier: "lengthResult", formulaRef: "arrayLength", formulaKey: "value", label: "Number of Selections")
            .addNumberField(identifier: "countIfResult", formulaRef: "countIf1", formulaKey: "value", label: "Options Containing Search Text")
            .addTextField(identifier: "concatResult", formulaRef: "arrayConcat", formulaKey: "value", label: "Selected Options String")
        
        self.documentEditor = DocumentEditor(document: document)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

#Preview {
    LiveViewTest()
}
