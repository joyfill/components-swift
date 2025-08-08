import XCTest
@testable import JoyfillFormulas // Use @testable to access internal types if needed

final class HigherOrderFunctionTests: XCTestCase {

    var evaluator: Evaluator!
    var emptyContext: EvaluationContext!
    var parser: Parser!

    override func setUp() {
        super.setUp()
        // Set up a fresh evaluator and context for each test
        evaluator = Evaluator() // Uses default FunctionRegistry which now includes map
        emptyContext = DictionaryContext() // Empty context for most tests
        parser = Parser()
    }

    override func tearDown() {
        evaluator = nil
        emptyContext = nil
        parser = nil
        super.tearDown()
    }

    // Helper to create a map function call AST
    private func createMapAST(arrayNode: ASTNode, variableName: String, expressionNode: ASTNode) -> ASTNode {
        return .functionCall(name: "map", arguments: [
            arrayNode,
            .literal(.string(variableName)),
            expressionNode
        ])
    }

    // Helper to run parse & eval
    private func evaluateFormula(_ formula: String, context: EvaluationContext? = nil) -> Result<FormulaValue, FormulaError> {
        let parseResult = parser.parse(formula: formula)
        switch parseResult {
        case .success(let ast):
            // print("AST: \(ast)") // Uncomment for debugging AST
            return evaluator.evaluate(node: ast, context: context ?? emptyContext)
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - MAP Tests (Lambda Expression Syntax)

    func testMap_parseAndEvaluate_simpleAddition_camelCase() throws {
        let formula = "map([10, 20, 30], (item) → item + 5)"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(15), .number(25), .number(35)])
        XCTAssertEqual(try result.get(), expectedValue)
    }

    func testMap_parseAndEvaluate_simpleAddition_upperCase() throws {
        let formula = "MAP([10, 20, 30], (item) → item + 5)"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(15), .number(25), .number(35)])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testMap_parseAndEvaluate_nestedMap() throws {
        let formula = "map([1, 2], (outer) → map([10, 20], (inner) → outer + inner))"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([
            .array([.number(11), .number(21)]),
            .array([.number(12), .number(22)])
        ])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testMap_emptyArray() throws {
        let formula = "map([], (x) → x)"
        let result = evaluateFormula(formula)
        XCTAssertEqual(try result.get(), .array([]))
    }
    
    func testMap_firstArgNotArray() throws {
         let formula = "map(\"not an array\", (x) → x)"
         let result = evaluateFormula(formula)
         guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
         guard case .typeMismatch = error else { XCTFail("Expected typeMismatch, got \(error)"); return }
         XCTAssert(true)
    }
    
    func testMap_secondArgNotStringLiteral() throws {
         let formula = "map([1], 123)" // Wrong argument type
         let result = evaluateFormula(formula)
         guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
         guard case .typeMismatch = error else { XCTFail("Expected typeMismatch, got \(error)"); return }
         XCTAssert(true)
    }
    
    func testMap_wrongArgumentCount() throws {
         let formula = "map([1, 2])" // Missing args
         let result = evaluateFormula(formula)
         guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
         guard case .invalidArguments = error else { XCTFail("Expected invalidArguments, got \(error)"); return }
         XCTAssert(true)
    }
    
    func testMap_simpleNumberArray_addOne() throws {
        let formula = "map([1, 2, 3], (x) → x + 1)"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(2), .number(3), .number(4)])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testMap_ExpressionError() {
        // Expression tries to add number and boolean
        let formula = "MAP([1, 2], (x) → x + true)"
        let result = evaluateFormula(formula)
        guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
        // Expecting a typeMismatch from the expression evaluation
        guard case .typeMismatch = error else { XCTFail("Expected typeMismatch, got \(error)"); return }
        XCTAssert(true)
    }
    
    // MARK: - FILTER Tests (Lambda Expression Syntax)
    
    func testFilter_parseAndEvaluate_numbersGreaterThan() throws {
        let formula = "filter([5, 15, 3, 25, 10], (num) → num > 10)"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(15), .number(25)])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testFilter_parseAndEvaluate_stringsEqual() throws {
        let formula = "filter([\"apple\", \"banana\", \"apricot\", \"avocado\"], (fruit) → fruit == \"apple\")"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.string("apple")])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testFilter_emptyArray() throws {
        let formula = "filter([], (x) → x > 5)"
        let result = evaluateFormula(formula)
        XCTAssertEqual(try result.get(), .array([]))
    }
    
    func testFilter_predicateError() throws {
        // Expression itself causes a type mismatch error
        let formula = "filter([1, 2], (x) → x + \"a\")"
        let result = evaluateFormula(formula)
        guard case .failure(_) = result else { XCTFail("Expected failure"); return }
        XCTAssert(true) // Error type might vary, just check failure
    }
    
    func testFilter_predicateNotBoolean() throws {
        // Expression evaluates, but not to a boolean
        let formula = "filter([1, 2], (x) → x + 1)"
        let result = evaluateFormula(formula)
        guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
        guard case .typeMismatch = error else { XCTFail("Expected typeMismatch, got \(error)"); return }
        XCTAssert(true)
    }

    // MARK: - SORT Tests

    func testSort_parseAndEvaluate_numbersAscending() throws {
        let formula = "sort([5, 1, 4, 2, 3])"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(1), .number(2), .number(3), .number(4), .number(5)])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testSort_parseAndEvaluate_numbersDescending() throws {
        let formula = "sort([5, 1, 4, 2, 3], false)"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(5), .number(4), .number(3), .number(2), .number(1)])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testSort_parseAndEvaluate_stringsAscending() throws {
        let formula = "sort([\"c\", \"a\", \"b\"])"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.string("a"), .string("b"), .string("c")])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testSort_parseAndEvaluate_emptyArray() throws {
        let formula = "sort([])"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testSort_parseAndEvaluate_mixedTypesError() throws {
        let formula = "sort([1, \"a\", 2])"
        let result = evaluateFormula(formula)
        guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
        guard case .typeMismatch = error else { XCTFail("Expected typeMismatch, got \(error)"); return }
        XCTAssert(true)
    }
    
    func testSort_parseAndEvaluate_wrongAscendingType() throws {
        let formula = "sort([1, 2], \"true\")"
        let result = evaluateFormula(formula)
        guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
        guard case .typeMismatch = error else { XCTFail("Expected typeMismatch, got \(error)"); return }
        XCTAssert(true)
    }

    func testSort_parseAndEvaluate_singleElement() throws {
        let formula = "sort([42])"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(42)])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testSort_parseAndEvaluate_duplicateElements() throws {
        let formula = "sort([3, 1, 4, 1, 5, 9, 2, 6, 5])"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(1), .number(1), .number(2), .number(3), .number(4), .number(5), .number(5), .number(6), .number(9)])
        XCTAssertEqual(try result.get(), expectedValue)
        
        let formulaDesc = "sort([\"b\", \"a\", \"c\", \"a\", \"b\"], false)"
        let resultDesc = evaluateFormula(formulaDesc)
        let expectedValueDesc = FormulaValue.array([.string("c"), .string("b"), .string("b"), .string("a"), .string("a")])
        XCTAssertEqual(try resultDesc.get(), expectedValueDesc)
    }

    // MARK: - FLATMAP Tests

    func testFlatMap_parseAndEvaluate_simpleReplication() throws {
        let formula = "flatMap([1, 2], (x) → [x, x * 2])"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([
            .number(1), .number(2),
            .number(2), .number(4)
        ])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testFlatMap_parseAndEvaluate_nestedArrays() throws {
        let formula = "flatMap([[1, 2], [3, 4]], (arr) → arr)"
        let result = evaluateFormula(formula)
        let expectedValue = FormulaValue.array([.number(1), .number(2), .number(3), .number(4)])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testFlatMap_parseAndEvaluate_emptyInputArray() throws {
        let formula = "flatMap([], (x) → [x])"
        let result = evaluateFormula(formula)
        XCTAssertEqual(try result.get(), .array([]))
    }
    
    func testFlatMap_parseAndEvaluate_expressionReturnsEmptyArray() throws {
        let formula = "flatMap([1, 2], (x) → [])"
        let result = evaluateFormula(formula)
        XCTAssertEqual(try result.get(), .array([]))
    }
    
    func testFlatMap_parseAndEvaluate_expressionReturningNonArray_autoWraps() throws {
        // FLATMAP auto-wraps single values into arrays - this is helpful behavior
        let formula = "flatMap([1, 2], (x) → x + 1)"
        let result = evaluateFormula(formula)
        // Should auto-wrap single values: [1,2] → [(1+1), (2+1)] → [[2], [3]] → [2, 3]
        let expectedValue = FormulaValue.array([.number(2), .number(3)])
        XCTAssertEqual(try result.get(), expectedValue)
    }
    
    func testFlatMap_ExpressionError() throws {
        // Expression fails during evaluation for one of the items
        let formula = "flatMap([1, 0, 2], (x) → [10 / x])" // Division by zero on second item
        let result = evaluateFormula(formula)
        guard case .failure(let error) = result else { XCTFail("Expected failure"); return }
        // Expecting an unknownError wrapping the divisionByZero from the inner evaluation
        guard case .unknownError = error else { XCTFail("Expected unknownError wrapping a divisionByZero, got \(error)"); return }
        XCTAssert(true)
    }
}
