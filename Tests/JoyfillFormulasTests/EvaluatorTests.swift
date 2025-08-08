import XCTest
@testable import JoyfillFormulas

final class EvaluatorTests: XCTestCase {

    var evaluator: Evaluator!
    var emptyContext: EvaluationContext!
    // Add specific contexts as needed for reference tests

    override func setUp() {
        super.setUp()
        evaluator = Evaluator() 
        emptyContext = DictionaryContext()
    }

    override func tearDown() {
        evaluator = nil
        emptyContext = nil
        super.tearDown()
    }

    // Helper function to simplify evaluation assertions
    func assertEval(_ node: ASTNode, context: EvaluationContext? = nil, equals expectedValue: FormulaValue, file: StaticString = #file, line: UInt = #line) {
        let result = evaluator.evaluate(node: node, context: context ?? emptyContext)
        switch result {
        case .success(let value):
            XCTAssertEqual(value, expectedValue, "Evaluation result mismatch.", file: file, line: line)
        case .failure(let error):
            XCTFail("Evaluation failed unexpectedly with error: \(error)", file: file, line: line)
        }
    }

    func assertEvalFails(_ node: ASTNode, context: EvaluationContext? = nil, file: StaticString = #file, line: UInt = #line) {
        let result = evaluator.evaluate(node: node, context: context ?? emptyContext)
        switch result {
        case .success(let value):
             XCTFail("Evaluation succeeded unexpectedly with value: \(value)", file: file, line: line)
        case .failure(_):
            // Expected failure
             XCTAssert(true)
        }
    }
    
    // MARK: - Literal & Reference Tests
    
    func testEvaluate_LiteralNumber() {
        assertEval(.literal(.number(123)), equals: .number(123))
    }
    
    func testEvaluate_LiteralString() {
         assertEval(.literal(.string("hello")), equals: .string("hello"))
    }
    
    func testEvaluate_LiteralBoolean() {
         // Need parser support for true/false first, but evaluator handles the value
         assertEval(.literal(.boolean(true)), equals: .boolean(true))
         assertEval(.literal(.boolean(false)), equals: .boolean(false))
    }
    
    func testEvaluate_LiteralArray() {
        let arrayNode = ASTNode.arrayLiteral([
            .literal(.number(1)),
            .literal(.string("a"))
        ])
        // Evaluate the array literal AST node itself
        assertEval(arrayNode, equals: .array([.number(1), .string("a")]))
    }
    
    func testEvaluate_Reference_Success() {
        let context = DictionaryContext(["price": .number(99.9)])
        assertEval(.reference("price"), context: context, equals: .number(99.9))
    }

    func testEvaluate_Reference_NotFound() {
        assertEvalFails(.reference("missing"))
    }
    
    func testEvaluate_Reference_CaseSensitivity() {
        // Assuming context keys are case-sensitive
        let context = DictionaryContext(["Price": .number(100)])
        assertEvalFails(.reference("price"), context: context)
        assertEval(.reference("Price"), context: context, equals: .number(100))
    }

    // MARK: - Infix Operation Tests
    
    // Tests for +, -, *, / with numbers were implicitly covered by HOF tests.
    // Add explicit tests focusing on Evaluator logic.

    func testEvaluate_Add_Numbers() {
        let node = ASTNode.infixOperation(operator: "+", left: .literal(.number(5)), right: .literal(.number(3)))
        assertEval(node, equals: .number(8))
    }
    
    func testEvaluate_Add_Strings() {
         let node = ASTNode.infixOperation(operator: "+", left: .literal(.string("Joy")), right: .literal(.string("fill")))
         assertEval(node, equals: .string("Joyfill"))
    }

    func testEvaluate_Add_StringAndNumber() {
         let node = ASTNode.infixOperation(operator: "+", left: .literal(.string("Value: ")), right: .literal(.number(42)))
         assertEval(node, equals: .string("Value: 42"))
    }
    
    func testEvaluate_Add_NumberAndString() {
         let node = ASTNode.infixOperation(operator: "+", left: .literal(.number(1)), right: .literal(.string(" item")))
         assertEval(node, equals: .string("1 item"))
    }
    
    func testEvaluate_Add_TypeMismatch() {
        let node = ASTNode.infixOperation(operator: "+", left: .literal(.number(1)), right: .literal(.boolean(true)))
        assertEvalFails(node)
    }
    
    func testEvaluate_Subtract_Numbers() {
        let node = ASTNode.infixOperation(operator: "-", left: .literal(.number(10)), right: .literal(.number(3)))
        assertEval(node, equals: .number(7))
    }
    
    func testEvaluate_Subtract_TypeMismatch() {
        let node = ASTNode.infixOperation(operator: "-", left: .literal(.string("a")), right: .literal(.number(3)))
        assertEvalFails(node)
    }

    func testEvaluate_Multiply_Numbers() {
        let node = ASTNode.infixOperation(operator: "*", left: .literal(.number(5)), right: .literal(.number(3)))
        assertEval(node, equals: .number(15))
    }

    func testEvaluate_Multiply_TypeMismatch() {
         let node = ASTNode.infixOperation(operator: "*", left: .literal(.number(5)), right: .literal(.string("a")))
         assertEvalFails(node)
    }
    
    func testEvaluate_Divide_Numbers() {
        let node = ASTNode.infixOperation(operator: "/", left: .literal(.number(10)), right: .literal(.number(2)))
        assertEval(node, equals: .number(5))
    }
    
    func testEvaluate_Divide_ByZero() {
         let node = ASTNode.infixOperation(operator: "/", left: .literal(.number(10)), right: .literal(.number(0)))
         let result = evaluator.evaluate(node: node, context: emptyContext)
         guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
         guard case .divisionByZero = error else { XCTFail("Expected divisionByZero error"); return }
         XCTAssert(true)
    }

    func testEvaluate_Divide_TypeMismatch() {
         let node = ASTNode.infixOperation(operator: "/", left: .literal(.string("a")), right: .literal(.number(2)))
         assertEvalFails(node)
    }
    
    // MARK: - Comparison Operator Tests
    
    func testEvaluate_Equals_Numbers() {
        assertEval(.infixOperation(operator: "==", left: .literal(.number(5)), right: .literal(.number(5))), equals: .boolean(true))
        assertEval(.infixOperation(operator: "==", left: .literal(.number(5)), right: .literal(.number(6))), equals: .boolean(false))
    }
    
    func testEvaluate_Equals_Strings() {
        assertEval(.infixOperation(operator: "==", left: .literal(.string("a")), right: .literal(.string("a"))), equals: .boolean(true))
        assertEval(.infixOperation(operator: "==", left: .literal(.string("a")), right: .literal(.string("b"))), equals: .boolean(false))
    }

    func testEvaluate_Equals_Booleans() {
         assertEval(.infixOperation(operator: "==", left: .literal(.boolean(true)), right: .literal(.boolean(true))), equals: .boolean(true))
         assertEval(.infixOperation(operator: "==", left: .literal(.boolean(true)), right: .literal(.boolean(false))), equals: .boolean(false))
    }
    
    func testEvaluate_Equals_TypeMismatch() {
        // Note: Current basic `==` allows comparing different types, returning false. 
        // This might need refinement based on desired coercion rules.
        assertEval(.infixOperation(operator: "==", left: .literal(.number(1)), right: .literal(.string("1"))), equals: .boolean(false))
        assertEval(.infixOperation(operator: "==", left: .literal(.number(1)), right: .literal(.boolean(true))), equals: .boolean(false))
    }
    
    func testEvaluate_NotEquals() {
        assertEval(.infixOperation(operator: "!=", left: .literal(.number(5)), right: .literal(.number(6))), equals: .boolean(true))
        assertEval(.infixOperation(operator: "!=", left: .literal(.string("a")), right: .literal(.string("a"))), equals: .boolean(false))
        assertEval(.infixOperation(operator: "!=", left: .literal(.number(1)), right: .literal(.string("1"))), equals: .boolean(true)) // Mismatched types are not equal
    }
    
    func testEvaluate_GreaterThan_Numbers() {
         assertEval(.infixOperation(operator: ">", left: .literal(.number(6)), right: .literal(.number(5))), equals: .boolean(true))
         assertEval(.infixOperation(operator: ">", left: .literal(.number(5)), right: .literal(.number(5))), equals: .boolean(false))
         assertEval(.infixOperation(operator: ">", left: .literal(.number(5)), right: .literal(.number(6))), equals: .boolean(false))
    }
    
     func testEvaluate_GreaterThan_Strings() {
          assertEval(.infixOperation(operator: ">", left: .literal(.string("b")), right: .literal(.string("a"))), equals: .boolean(true))
          assertEval(.infixOperation(operator: ">", left: .literal(.string("a")), right: .literal(.string("a"))), equals: .boolean(false))
          assertEval(.infixOperation(operator: ">", left: .literal(.string("a")), right: .literal(.string("b"))), equals: .boolean(false))
     }
     
     func testEvaluate_GreaterThan_TypeMismatch() {
          assertEvalFails(.infixOperation(operator: ">", left: .literal(.number(1)), right: .literal(.string("a"))))
     }
     
     // --- Tests for <, >=, <= --- 
     
     func testEvaluate_LessThan_Numbers() {
         assertEval(.infixOperation(operator: "<", left: .literal(.number(5)), right: .literal(.number(6))), equals: .boolean(true))
         assertEval(.infixOperation(operator: "<", left: .literal(.number(5)), right: .literal(.number(5))), equals: .boolean(false))
         assertEval(.infixOperation(operator: "<", left: .literal(.number(6)), right: .literal(.number(5))), equals: .boolean(false))
     }

     func testEvaluate_LessThan_Strings() {
         assertEval(.infixOperation(operator: "<", left: .literal(.string("a")), right: .literal(.string("b"))), equals: .boolean(true))
         assertEval(.infixOperation(operator: "<", left: .literal(.string("a")), right: .literal(.string("a"))), equals: .boolean(false))
         assertEval(.infixOperation(operator: "<", left: .literal(.string("b")), right: .literal(.string("a"))), equals: .boolean(false))
     }

     func testEvaluate_LessThan_TypeMismatch() {
         assertEvalFails(.infixOperation(operator: "<", left: .literal(.number(1)), right: .literal(.string("a"))))
     }
     
     func testEvaluate_GreaterEqual_Numbers() {
          assertEval(.infixOperation(operator: ">=", left: .literal(.number(6)), right: .literal(.number(5))), equals: .boolean(true))
          assertEval(.infixOperation(operator: ">=", left: .literal(.number(5)), right: .literal(.number(5))), equals: .boolean(true))
          assertEval(.infixOperation(operator: ">=", left: .literal(.number(5)), right: .literal(.number(6))), equals: .boolean(false))
     }
     
      func testEvaluate_GreaterEqual_Strings() {
           assertEval(.infixOperation(operator: ">=", left: .literal(.string("b")), right: .literal(.string("a"))), equals: .boolean(true))
           assertEval(.infixOperation(operator: ">=", left: .literal(.string("a")), right: .literal(.string("a"))), equals: .boolean(true))
           assertEval(.infixOperation(operator: ">=", left: .literal(.string("a")), right: .literal(.string("b"))), equals: .boolean(false))
      }
      
      func testEvaluate_GreaterEqual_TypeMismatch() {
           assertEvalFails(.infixOperation(operator: ">=", left: .literal(.number(1)), right: .literal(.string("a"))))
      }
      
      func testEvaluate_LessEqual_Numbers() {
           assertEval(.infixOperation(operator: "<=", left: .literal(.number(5)), right: .literal(.number(6))), equals: .boolean(true))
           assertEval(.infixOperation(operator: "<=", left: .literal(.number(5)), right: .literal(.number(5))), equals: .boolean(true))
           assertEval(.infixOperation(operator: "<=", left: .literal(.number(6)), right: .literal(.number(5))), equals: .boolean(false))
      }
      
       func testEvaluate_LessEqual_Strings() {
            assertEval(.infixOperation(operator: "<=", left: .literal(.string("a")), right: .literal(.string("b"))), equals: .boolean(true))
            assertEval(.infixOperation(operator: "<=", left: .literal(.string("a")), right: .literal(.string("a"))), equals: .boolean(true))
            assertEval(.infixOperation(operator: "<=", left: .literal(.string("b")), right: .literal(.string("a"))), equals: .boolean(false))
       }
       
       func testEvaluate_LessEqual_TypeMismatch() {
            assertEvalFails(.infixOperation(operator: "<=", left: .literal(.number(1)), right: .literal(.string("a"))))
       }
       
     // MARK: - Function Call Tests (Basic)
     
     func testEvaluate_FunctionNotFound() {
          assertEvalFails(.functionCall(name: "NOSUCHFUNCTION", arguments: []))
     }

    // Note: More complex function calls are tested in HigherOrderFunctionTests
    
    // MARK: - Stringify Helper Tests (Indirectly via +)
    
    func testEvaluate_StringifyViaConcat() {
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.boolean(true))), equals: .string("true"))
        // Dates require Foundation import in FormulaValue for Date() 
        // let date = Date(timeIntervalSinceReferenceDate: 0) // Jan 1, 2001
        // assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.date(date))), equals: .string(date.description))
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.array([.number(1)]))), equals: .string("[1]"))
        let err = FormulaError.divisionByZero
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.error(err))), equals: .string("#DIV/0!"))
    }

    func testEvaluate_ErrorStringFormatting() {
        // Test various error types are stringified correctly
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.error(.syntaxError("Bad char")))), equals: .string("#SYNTAX!(Bad char)"))
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.error(.invalidReference("foo")))), equals: .string("#REF!(foo)"))
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.error(.typeMismatch(expected: "Num", actual: "Str")))), equals: .string("#TYPE!(Num,Str)"))
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.error(.invalidArguments(function: "SUM", reason: "Needs numbers")))), equals: .string("#ARGS!(SUM:Needs numbers)"))
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.error(.circularReference("a>b>a")))), equals: .string("#CIRC!(a>b>a)"))
        assertEval(.infixOperation(operator: "+", left: .literal(.string("")), right: .literal(.error(.unknownError("Oops")))), equals: .string("#ERROR!(Oops)"))
    }
    
    // MARK: - Array Literal Tests
    
    func testEvaluate_ArrayLiteral_WithExpressions() {
        let context = DictionaryContext(["val": .number(10)])
        let node = ASTNode.arrayLiteral([
            .literal(.number(1)), 
            .infixOperation(operator: "+", left: .reference("val"), right: .literal(.number(5))),
            .literal(.string("end"))
        ])
        assertEval(node, context: context, equals: .array([.number(1), .number(15), .string("end")]))
    }
    
    func testEvaluate_ArrayLiteral_WithError() {
        let node = ASTNode.arrayLiteral([
            .literal(.number(1)), 
            .infixOperation(operator: "/", left: .literal(.number(1)), right: .literal(.number(0))) // Division by zero
        ])
        assertEvalFails(node)
    }
    
    func testEvaluate_ArrayLiteral_MultiSelectFormula() {
        // Test case for multiselect6:handleinvalidarray_formula
        // Expression: ["Yes", ] - array literal with trailing comma
        // Expected: Array containing single string "Yes"
        let node = ASTNode.arrayLiteral([
            .literal(.string("Yes"))
        ])
        assertEval(node, equals: .array([.string("Yes")]))
    }
    
    func testEvaluate_EndToEnd_MultiSelectFormulaWithParser() {
        // Integration test: Parse and evaluate multiselect6:handleinvalidarray_formula
        // Expression: ["Yes", ] - formula engine should handle trailing comma and return array value
        let parser = Parser()
        let formula = "[\"Yes\", ]"
        
        let parseResult = parser.parse(formula: formula)
        guard case .success(let ast) = parseResult else {
            XCTFail("Failed to parse formula: \(parseResult)")
            return
        }
        
        // Should parse as array literal
        guard case .arrayLiteral(let elements) = ast else {
            XCTFail("Expected arrayLiteral AST node, got: \(ast)")
            return
        }
        
        XCTAssertEqual(elements.count, 1, "Should have one element")
        XCTAssertEqual(elements[0], .literal(.string("Yes")))
        
        // Evaluate the parsed AST
        assertEval(ast, equals: .array([.string("Yes")]))
    }
    
    // MARK: - Comparison Operator Tests
    // ... tests for <, >=, <= ...
    
    func testEvaluate_UnsupportedOperator() {
        // Use an operator not in our known set (e.g., % if not added)
        let node = ASTNode.infixOperation(operator: "%", left: .literal(.number(5)), right: .literal(.number(3)))
        assertEvalFails(node) // Expecting unknownError or potentially a parser error earlier
    }
    
    func testEvaluate_PrefixOperator_NowImplemented() {
        // Renamed from testEvaluate_PrefixOperator_NotImplemented
        // Now tests that prefix operations work correctly
        let node = ASTNode.prefixOperation(operator: "-", operand: .literal(.number(5)))
        assertEval(node, equals: .number(-5))
        
        let node2 = ASTNode.prefixOperation(operator: "!", operand: .literal(.boolean(false)))
        assertEval(node2, equals: .boolean(true))
    }
    
    func testEvaluate_Equals_Dates() {
        let date1 = Date(timeIntervalSinceReferenceDate: 1000)
        let date2 = Date(timeIntervalSinceReferenceDate: 1000)
        let date3 = Date(timeIntervalSinceReferenceDate: 2000)
        assertEval(.infixOperation(operator: "==", left: .literal(.date(date1)), right: .literal(.date(date2))), equals: .boolean(true))
        assertEval(.infixOperation(operator: "==", left: .literal(.date(date1)), right: .literal(.date(date3))), equals: .boolean(false))
    }

    func testEvaluate_Equals_Arrays() {
        // Basic array equality (order and elements matter)
        let arr1 = FormulaValue.array([.number(1), .string("a")])
        let arr2 = FormulaValue.array([.number(1), .string("a")])
        let arr3 = FormulaValue.array([.string("a"), .number(1)]) // Different order
        let arr4 = FormulaValue.array([.number(1)]) // Different content
        assertEval(.infixOperation(operator: "==", left: .literal(arr1), right: .literal(arr2)), equals: .boolean(true))
        assertEval(.infixOperation(operator: "==", left: .literal(arr1), right: .literal(arr3)), equals: .boolean(false))
        assertEval(.infixOperation(operator: "==", left: .literal(arr1), right: .literal(arr4)), equals: .boolean(false))
    }
    
    func testEvaluate_Equals_Errors() {
        let err1 = FormulaError.divisionByZero
        let err2 = FormulaError.divisionByZero
        let err3 = FormulaError.syntaxError("test")
        assertEval(.infixOperation(operator: "==", left: .literal(.error(err1)), right: .literal(.error(err2))), equals: .boolean(true))
        assertEval(.infixOperation(operator: "==", left: .literal(.error(err1)), right: .literal(.error(err3))), equals: .boolean(false))
    }
    
    // MARK: - Unary Operation Tests
    
    func testEvaluate_UnaryMinus_Number() {
        let node = ASTNode.prefixOperation(operator: "-", operand: .literal(.number(10)))
        assertEval(node, equals: .number(-10))
        
        let node2 = ASTNode.prefixOperation(operator: "-", operand: .literal(.number(-5)))
        assertEval(node2, equals: .number(5))
    }
    
    func testEvaluate_UnaryMinus_TypeMismatch() {
        let node = ASTNode.prefixOperation(operator: "-", operand: .literal(.string("a")))
        assertEvalFails(node)
        
        let node2 = ASTNode.prefixOperation(operator: "-", operand: .literal(.boolean(true)))
        assertEvalFails(node2)
    }
    
    func testEvaluate_UnaryNot_Boolean() {
        let node = ASTNode.prefixOperation(operator: "!", operand: .literal(.boolean(true)))
        assertEval(node, equals: .boolean(false))
        
        let node2 = ASTNode.prefixOperation(operator: "!", operand: .literal(.boolean(false)))
        assertEval(node2, equals: .boolean(true))
    }
    
     func testEvaluate_UnaryNot_TypeMismatch() {
         let node = ASTNode.prefixOperation(operator: "!", operand: .literal(.number(1)))
         assertEvalFails(node)
         
         let node2 = ASTNode.prefixOperation(operator: "!", operand: .literal(.string("a")))
         assertEvalFails(node2)
     }
     
     func testEvaluate_MultipleUnary() {
          // AST for --5
          let node1 = ASTNode.prefixOperation(operator: "-", operand: .prefixOperation(operator: "-", operand: .literal(.number(5))))
          assertEval(node1, equals: .number(5))
          
          // AST for !!true
          let node2 = ASTNode.prefixOperation(operator: "!", operand: .prefixOperation(operator: "!", operand: .literal(.boolean(true))))
          assertEval(node2, equals: .boolean(true))
     }
     
     func testEvaluate_UnaryWithInfix() {
         // AST for -5 + 10
         let node1 = ASTNode.infixOperation(operator: "+", 
            left: .prefixOperation(operator: "-", operand: .literal(.number(5))),
            right: .literal(.number(10))
         )
         assertEval(node1, equals: .number(5))
         
         // AST for !(true && false)
         let node2 = ASTNode.prefixOperation(operator: "!", 
            operand: .infixOperation(operator: "&&",
                left: .literal(.boolean(true)),
                right: .literal(.boolean(false))
            )
         )
          assertEval(node2, equals: .boolean(true))
     }

    func testEvaluate_UnsupportedPrefixOperator() {
        let node = ASTNode.prefixOperation(operator: "+", operand: .literal(.number(5)))
        let result = evaluator.evaluate(node: node, context: emptyContext)
        guard case .failure(let error) = result else { XCTFail("Expected failure for unsupported prefix operator"); return }
        guard case .unknownError(let msg) = error else { XCTFail("Expected unknownError, got \(error)"); return }
        
        let expectedMsgContent = "Unsupported prefix operator: +"
        XCTAssertTrue(msg.contains(expectedMsgContent), "Expected message to contain '\(expectedMsgContent)', but got: '\(msg)'")
    }

} 
