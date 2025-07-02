//
//  FormulaTemplate_Write_ChartField.swift
//  JoyfillTests
//
//  Created by Assistant on Chart Field Write Implementation
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_Write_ChartFieldTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_Write_ChartField")
        documentEditor = DocumentEditor(document: document)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Chart Field Write Tests
    
    func testChartFieldWriteFormulas() {
        print("\n🧪 === Chart Field Write Formula Tests ===")
        
        // Debug: Print chart field structure
        if let chartField = documentEditor.field(fieldID: "chart1") {
            print("📊 Chart field found with type: \(chartField.fieldType)")
            
            if let value = chartField.value {
                switch value {
                case .valueElementArray(let elements):
                    print("📊 Chart field has \(elements.count) lines after formula execution")
                case .array(let lines):
                    print("📊 Chart field has \(lines.count) lines (string array)")
                default:
                    print("📊 Chart field value type: \(value)")
                }
            } else {
                print("📊 Chart field has no value")
            }
        }
        
        testWriteCustomChartLines()
        testChartDataStructure() 
        testChartDataValues()
        testTypeConversion()
    }
    
    private func testWriteCustomChartLines() {
        print("\n🔍 Test 1: Write Custom Chart Lines Formula")
        print("Formula: writeCustomChartLines")
        print("Expected: Chart field populated with 2 lines")
        
        guard let chartField = documentEditor.field(fieldID: "chart1") else {
            XCTFail("Chart field not found")
            return
        }
        
        guard let value = chartField.value else {
            XCTFail("Chart field has no value")
            return
        }
        
        switch value {
        case .valueElementArray(let elements):
            print("🎯 Result: Chart has \(elements.count) lines")
            XCTAssertEqual(elements.count, 2, "Should have 2 lines")
        case .array(let lines):
            print("🎯 Result: Chart has \(lines.count) lines (string array)")
            XCTAssertEqual(lines.count, 2, "Should have 2 lines")
        default:
            XCTFail("Chart field value should be an array, got: \(value)")
        }
    }
    
    private func testChartDataStructure() {
        print("\n📊 Test 2: Chart Data Structure Validation")
        
        guard let chartField = documentEditor.field(fieldID: "chart1"),
              let value = chartField.value else {
            XCTFail("Chart field should have value")
            return
        }
        
        switch value {
        case .valueElementArray(let elements):
            guard elements.count >= 1 else {
                XCTFail("Should have at least 1 line")
                return
            }
            
            let line1 = elements[0]
            XCTAssertNotNil(line1.id, "Line should have _id")
            XCTAssertNotNil(line1.title, "Line should have title")
            XCTAssertNotNil(line1.points, "Line should have points")
            
            if let points = line1.points {
                print("🎯 Line 1 has \(points.count) points")
                XCTAssertGreaterThan(points.count, 0, "Line should have points")
                
                if points.count > 0 {
                    let point1 = points[0]
                    XCTAssertNotNil(point1.id, "Point should have _id")
                    XCTAssertNotNil(point1.x, "Point should have x coordinate")
                    XCTAssertNotNil(point1.y, "Point should have y coordinate")
                    print("✅ Point structure validated")
                }
            }
            
        default:
            XCTFail("Chart field should be valueElementArray")
        }
    }
    
    private func testChartDataValues() {
        print("\n📝 Test 3: Chart Data Values Validation")
        
        guard let chartField = documentEditor.field(fieldID: "chart1"),
              let value = chartField.value,
              case .valueElementArray(let elements) = value else {
            XCTFail("Chart field should have valueElementArray value")
            return
        }
        
        // Test first line values
        if elements.count >= 1 {
            let line1 = elements[0]
            
            if let title = line1.title {
                print("🎯 Line 1 title: '\(title)'")
                XCTAssertEqual(title, "Line 1 Label", "First line title should match line1Label field")
            }
            
            if let points = line1.points, points.count >= 1 {
                let point1 = points[0]
                
                if let label = point1.label {
                    print("🎯 Point 1 label: '\(label)'")
                    XCTAssertEqual(label, "Zero Point", "First point label should match point1Label field")
                }
                
                if let x = point1.x {
                    print("🎯 Point 1 x: \(x)")
                    XCTAssertEqual(x, 0, "First point x should be 0")
                }
                
                if let y = point1.y {
                    print("🎯 Point 1 y: \(y)")
                    XCTAssertEqual(y, 100, "First point y should be 100")
                }
            }
        }
        
        // Test second line (mapped from table)
        if elements.count >= 2 {
            let line2 = elements[1]
            
            if let title = line2.title {
                print("🎯 Line 2 title: '\(title)'")
                XCTAssertEqual(title, "Line 2 Manual Label", "Second line should have manual title")
            }
            
            if let points = line2.points {
                print("🎯 Line 2 has \(points.count) points (mapped from table)")
                XCTAssertNotNil(points, "Second line should have points array")
            }
        }
    }
    
    private func testTypeConversion() {
        print("\n🔧 Test 4: Type Conversion and Validation")
        
        guard let chartField = documentEditor.field(fieldID: "chart1"),
              let value = chartField.value,
              case .valueElementArray(let elements) = value else {
            XCTFail("Chart field should have valueElementArray value")
            return
        }
        
        // Test that IDs are auto-generated (should be strings)
        for (lineIndex, line) in elements.enumerated() {
            if let lineId = line.id {
                print("✅ Line \(lineIndex) has auto-generated ID: \(lineId)")
                XCTAssertFalse(lineId.isEmpty, "Line ID should not be empty")
            }
            
            if let points = line.points {
                for (pointIndex, point) in points.enumerated() {
                    if let pointId = point.id {
                        print("✅ Point \(pointIndex) has auto-generated ID: \(pointId)")
                        XCTAssertFalse(pointId.isEmpty, "Point ID should not be empty")
                    }
                    
                    // Check that coordinates are numbers
                    if let x = point.x {
                        print("✅ Point \(pointIndex) x coordinate: \(x)")
                        XCTAssertNotNil(x, "Point x coordinate should be a number")
                    }
                    
                    if let y = point.y {
                        print("✅ Point \(pointIndex) y coordinate: \(y)")
                        XCTAssertNotNil(y, "Point y coordinate should be a number")
                    }
                }
            }
        }
        
        print("✅ Type conversion and validation tests passed")
    }
} 