import XCTest
@testable import JoyfillFormulas // Ensure this import exists

class FunctionRegistryTests: XCTestCase {

    var registry: FunctionRegistry!

    override func setUp() {
        super.setUp()
        registry = FunctionRegistry()
    }

    override func tearDown() {
        registry = nil
        super.tearDown()
    }

    // Test registering and looking up a simple function
    func testRegisterAndLookup() {
        let dummyFunction: FormulaFunction = { _, _, _ in .success(.number(1)) }
        registry.register(name: "DUMMY", function: dummyFunction)
        let lookedUp = registry.lookup(name: "DUMMY")
        XCTAssertNotNil(lookedUp, "Lookup should return the registered function")
        // We can't directly compare closures for equality in Swift,
        // so invoking is the best way to check indirectly if possible,
        // or just check for nil/non-nil.
    }

    // Test lookup of a non-existent function
    func testLookup_NotFound() {
        XCTAssertNil(registry.lookup(name: "nonExistentFunction"), "Lookup for non-existent function should return nil")
    }

    // Test case-insensitivity of function names
    func testRegister_CaseSensitivity() {
        let dummyFunction: FormulaFunction = { _, _, _ in .success(.boolean(true)) }
        registry.register(name: "TeStCaSe", function: dummyFunction)
        
        // Lookup should work regardless of case
        XCTAssertNotNil(registry.lookup(name: "TESTCASE"), "Lookup should be case-insensitive")
        XCTAssertNotNil(registry.lookup(name: "testcase"), "Lookup should be case-insensitive")
        XCTAssertNotNil(registry.lookup(name: "TeStCaSe"), "Lookup should be case-insensitive")
    }

    // Test that registering a function with an existing name overwrites the old one
    func testRegister_ConflictOverwrite() {
        let function1: FormulaFunction = { _, _, _ in .success(.string("Version 1")) }
        let function2: FormulaFunction = { _, _, _ in .success(.string("Version 2")) }
        
        registry.register(name: "CONFLICT", function: function1)
        // Verify first registration
        let lookup1 = registry.lookup(name: "CONFLICT")
        XCTAssertNotNil(lookup1, "Function should be registered")

        // Re-register with the same name (case-insensitive)
        registry.register(name: "conflict", function: function2)
        
        // Verify the second registration overwrote the first
        let lookup2 = registry.lookup(name: "CONFLICT")
        XCTAssertNotNil(lookup2, "Function should still be registered after overwrite")
        
        // Invoke to confirm it's the second function
        let evalResult = lookup2?([], DictionaryContext(), Evaluator())
        XCTAssertEqual(try? evalResult?.get(), .string("Version 2"), "Second registration should overwrite the first")
    }
    
    // Removed duplicate/incorrect testLookup_NotFound stub from faulty edit
} 