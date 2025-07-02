//
//  FormulaTemplate_CollectionField.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_Read_ChartFieldTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_Read_ChartField")
        documentEditor = DocumentEditor(document: document)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Chart Field Formula Tests
    
    func testChartFieldFormulas() {
        print("\n🧪 === Chart Field Formula Tests ===")
        
        // Debug: Print chart field structure
        if let chartField = documentEditor.field(fieldID: "chart1") {
            print("📊 Chart field found")
            
            // Chart fields store data directly in the 'value' field as JSON array
            if let value = chartField.value {
                switch value {
                case .array(let chartLines):
                    print("📊 Chart field found with \(chartLines.count) lines")
                    
                    for (lineIndex, lineValue) in chartLines.enumerated() {
                        print("  📈 Line \(lineIndex): \(lineValue)")
                    }
                case .string(let str):
                    print("📊 Chart field value is string: \(str)")
                    // Try to parse as JSON
                    if let data = str.data(using: .utf8) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            print("📊 Parsed JSON: \(json)")
                        } catch {
                            print("📊 Failed to parse JSON: \(error)")
                        }
                    }
                default:
                    print("📊 Chart field value type: \(value)")
                }
            }
        } else {
            print("❌ Chart field not found")
        }
        
        testAnyYOver50()
        testGetLineTitle()
        testFirstPointYLine2()
        testArithmeticWithChart()
    }
    
    private func testAnyYOver50() {
        print("\n🔍 Test 1: Any Y > 50?")
        print("Formula: chart1.1.points.1.y > 50")
        print("Expected: true (Line 2, Point 1 has y=60)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        // Should return "true" since point 3 of line 1 has y=60 which is > 50
        XCTAssertEqual(resultText, "true", "Should detect y value > 50")
    }
    
    private func testGetLineTitle() {
        print("\n📝 Test 2: Get Line Title")
        print("Formula: chart1.0.title")
        print("Expected: 'Line 1 Title'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "Line 1 Title", "Should get first line title")
    }
    
    private func testFirstPointYLine2() {
        print("\n📊 Test 3: Y of First Point (Line 2)")
        print("Formula: chart1.1.points.0.y")
        print("Expected: 10")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number1")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 10, "Should return y value of first point in second line")
    }
    
    private func testArithmeticWithChart() {
        print("\n📈 Test 4: Arithmetic with Chart Data")
        print("Formula: chart1.0.points.2.y + chart1.1.points.0.y")
        print("Expected: 40.0 (30 + 10)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number2")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 40.0, "Should return sum of chart values")
    }
}
