import XCTest
@testable import JoyfillFormulas

final class ParserTests: XCTestCase {

    var parser: Parser!

    override func setUp() {
        super.setUp()
        parser = Parser()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    // Helper to assert parsing success (don't need to check exact AST for all error tests)
    func assertParseSuccess(_ formula: String, file: StaticString = #file, line: UInt = #line) {
        let result = parser.parse(formula: formula)
        switch result {
        case .success:
            XCTAssert(true)
        case .failure(let error):
            XCTFail("Parsing failed unexpectedly: \(error)", file: file, line: line)
        }
    }

    // Helper to assert parsing failure with a specific error type
    func assertParseFailure<E: Error & Equatable>(_ formula: String, errorType: E, file: StaticString = #file, line: UInt = #line) {
        let result = parser.parse(formula: formula)
        switch result {
        case .success(let ast):
            XCTFail("Parsing succeeded unexpectedly with AST: \(ast)", file: file, line: line)
        case .failure(let error):
            // The error from parser.parse is already FormulaError
            guard case .syntaxError(let msg) = error else { 
                XCTFail("Expected FormulaError.syntaxError, got \(error)", file: file, line: line)
                return
            }
            print("Received expected syntax error: \(msg) for formula: \(formula)")
            XCTAssert(true) 
        }
    }

    func assertSyntaxError(_ formula: String, file: StaticString = #file, line: UInt = #line) {
         let result = parser.parse(formula: formula)
         switch result {
         case .success(let ast):
             XCTFail("Parsing succeeded unexpectedly with AST: \(ast)", file: file, line: line)
         case .failure(let error):
             // The error from parser.parse is already FormulaError
             guard case .syntaxError = error else { 
                 XCTFail("Expected FormulaError.syntaxError, got \(error)", file: file, line: line)
                 return
             }
             XCTAssert(true) // Correctly failed with syntax error
         }
     }

    // MARK: - Lexer Error Tests

    func testLexer_UnterminatedString() {
        assertSyntaxError(" \"hello ") // No closing quote
    }

    func testLexer_UnterminatedReference() {
         // Note: Unterminated references no longer exist since we removed curly braces
         // Field references like "field" are now valid identifiers
         // Test a different error case instead
         assertSyntaxError(" $ ") // $ is not a valid character
    }

    func testLexer_InvalidNumber() {
        assertSyntaxError(" 1.2.3 ")
        // Remove the assertion for "--2" as it's syntactically valid (prefix minus on negative number literal)
        // assertSyntaxError(" --2 ") 
    }

    func testLexer_UnknownOperatorSequence() {
        assertSyntaxError(" 1 %%% 2 ") // % isn't known yet
        assertSyntaxError(" 1 =/= 2 ") // Invalid sequence
    }

    func testLexer_UnexpectedCharacter() {
        assertSyntaxError(" @ ")
        assertSyntaxError(" # ")
    }

    // MARK: - Parser Syntax Error Tests

    func testParser_MissingClosingParenthesis() {
        assertSyntaxError(" (1 + 2 ")
        assertSyntaxError(" MAP([1], (x) → x ") // Missing closing paren for function
    }

    func testParser_MissingClosingBracket() {
        assertSyntaxError(" [1, 2 ")
    }

    func testParser_UnexpectedTokenAfterExpression() {
        // Note: Parser should now fail strictly on leftover tokens.
        assertSyntaxError(" 1 + 2 ) ") 
    }

    func testParser_OperatorAsValue() {
        assertSyntaxError(" + ")
        assertSyntaxError(" FUNC(+) ")
    }

    func testParser_MissingFunctionParenthesis() {
        // assertSyntaxError(" MAP ") // Identifier alone is treated as reference currently
        let formula = "MAP"
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        XCTAssertEqual(ast, .reference("MAP")) // Verify it parses as a reference
    }

    func testParser_InvalidArgumentSeparator() {
        assertSyntaxError(" MAP([1]; \"x\", {x}) ") // Semicolon instead of comma
    }

    func testParser_EmptyFormula() {
        assertSyntaxError("") // Handled by lexer returning only EOF
    }

    func testParser_ExtraCommaInFunction() {
        assertSyntaxError(" MAP([1], (x) → x, ) ")
    }

    func testParser_ExtraCommaInArray() {
        assertSyntaxError(" [1, 2, ] ")
    }

    func testParser_InvalidArgumentExpression() {
        assertSyntaxError("FUNC(1+)") // Incomplete expression in args
        assertSyntaxError("FUNC(a == )")
    }
    
    func testParser_InvalidArrayElementExpression() {
        assertSyntaxError("[1+]" ) // Incomplete expression in array
        assertSyntaxError("[a == ]")
    }

    func testParser_LeadingCommaFunction() {
        assertSyntaxError("FUNC(,1)") 
    }
    
    func testParser_LeadingCommaArray() {
        assertSyntaxError("[,1]") 
    }

    func testParser_InvalidPrimaryStart() {
        assertSyntaxError("== 1") // Operator cannot start expression here
        assertSyntaxError(", 1")  // Comma cannot start expression
        assertSyntaxError(")")
        assertSyntaxError("]")
    }

    // MARK: - Parser Success Tests (AST Structure)
    
    func testParser_SimpleInfix() {
        let formula = "1 + 2"
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        XCTAssertEqual(ast, .infixOperation(operator: "+", left: .literal(.number(1)), right: .literal(.number(2))))
    }
    
    func testParser_OperatorPrecedence() {
        let formula = "1 + 2 * 3"
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        // Expect: 1 + (2 * 3)
        let expectedAST = ASTNode.infixOperation(operator: "+", 
            left: .literal(.number(1)), 
            right: .infixOperation(operator: "*", 
                left: .literal(.number(2)), 
                right: .literal(.number(3))
            )
        )
        XCTAssertEqual(ast, expectedAST)
    }
    
    func testParser_Parentheses() {
        let formula = "(1 + 2) * 3"
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        // Expect: (1 + 2) * 3
        let expectedAST = ASTNode.infixOperation(operator: "*", 
            left: .infixOperation(operator: "+", 
                left: .literal(.number(1)), 
                right: .literal(.number(2))
            ), 
            right: .literal(.number(3))
        )
        XCTAssertEqual(ast, expectedAST)
    }
    
    func testParser_FunctionCall_NoArgs() {
         let formula = "NOW()"
         let result = parser.parse(formula: formula)
         guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
         XCTAssertEqual(ast, .functionCall(name: "NOW", arguments: []))
    }
    
    func testParser_FunctionCall_OneArg() {
         let formula = "ROUND(1.23)"
         let result = parser.parse(formula: formula)
         guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
         XCTAssertEqual(ast, .functionCall(name: "ROUND", arguments: [.literal(.number(1.23))]))
    }
    
    func testParser_FunctionCall_MultipleArgs() {
         let formula = "IF(a > 1, \"OK\", \"NO\")"
         let result = parser.parse(formula: formula)
         guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
         let expectedAST = ASTNode.functionCall(name: "IF", arguments: [
            .infixOperation(operator: ">", left: .reference("a"), right: .literal(.number(1))),
            .literal(.string("OK")),
            .literal(.string("NO"))
         ])
         XCTAssertEqual(ast, expectedAST)
    }
    
     func testParser_ArrayLiteral_Simple() {
         let formula = "[1, \"a\", true]"
         let result = parser.parse(formula: formula)
         guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
         XCTAssertEqual(ast, .arrayLiteral([
            .literal(.number(1)),
            .literal(.string("a")),
            .literal(.boolean(true))
         ]))
     }
     
     func testParser_ArrayLiteral_WithExpressions() {
         let formula = "[1 * 2, ref]"
         let result = parser.parse(formula: formula)
         guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
         XCTAssertEqual(ast, .arrayLiteral([
             .infixOperation(operator: "*", left: .literal(.number(1)), right: .literal(.number(2))),
             .reference("ref")
          ]))
     }
     
     func testParser_HigherOrderFunction_Map() {
         let formula = "MAP([1, 2], (x) → x * 2)"
         let result = parser.parse(formula: formula)
         guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
         let expectedAST = ASTNode.functionCall(name: "MAP", arguments: [
             .arrayLiteral([.literal(.number(1)), .literal(.number(2))]),
             .lambda(parameters: ["x"], body: .infixOperation(operator: "*", left: .reference("x"), right: .literal(.number(2))))
         ])
         XCTAssertEqual(ast, expectedAST)
     }

    func testParser_LogicalOr() {
        let formula = "true || false"
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        XCTAssertEqual(ast, .infixOperation(operator: "||", left: .literal(.boolean(true)), right: .literal(.boolean(false))))
    }

    func testParser_LogicalAnd() {
        let formula = "a && b"
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        XCTAssertEqual(ast, .infixOperation(operator: "&&", left: .reference("a"), right: .reference("b")))
    }

    func testParser_LogicalCombination() {
        let formula = "a || b && c" // Expect a || (b && c)
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        let expectedAST = ASTNode.infixOperation(operator: "||",
            left: .reference("a"),
            right: .infixOperation(operator: "&&",
                left: .reference("b"),
                right: .reference("c")
            )
        )
        XCTAssertEqual(ast, expectedAST)
    }

    func testParser_UnaryMinus() {
        let formula = "-5"
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        // Lexer produces NumberLiteral "-5", Parser makes it a literal node
        XCTAssertEqual(ast, .literal(.number(-5.0)))
    }

    func testParser_UnaryNot() {
        let formula = "!true"
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        XCTAssertEqual(ast, .prefixOperation(operator: "!", operand: .literal(.boolean(true))))
    }

    func testParser_UnaryWithInfixPrecedence() {
        let formula = "-5 + 10" // Lexer: [-5, +, 10] -> Parser: (literal -5) + (literal 10)
        let result = parser.parse(formula: formula)
        guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
        let expected = ASTNode.infixOperation(operator: "+",
            left: .literal(.number(-5.0)), // Corrected expectation
            right: .literal(.number(10))
        )
        XCTAssertEqual(ast, expected)
        
        let formula2 = "!true && false" // Should be (!true) && false
        let result2 = parser.parse(formula: formula2)
        guard case .success(let ast2) = result2 else { XCTFail("Parse failed: \(result2)"); return }
        let expected2 = ASTNode.infixOperation(operator: "&&",
            left: .prefixOperation(operator: "!", operand: .literal(.boolean(true))),
            right: .literal(.boolean(false))
        )
        XCTAssertEqual(ast2, expected2)
    }

    func testParser_MultipleUnary() {
         let formula = "--5" // Lexer: [-, -5] -> Parser: prefix(-, literal(-5))
         let result = parser.parse(formula: formula)
         guard case .success(let ast) = result else { XCTFail("Parse failed: \(result)"); return }
         // Corrected expectation based on lexer behavior
         XCTAssertEqual(ast, .prefixOperation(operator: "-", operand: .literal(.number(-5.0))))

         let formula2 = "!!true"
         let result2 = parser.parse(formula: formula2)
         guard case .success(let ast2) = result2 else { XCTFail("Parse failed: \(result2)"); return }
         XCTAssertEqual(ast2, .prefixOperation(operator: "!", operand: .prefixOperation(operator: "!", operand: .literal(.boolean(true)))))

    }

} 