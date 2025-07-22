//import XCTest
//@testable import JoyfillFormulas
//@testable import JoyfillModel
//
//final class FormulaEndToEndTests: XCTestCase {
//    // MARK: - Properties
//    
//    // Using JoyDoc as context for tests
//    var joyDoc: JoyDoc!
//    var context: JoyfillDocContext!
//    var parser: Parser!
//    var evaluator: Evaluator!
//    
//    // MARK: - Setup and Teardown
//    
//    override func setUp() {
//        super.setUp()
//        
//        // Create test JoyDoc and context
//        joyDoc = createTestJoyDoc()
//        context = JoyfillDocContext(joyDoc: joyDoc)
//        parser = Parser()
//        evaluator = Evaluator()
//    }
//    
//    override func tearDown() {
//        evaluator = nil
//        parser = nil
//        context = nil
//        joyDoc = nil
//        super.tearDown()
//    }
//    
//    // MARK: - End to End Tests
//    
//    func testSimpleArithmeticFormula() {
//        // Test a simple arithmetic formula
//        let formula = "10 * 3" // Simple arithmetic formula
//        
//        // Parse and evaluate the formula
//        let parseResult = parser.parse(formula: formula)
//        
//        if case .success(let ast) = parseResult {
//            let result = evaluator.evaluate(node: ast, context: context)
//            
//            // Verify result
//            if case .success(let value) = result {
//                XCTAssertEqual(value, FormulaValue.number(30), "Formula should evaluate to 30")
//            } else {
//                XCTFail("Failed to evaluate formula: \(result)")
//            }
//        } else if case .failure(let error) = parseResult {
//            XCTFail("Failed to parse formula: \(error)")
//        }
//    }
//    
//    func testFormulaWithReferences() {
//        // Test a formula that references other fields
//        let formula = "{price} * {quantity}" // References other fields
//        
//        // Parse and evaluate the formula
//        let parseResult = parser.parse(formula: formula)
//        
//        if case .success(let ast) = parseResult {
//            let result = evaluator.evaluate(node: ast, context: context)
//            
//            // Verify result - should be price * quantity
//            if case .success(let value) = result {
//                XCTAssertEqual(value, FormulaValue.number(25 * 4), "Formula should multiply price by quantity")
//            } else {
//                XCTFail("Failed to evaluate formula with references: \(result)")
//            }
//        } else if case .failure(let error) = parseResult {
//            XCTFail("Failed to parse formula: \(error)")
//        }
//    }
//    
//    func testCollectionFormula() {
//        // Test a formula that works with collection data
//        let formula = "MAP({items.price}, \"price\", {price})" // Use MAP instead of SUM since SUM is not implemented
//        
//        // Parse and evaluate the formula
//        let parseResult = parser.parse(formula: formula)
//        
//        if case .success(let ast) = parseResult {
//            let result = evaluator.evaluate(node: ast, context: context)
//            
//            // Verify result - should be an array of all prices
//            if case .success(let value) = result, case .array(let prices) = value {
//                XCTAssertEqual(prices.count, 3, "Should return an array with 3 prices")
//                XCTAssertEqual(prices[0], FormulaValue.number(50), "First price should be 50")
//                XCTAssertEqual(prices[1], FormulaValue.number(30), "Second price should be 30")
//                XCTAssertEqual(prices[2], FormulaValue.number(50), "Third price should be 50")
//            } else {
//                XCTFail("Failed to evaluate collection formula: \(result)")
//            }
//        } else if case .failure(let error) = parseResult {
//            XCTFail("Failed to parse formula: \(error)")
//        }
//    }
//    
//    // MARK: - Formula Field Extension Tests
//    
//    func testFormulaFieldExtension() {
//        // Create a JoyDoc with formula fields using the extension
//        var joyDoc = JoyDoc(dictionary: [:])
//        
//        // Base fields
//        var baseField = JoyDocField(field: [:])
//        baseField.fieldType = .number
//        baseField.identifier = "baseValue"
//        baseField.value = ValueUnion(value: 10.0)!
//        
//        // Create a formula field using the extension
//        let doubleField = JoyDocField.createNumberFormulaField(
//            identifier: "doubleValue",
//            formula: "{baseValue} * 2",
//            value: 20.0 // Pre-calculated value, but our implementation now evaluates dynamically
//        )
//        
//        // Add fields to JoyDoc
//        joyDoc.fields = [baseField, doubleField]
//        
//        // Create context with the JoyDoc
//        let testContext = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Verify that we can access the formula property
//        XCTAssertEqual(doubleField.formula, "{baseValue} * 2", "Formula property should be accessible")
//        
//        // Test resolving the formula field's value - should evaluate dynamically
//        let result = testContext.resolveReference("{doubleValue}")
//        if case .success(let value) = result {
//            XCTAssertEqual(value, .number(20.0), "Should dynamically evaluate to baseValue * 2 = 20.0")
//        } else {
//            XCTFail("Failed to resolve formula field: \(result)")
//        }
//        
//        // Test what happens when base value changes
//        if let index = joyDoc.fields.firstIndex(where: { $0.identifier == "baseValue" }) {
//            joyDoc.fields[index].value = ValueUnion(value: 15.0)!
//        }
//        
//        // Create a new context with the updated JoyDoc
//        let updatedContext = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Test dynamic recalculation without manually updating formula field
//        let updatedResult = updatedContext.resolveReference("{doubleValue}")
//        if case .success(let value) = updatedResult {
//            XCTAssertEqual(value, .number(30.0), "Should dynamically evaluate to new baseValue * 2 = 30.0")
//        } else {
//            XCTFail("Failed to resolve updated formula field: \(updatedResult)")
//        }
//        
//        // Test actual evaluation of the formula directly
//        let parseResult = parser.parse(formula: doubleField.formula!)
//        
//        if case .success(let ast) = parseResult {
//            let evalResult = evaluator.evaluate(node: ast, context: updatedContext)
//            
//            if case .success(let value) = evalResult {
//                XCTAssertEqual(value, .number(30.0), "Formula should evaluate to 30 with updated base value")
//            } else {
//                XCTFail("Failed to evaluate formula: \(evalResult)")
//            }
//        } else {
//            XCTFail("Failed to parse formula: \(parseResult)")
//        }
//    }
//    
//    func testMultipleFormulaFields() {
//        // Create a JoyDoc with multiple formula fields that reference each other
//        var joyDoc = JoyDoc(dictionary: [:])
//        
//        // Base value field
//        var baseField = JoyDocField(field: [:])
//        baseField.fieldType = .number
//        baseField.identifier = "base"
//        baseField.value = ValueUnion(value: 5.0)!
//        
//        // Create formula fields using the extension
//        let squaredField = JoyDocField.createNumberFormulaField(
//            identifier: "squared",
//            formula: "{base} * {base}",
//            value: 0.0 // Pre-calculated value won't be used, formula will be evaluated dynamically
//        )
//        
//        let cubedField = JoyDocField.createNumberFormulaField(
//            identifier: "cubed", 
//            formula: "{squared} * {base}",
//            value: 0.0 // Pre-calculated value won't be used, formula will be evaluated dynamically
//        )
//        
//        let resultField = JoyDocField.createStringFormulaField(
//            identifier: "result",
//            formula: "\"The cube of \" + {base} + \" is \" + {cubed}",
//            value: "" // Pre-calculated value won't be used, formula will be evaluated dynamically
//        )
//        
//        // Add fields to JoyDoc
//        joyDoc.fields = [baseField, squaredField, cubedField, resultField]
//        
//        // Create context with the JoyDoc
//        let testContext = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Test resolving the formula fields
//        let squaredResult = testContext.resolveReference("{squared}")
//        let cubedResult = testContext.resolveReference("{cubed}")
//        let textResult = testContext.resolveReference("{result}")
//        
//        if case .success(let squaredValue) = squaredResult,
//           case .success(let cubedValue) = cubedResult,
//           case .success(let textValue) = textResult {
//            XCTAssertEqual(squaredValue, .number(25.0), "squared should be dynamically calculated as 5^2 = 25")
//            XCTAssertEqual(cubedValue, .number(125.0), "cubed should be dynamically calculated as 25 * 5 = 125")
//            XCTAssertEqual(textValue, .string("The cube of 5 is 125"), "text should be formatted correctly")
//        } else {
//            XCTFail("Failed to resolve formula fields")
//        }
//        
//        // Test what happens when base value changes
//        if let index = joyDoc.fields.firstIndex(where: { $0.identifier == "base" }) {
//            joyDoc.fields[index].value = ValueUnion(value: 10.0)!
//        }
//        
//        // Create a new context with the updated JoyDoc
//        let updatedContext = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Test the dynamic recalculation without manually updating formula fields
//        let updatedSquaredResult = updatedContext.resolveReference("{squared}")
//        let updatedCubedResult = updatedContext.resolveReference("{cubed}")
//        let updatedTextResult = updatedContext.resolveReference("{result}")
//        
//        if case .success(let updatedSquaredValue) = updatedSquaredResult,
//           case .success(let updatedCubedValue) = updatedCubedResult,
//           case .success(let updatedTextValue) = updatedTextResult {
//            XCTAssertEqual(updatedSquaredValue, .number(100.0), "updated squared should be 10^2 = 100")
//            XCTAssertEqual(updatedCubedValue, .number(1000.0), "updated cubed should be 100 * 10 = 1000")
//            XCTAssertEqual(updatedTextValue, .string("The cube of 10 is 1000"), "updated text should reflect new values")
//        } else {
//            XCTFail("Failed to resolve updated formula fields")
//        }
//        
//        // Test evaluating a formula that references all of these fields
//        let formula = "({base} + {squared} + {cubed}) / 3"
//        let parseResult = parser.parse(formula: formula)
//        
//        if case .success(let ast) = parseResult {
//            let evalResult = evaluator.evaluate(node: ast, context: updatedContext)
//            
//            if case .success(let value) = evalResult {
//                // Expected: (10 + 100 + 1000) / 3 = 370
//                XCTAssertEqual(value, .number((10 + 100 + 1000) / 3), "Formula should evaluate using current values")
//            } else {
//                XCTFail("Failed to evaluate formula: \(evalResult)")
//            }
//        } else {
//            XCTFail("Failed to parse formula: \(parseResult)")
//        }
//    }
//    
//    func testCollectionWithFormulaFields() {
//        // Create a JoyDoc with a collection that contains formula fields
//        var joyDoc = JoyDoc(dictionary: [:])
//        
//        // Create tax rate field
//        var taxRateField = JoyDocField(field: [:])
//        taxRateField.fieldType = .number
//        taxRateField.identifier = "taxRate"
//        taxRateField.value = ValueUnion(value: 0.1)! // 10% tax
//        
//        // Create products collection
//        var productsField = JoyDocField(field: [:])
//        productsField.fieldType = .table
//        productsField.identifier = "products"
//        
//        // Create product rows with formula fields
//        var product1 = ValueElement()
//        var product1Cells = [String: ValueUnion]()
//        product1Cells["name"] = ValueUnion(value: "Product A")!
//        product1Cells["price"] = ValueUnion(value: 100.0)!
//        product1Cells["quantity"] = ValueUnion(value: 2.0)!
//        product1Cells["subtotal"] = ValueUnion(value: 200.0)! // price * quantity = 100 * 2 = 200
//        product1Cells["tax"] = ValueUnion(value: 20.0)! // subtotal * taxRate = 200 * 0.1 = 20
//        product1Cells["total"] = ValueUnion(value: 220.0)! // subtotal + tax = 200 + 20 = 220
//        product1.cells = product1Cells
//        
//        var product2 = ValueElement()
//        var product2Cells = [String: ValueUnion]()
//        product2Cells["name"] = ValueUnion(value: "Product B")!
//        product2Cells["price"] = ValueUnion(value: 50.0)!
//        product2Cells["quantity"] = ValueUnion(value: 3.0)!
//        product2Cells["subtotal"] = ValueUnion(value: 150.0)! // price * quantity = 50 * 3 = 150
//        product2Cells["tax"] = ValueUnion(value: 15.0)! // subtotal * taxRate = 150 * 0.1 = 15
//        product2Cells["total"] = ValueUnion(value: 165.0)! // subtotal + tax = 150 + 15 = 165
//        product2.cells = product2Cells
//        
//        productsField.value = ValueUnion(value: [product1, product2])!
//        
//        // Create order total formula field using the extension
//        let orderTotalField = JoyDocField.createNumberFormulaField(
//            identifier: "orderTotal",
//            formula: "SUM({products.total})",
//            value: 385.0 // 220 + 165 = 385
//        )
//        
//        // Add fields to JoyDoc
//        joyDoc.fields = [taxRateField, productsField, orderTotalField]
//        
//        // Create context with the JoyDoc
//        let testContext = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Test resolving orderTotal
//        let orderTotalResult = testContext.resolveReference("{orderTotal}")
//        if case .success(let value) = orderTotalResult {
//            XCTAssertEqual(value, .number(385.0), "orderTotal should be 385")
//        } else {
//            XCTFail("Failed to resolve orderTotal: \(orderTotalResult)")
//        }
//        
//        // Test resolving collection columns
//        let subtotalsResult = testContext.resolveReference("{products.subtotal}")
//        let taxesResult = testContext.resolveReference("{products.tax}")
//        let totalsResult = testContext.resolveReference("{products.total}")
//        
//        if case .success(let subtotalsValue) = subtotalsResult, case .array(let subtotals) = subtotalsValue,
//           case .success(let taxesValue) = taxesResult, case .array(let taxes) = taxesValue,
//           case .success(let totalsValue) = totalsResult, case .array(let totals) = totalsValue {
//            
//            // Check subtotals
//            XCTAssertEqual(subtotals.count, 2, "Should have 2 subtotals")
//            XCTAssertEqual(subtotals[0], .number(200.0), "First subtotal should be 200")
//            XCTAssertEqual(subtotals[1], .number(150.0), "Second subtotal should be 150")
//            
//            // Check taxes
//            XCTAssertEqual(taxes.count, 2, "Should have 2 tax values")
//            XCTAssertEqual(taxes[0], .number(20.0), "First tax should be 20")
//            XCTAssertEqual(taxes[1], .number(15.0), "Second tax should be 15")
//            
//            // Check totals
//            XCTAssertEqual(totals.count, 2, "Should have 2 total values")
//            XCTAssertEqual(totals[0], .number(220.0), "First total should be 220")
//            XCTAssertEqual(totals[1], .number(165.0), "Second total should be 165")
//        } else {
//            XCTFail("Failed to resolve collection columns")
//        }
//    }
//   
//    
//    // MARK: - Helper Methods
//    
//    // Helper method for evaluating formulas
//    private func evaluateFormula(_ formula: String, parser: Parser? = nil, evaluator: Evaluator? = nil, context: EvaluationContext? = nil) -> Result<FormulaValue, FormulaError> {
//        let parserToUse = parser ?? self.parser
//        let evaluatorToUse = evaluator ?? self.evaluator
//        let contextToUse = context ?? self.context
//        
//        let parseResult = parserToUse!.parse(formula: formula)
//        
//        switch parseResult {
//        case .success(let ast):
//            return evaluatorToUse!.evaluate(node: ast, context: contextToUse!)
//        case .failure(let error):
//            return .failure(error)
//        }
//    }
//    
//    // MARK: - JoyDoc Creation
//    
//    private func createTestJoyDoc() -> JoyDoc {
//        var joyDoc = JoyDoc(dictionary: [:])
//        
//        // Add basic input fields
//        var priceField = JoyDocField(field: [:])
//        priceField.fieldType = .number
//        priceField.identifier = "price"
//        priceField.value = ValueUnion(value: 25.0)!
//        
//        var quantityField = JoyDocField(field: [:])
//        quantityField.fieldType = .number
//        quantityField.identifier = "quantity"
//        quantityField.value = ValueUnion(value: 4.0)!
//        
//        // Create items collection
//        var itemsField = JoyDocField(field: [:])
//        itemsField.fieldType = .table
//        itemsField.identifier = "items"
//        
//        // Create item rows
//        var item1 = ValueElement()
//        var item1Cells = [String: ValueUnion]()
//        item1Cells["name"] = ValueUnion(value: "Item 1")!
//        item1Cells["price"] = ValueUnion(value: 50.0)!
//        item1.cells = item1Cells
//        
//        var item2 = ValueElement()
//        var item2Cells = [String: ValueUnion]()
//        item2Cells["name"] = ValueUnion(value: "Item 2")!
//        item2Cells["price"] = ValueUnion(value: 30.0)!
//        item2.cells = item2Cells
//        
//        var item3 = ValueElement()
//        var item3Cells = [String: ValueUnion]()
//        item3Cells["name"] = ValueUnion(value: "Item 3")!
//        item3Cells["price"] = ValueUnion(value: 50.0)!
//        item3.cells = item3Cells
//        
//        let items = [item1, item2, item3]
//        itemsField.value = ValueUnion(value: items)!
//        
//        // Add formula fields using the extension
//        let totalField = JoyDocField.createNumberFormulaField(
//            identifier: "total",
//            formula: "{price} * {quantity}",
//            value: 100.0 // 25 * 4 = 100
//        )
//        
//        let itemsTotalField = JoyDocField.createNumberFormulaField(
//            identifier: "itemsTotal",
//            formula: "SUM({items.price})",
//            value: 130.0 // 50 + 30 + 50 = 130
//        )
//        
//        // Add fields to JoyDoc
//        joyDoc.fields = [
//            priceField,
//            quantityField,
//            itemsField,
//            totalField,
//            itemsTotalField
//        ]
//        
//        return joyDoc
//    }
//
//    func testNumberFieldDependencies1() {
//        // Create a JoyDoc with formula fields that have chained dependencies
//        var joyDoc = JoyDoc(dictionary: [:])
//
//        // Create base number field (n4)
//        var num4Field = JoyDocField(field: [:])
//        num4Field.fieldType = .number
//        num4Field.identifier = "num4"
//        num4Field.value = ValueUnion(value: 10.0)!
//
//        // Create num3 - regular number field
//        var num3Field = JoyDocField(field: [:])
//        num3Field.fieldType = .number
//        num3Field.identifier = "num3"
//        num3Field.value = ValueUnion(value: 15.0)!
//
//        // Create num2 with formula: n2 = n4 + 5
//        let num2Field = JoyDocField.createNumberFormulaField(
//            identifier: "num2",
//            formula: "{num4} + 5",
//            value: 999.0 // Intentionally incorrect pre-calculated value to prove dynamic calculation
//        )
//
//        // Create num1 with formula: n1 = n2 + n3
//        let num1Field = JoyDocField.createNumberFormulaField(
//            identifier: "num1",
//            formula: "{num2} + {num3}",
//            value: 888.0 // Intentionally incorrect pre-calculated value to prove dynamic calculation
//        )
//
//        // Add fields to JoyDoc
//        joyDoc.fields = [num4Field, num3Field, num2Field, num1Field]
//
//        // Create context with the JoyDoc
//        let testContext = JoyfillDocContext(joyDoc: joyDoc)
//
//        // Test resolving all fields - should dynamically evaluate formulas
//        let num4Result = testContext.resolveReference("{num4}")
//        let num3Result = testContext.resolveReference("{num3}")
//        let num2Result = testContext.resolveReference("{num2}")
//        let num1Result = testContext.resolveReference("{num1}")
//
//        // Verify the field values
//        if case .success(let num4Value) = num4Result,
//           case .success(let num3Value) = num3Result,
//           case .success(let num2Value) = num2Result,
//           case .success(let num1Value) = num1Result {
//            XCTAssertEqual(num4Value, .number(10.0), "num4 should be 10")
//            XCTAssertEqual(num3Value, .number(15.0), "num3 should be 15")
//            XCTAssertEqual(num2Value, .number(15.0), "num2 should be dynamically calculated as num4 + 5 = 15, not the pre-calculated value")
//            XCTAssertEqual(num1Value, .number(30.0), "num1 should be dynamically calculated as num2 + num3 = 30, not the pre-calculated value")
//        } else {
//            XCTFail("Failed to resolve number fields")
//        }
//
//        // Now test what happens when base values change
//        // Update num4 value
//        if let index = joyDoc.fields.firstIndex(where: { $0.identifier == "num4" }) {
//            joyDoc.fields[index].value = ValueUnion(value: 20.0)!
//        }
//
//        // Create a new context with the updated JoyDoc
//        let updatedContext = JoyfillDocContext(joyDoc: joyDoc)
//
//        // Test the dynamic recalculation of formulas without manually updating formula field values
//        let updatedNum4Result = updatedContext.resolveReference("{num4}")
//        let updatedNum2Result = updatedContext.resolveReference("{num2}")
//        let updatedNum1Result = updatedContext.resolveReference("{num1}")
//
//        if case .success(let updatedNum4Value) = updatedNum4Result,
//           case .success(let updatedNum2Value) = updatedNum2Result,
//           case .success(let updatedNum1Value) = updatedNum1Result {
//            XCTAssertEqual(updatedNum4Value, .number(20.0), "Updated num4 should be 20")
//            XCTAssertEqual(updatedNum2Value, .number(25.0), "Updated num2 should be dynamically calculated as num4 + 5 = 25")
//            XCTAssertEqual(updatedNum1Value, .number(40.0), "Updated num1 should be dynamically calculated as num2 + num3 = 40")
//        } else {
//            XCTFail("Failed to resolve updated number fields")
//        }
//
//        // Test caching - resolving the same formula again should reuse the calculated value
//        let cachedNum2Result = updatedContext.resolveReference("{num2}")
//        XCTAssertEqual(cachedNum2Result, .success(.number(25.0)), "Cached num2 value should be 25")
//
//        // Testing formula evaluation directly
//        let parser = Parser()
//        let evaluator = Evaluator()
//
//        // Test formulas against the updated context
//        let num2FormulaResult = evaluateFormula(
//            num2Field.formula!,
//            parser: parser,
//            evaluator: evaluator,
//            context: updatedContext
//        )
//
//        let num1FormulaResult = evaluateFormula(
//            num1Field.formula!,
//            parser: parser,
//            evaluator: evaluator,
//            context: updatedContext
//        )
//
//        // Verify the formula evaluations match the resolved references
//        XCTAssertEqual(num2FormulaResult, .success(.number(25.0)), "num2 formula should evaluate to 25")
//        XCTAssertEqual(num1FormulaResult, .success(.number(40.0)), "num1 formula should evaluate to 40")
//    }
//
//    func testNumberFieldDependencies() {
//        // Create a JoyDoc with formula fields that have chained dependencies
//        var joyDoc = JoyDoc(dictionary: [:])
//        
//        // Create base number field (n4)
//        var num4Field = JoyDocField(field: [:])
//        num4Field.fieldType = .number
//        num4Field.identifier = "num4"
//        num4Field.value = ValueUnion(value: 10.0)!
//        
//        // Create num3 - regular number field
//        var num3Field = JoyDocField(field: [:])
//        num3Field.fieldType = .number
//        num3Field.identifier = "num3"
//        num3Field.value = ValueUnion(value: 15.0)!
//        
//        // Create num2 with formula: n2 = n4 + 5
//        let num2Field = JoyDocField.createNumberFormulaField(
//            identifier: "num2",
//            formula: "{num4} + 5",
//            value: 999.0 // Intentionally incorrect pre-calculated value to prove dynamic calculation
//        )
//        
//        // Create num1 with formula: n1 = n2 + n3
//        let num1Field = JoyDocField.createNumberFormulaField(
//            identifier: "num1",
//            formula: "{num2} + {num3}",
//            value: 888.0 // Intentionally incorrect pre-calculated value to prove dynamic calculation
//        )
//        
//        // Add fields to JoyDoc
//        joyDoc.fields = [num4Field, num3Field, num2Field, num1Field]
//        
//        // Create context with the JoyDoc
//        let testContext = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Test resolving all fields - should dynamically evaluate formulas
//        let num4Result = testContext.resolveReference("{num4}")
//        let num3Result = testContext.resolveReference("{num3}")
//        let num2Result = testContext.resolveReference("{num2}")
//        let num1Result = testContext.resolveReference("{num1}")
//        
//        // Verify the field values
//        if case .success(let num4Value) = num4Result,
//           case .success(let num3Value) = num3Result,
//           case .success(let num2Value) = num2Result,
//           case .success(let num1Value) = num1Result {
//            XCTAssertEqual(num4Value, .number(10.0), "num4 should be 10")
//            XCTAssertEqual(num3Value, .number(15.0), "num3 should be 15")
//            XCTAssertEqual(num2Value, .number(15.0), "num2 should be dynamically calculated as num4 + 5 = 15, not the pre-calculated value")
//            XCTAssertEqual(num1Value, .number(30.0), "num1 should be dynamically calculated as num2 + num3 = 30, not the pre-calculated value")
//        } else {
//            XCTFail("Failed to resolve number fields")
//        }
//        
//        // Now test what happens when base values change
//        // Update num4 value
//        if let index = joyDoc.fields.firstIndex(where: { $0.identifier == "num4" }) {
//            joyDoc.fields[index].value = ValueUnion(value: 20.0)!
//        }
//        
//        // Create a new context with the updated JoyDoc
//        let updatedContext = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Test the dynamic recalculation of formulas without manually updating formula field values
//        let updatedNum4Result = updatedContext.resolveReference("{num4}")
//        let updatedNum2Result = updatedContext.resolveReference("{num2}")
//        let updatedNum1Result = updatedContext.resolveReference("{num1}")
//        
//        if case .success(let updatedNum4Value) = updatedNum4Result,
//           case .success(let updatedNum2Value) = updatedNum2Result,
//           case .success(let updatedNum1Value) = updatedNum1Result {
//            XCTAssertEqual(updatedNum4Value, .number(20.0), "Updated num4 should be 20")
//            XCTAssertEqual(updatedNum2Value, .number(25.0), "Updated num2 should be dynamically calculated as num4 + 5 = 25")
//            XCTAssertEqual(updatedNum1Value, .number(40.0), "Updated num1 should be dynamically calculated as num2 + num3 = 40")
//        } else {
//            XCTFail("Failed to resolve updated number fields")
//        }
//        
//        // Test caching - resolving the same formula again should reuse the calculated value
//        let cachedNum2Result = updatedContext.resolveReference("{num2}")
//        XCTAssertEqual(cachedNum2Result, .success(.number(25.0)), "Cached num2 value should be 25")
//        
//        // Testing formula evaluation directly
//        let parser = Parser()
//        let evaluator = Evaluator()
//        
//        // Test formulas against the updated context
//        let num2FormulaResult = evaluateFormula(
//            num2Field.formula!,
//            parser: parser,
//            evaluator: evaluator,
//            context: updatedContext
//        )
//        
//        let num1FormulaResult = evaluateFormula(
//            num1Field.formula!,
//            parser: parser,
//            evaluator: evaluator,
//            context: updatedContext
//        )
//        
//        // Verify the formula evaluations match the resolved references
//        XCTAssertEqual(num2FormulaResult, .success(.number(25.0)), "num2 formula should evaluate to 25")
//        XCTAssertEqual(num1FormulaResult, .success(.number(40.0)), "num1 formula should evaluate to 40")
//    }
//    
//    func testCircularDependencyDetection() {
//        // Create a JoyDoc with formula fields that have circular dependencies
//        var joyDoc = JoyDoc(dictionary: [:])
//        
//        // Create formula fields with circular references
//        let formulaA = JoyDocField.createNumberFormulaField(
//            identifier: "formulaA",
//            formula: "{formulaB} + 5",  // Depends on formulaB
//            value: 0.0  // Value doesn't matter
//        )
//        
//        let formulaB = JoyDocField.createNumberFormulaField(
//            identifier: "formulaB",
//            formula: "{formulaA} - 3",  // Depends on formulaA, creating a circular dependency
//            value: 0.0  // Value doesn't matter
//        )
//        
//        // Add fields to JoyDoc
//        joyDoc.fields = [formulaA, formulaB]
//        
//        // Create context with the JoyDoc
//        let testContext = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Attempt to resolve formulaA (should detect circular dependency)
//        let resultA = testContext.resolveReference("{formulaA}")
//        
//        // Verify that circular dependency was detected
//        if case .failure(let error) = resultA {
//            // Check that it's a circular reference error
//            if case .circularReference(let message) = error {
//                XCTAssertTrue(message.contains("formulaA"), "Error should mention formulaA")
//                print("Successfully detected circular dependency: \(message)")
//            } else {
//                XCTFail("Expected circular reference error but got: \(error)")
//            }
//        } else {
//            XCTFail("Expected circular reference error but got success")
//        }
//        
//        // Attempt to resolve formulaB (should also detect circular dependency)
//        let resultB = testContext.resolveReference("{formulaB}")
//        
//        // Verify that circular dependency was detected from the other direction
//        if case .failure(let error) = resultB {
//            if case .circularReference = error {
//                // Success - circular dependency was detected
//            } else {
//                XCTFail("Expected circular reference error but got: \(error)")
//            }
//        } else {
//            XCTFail("Expected circular reference error but got success")
//        }
//    }
//}
