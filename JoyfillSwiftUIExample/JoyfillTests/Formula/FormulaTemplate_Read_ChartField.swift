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
        documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
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
        print("Formula: some(flatMap(chart1, (line) -> line.points), (pt) -> pt.y > 50)")
        print("Expected: true (Line 2 has points with y=60 and y=40 which are > 50)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        // Should return "true" since multiple points have y > 50 (y=60, y=40)
        XCTAssertEqual(resultText, "true", "Should detect y values > 50 across all chart points")
    }
    
    private func testGetLineTitle() {
        print("\n📝 Test 2: Concatenate Line Titles")
        print("Formula: concat(map(chart1, (line) -> line.title))")
        print("Expected: 'Line 1 TitleLine 2 Title' (concatenated titles)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "Line 1 TitleLine 2 Title", "Should concatenate all line titles")
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
        print("\n📈 Test 4: Average Points Per Line")
        print("Formula: sum(map(chart1, (line) -> length(line.points))) / length(chart1)")
        print("Expected: 3.0 (average: (3+3)/2 = 3)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number2")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 3.0, "Should return average number of points per line")
    }
}
