import XCTest
@testable import JoyfillExample
import JoyfillModel
import JoyfillFormulas
import Joyfill

class SimpleTableTest: XCTestCase {
    
    func testBasicTableCellResolution() {
        // Create a simple document with table cell resolution
        let document = JoyDoc.createTableCellResolutionDocument()
        let documentEditor = DocumentEditor(document: document, shouldValidate: false)
        
        // Test basic functionality
        print("Testing basic table cell resolution...")
        
        // Test row count
        let rowCount = documentEditor.value(ofFieldWithIdentifier: "rowCount")?.number
        print("Row count: \(rowCount ?? -1)")
        XCTAssertEqual(rowCount, 3, "Should have 3 rows")
        
        // Test first product name
        let firstName = documentEditor.value(ofFieldWithIdentifier: "firstProductName")?.text
        print("First product name: \(firstName ?? "nil")")
        XCTAssertEqual(firstName, "Laptop", "First product should be Laptop")
        
        // Test first product price
        let firstPrice = documentEditor.value(ofFieldWithIdentifier: "firstProductPrice")?.number
        print("First product price: \(firstPrice ?? -1)")
        XCTAssertEqual(firstPrice, 999.99, "First product price should be 999.99")
        
        // Test total price calculation
        let totalPrice = documentEditor.value(ofFieldWithIdentifier: "totalPriceResult")?.number
        print("Total price: \(totalPrice ?? -1)")
        XCTAssertEqual(totalPrice!, 1105.48, accuracy: 0.01, "Total price should be 1105.48")

        print("✅ Basic table cell resolution test passed!")
    }
}
 
