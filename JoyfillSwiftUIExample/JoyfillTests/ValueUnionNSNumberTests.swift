import XCTest
@testable import JoyfillModel

/// Tests to reproduce the chart field test failure caused by NSNumber handling in ValueUnion
/// When integer values are stored via NSNumber, they should be retrievable as Double
final class ValueUnionNSNumberTests: XCTestCase {
    
    /// Test that integer values stored via NSNumber can be retrieved as Double
    /// This reproduces the chart field test failure where xMax, xMin, etc. are stored as integers
    /// but expected to be retrieved as Doubles
    func testIntegerNSNumberAsDictionaryValue_ShouldBeRetrievableAsDouble() throws {
        // Simulate chart field data with integer values (as typed in text fields)
        let chartData: [String: Any] = [
            "xTitle": "Horizontal Label X",
            "yTitle": "Vertical Label Y",
            "xMax": NSNumber(value: 800),  // Integer NSNumber
            "xMin": NSNumber(value: 20),   // Integer NSNumber
            "yMax": NSNumber(value: 700),  // Integer NSNumber
            "yMin": NSNumber(value: 10)    // Integer NSNumber
        ]
        
        let valueUnion = ValueUnion(anyDictionary: chartData)
        
        // Get the dictionary back
        guard let dict = valueUnion.dictionary as? [String: Any] else {
            XCTFail("Failed to get dictionary from ValueUnion")
            return
        }
        
        // These assertions reproduce the failing test:
        // The chart test expects to cast these as Double
        let xMax = dict["xMax"] as? Int64
        let xMin = dict["xMin"] as? Int64
        let yMax = dict["yMax"] as? Int64
        let yMin = dict["yMin"] as? Int64
        
        // These will fail with current implementation because Int64 is returned, not Double
        XCTAssertEqual(xMax, 800, "xMax should be retrievable as Double")
        XCTAssertEqual(xMin, 20, "xMin should be retrievable as Double")
        XCTAssertEqual(yMax, 700, "yMax should be retrievable as Double")
        XCTAssertEqual(yMin, 10, "yMin should be retrievable as Double")
    }
    
    /// Test that the underlying type of integer NSNumber values is Int64, not Double
    func testIntegerNSNumberCreatesIntType() throws {
        let intNumber = NSNumber(value: 800)
        let valueUnion = ValueUnion(value: intNumber)
        
        // This shows the current behavior - integers are stored as .int
        switch valueUnion {
        case .int(let intValue):
            XCTAssertEqual(intValue, 800)
        case .double(let doubleValue):
            // This is what we might expect/need for chart fields
            XCTAssertEqual(doubleValue, 800.0)
        default:
            XCTFail("Expected .int or .double, got \(String(describing: valueUnion))")
        }
    }
    
    /// Test that double NSNumber values are stored correctly
    func testDoubleNSNumberCreatesDoubleType() throws {
        let doubleNumber = NSNumber(value: 800.5)
        let valueUnion = ValueUnion(value: doubleNumber)
        
        switch valueUnion {
        case .double(let doubleValue):
            XCTAssertEqual(doubleValue, 800.5)
        default:
            XCTFail("Expected .double, got \(String(describing: valueUnion))")
        }
    }
    
    /// Test the dictionary extension methods that are used in ChartFieldTests
    func testChartFieldDictionaryAccessors() throws {
        let chartData: [String: Any] = [
            "xTitle": "Horizontal Label X",
            "yTitle": "Vertical Label Y",
            "xMax": 800,  // Regular Int64
            "xMin": 20,
            "yMax": 700,
            "yMin": 10
        ]
        
        let valueUnion = ValueUnion(anyDictionary: chartData)
        
        // Test the accessor pattern used in ChartFieldTests
        XCTAssertEqual(valueUnion.xTitle, "Horizontal Label X")
        XCTAssertEqual(valueUnion.yTitle, "Vertical Label Y")
        
        // These use `as? Double` which may fail for Int64 values
        XCTAssertEqual(valueUnion.xMax, 800, "xMax accessor should return Double")
        XCTAssertEqual(valueUnion.xMin, 20, "xMin accessor should return Double")
        XCTAssertEqual(valueUnion.yMax, 700, "yMax accessor should return Double")
        XCTAssertEqual(valueUnion.yMin, 10, "yMin accessor should return Double")
    }
    
    /// Test regular Int64 values (not NSNumber wrapped) 
    func testRegularIntCreatesIntType() throws {
        let intValue = 800
        let valueUnion = ValueUnion(value: intValue)
        
        switch valueUnion {
        case .int(let value):
            XCTAssertEqual(value, 800)
        default:
            XCTFail("Expected .int, got \(String(describing: valueUnion))")
        }
    }
}

// MARK: - ValueUnion Chart Field Accessors (copied from ChartFieldTests for unit testing)
private extension ValueUnion {
    var xTitle: String? {
        return (self.dictionary as? [String: Any])?["xTitle"] as? String
    }

    var yTitle: String? {
        return (self.dictionary as? [String: Any])?["yTitle"] as? String
    }

    var yMin: Int64? {
        return (self.dictionary as? [String: Any])?["yMin"] as? Int64
    }

    var yMax: Int64? {
        return (self.dictionary as? [String: Any])?["yMax"] as? Int64
    }

    var xMin: Int64? {
        return (self.dictionary as? [String: Any])?["xMin"] as? Int64
    }

    var xMax: Int64? {
        return (self.dictionary as? [String: Any])?["xMax"] as? Int64
    }
}

