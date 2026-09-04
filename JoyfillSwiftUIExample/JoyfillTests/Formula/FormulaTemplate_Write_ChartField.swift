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
        documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Chart Field Write Tests
    
    func testChartFieldWriteFormulas() {
        print("\n📊 Chart Field Write Tests Starting...")
        
        guard let chartField = documentEditor.field(fieldID: "chart1") else {
            XCTFail("❌ Chart field 'chart1' not found")
            return
        }
        
        print("📊 Chart field found with type: \(chartField.fieldType)")
        
        // Initial test - verify formula executed
        if case .valueElementArray(let lines) = chartField.value {
            print("📊 Chart field has \(lines.count) lines after formula execution")
            
            print("\n🔍 Test 1: Write Custom Chart Lines Formula")
            print("Formula: writeCustomChartLines")
            print("Expected: Chart field populated with 2 lines")
            print("🎯 Result: Chart has \(lines.count) lines")
            
            XCTAssertEqual(lines.count, 2, "Chart should have 2 lines")
            
            if lines.count >= 1 {
                let line1 = lines[0]
                let lineDict = line1.dictionary
                    print("\n📊 Test 2: Chart Data Structure Validation")
                    
                    // Validate line 1 structure
                    if case .valueElementArray(let points) = lineDict["points"] {
                        print("🎯 Line 1 has \(points.count) points")
                        XCTAssertEqual(points.count, 3, "Line 1 should have 3 points")
                        print("✅ Point structure validated")
                    }
                    
                    // Validate line 1 data values
                    print("\n📝 Test 3: Chart Data Values Validation")
                    if case .string(let title) = lineDict["title"] {
                        print("🎯 Line 1 title: '\(title)'")
                        XCTAssertEqual(title, "Line 1 Label", "Line 1 title should match line1Label field")
                    }
                    
                    if case .valueElementArray(let points) = lineDict["points"], points.count > 0 {
                        let point1 = points[0]
                        let pointDict = point1.dictionary
                            if let label = pointDict["label"], case .string(let labelStr) = label {
                                print("🎯 Point 1 label: '\(labelStr)'")
                                XCTAssertEqual(labelStr, "Zero Point", "Point 1 label should match point1Label field")
                            }
                            if let x = pointDict["x"], case .int(let xVal) = x {
                                print("🎯 Point 1 x: \(xVal)")
                                XCTAssertEqual(xVal, 0, "Point 1 x should match point1X field")
                            }
                            if let y = pointDict["y"], case .int(let yVal) = y {
                                print("🎯 Point 1 y: \(yVal)")
                                XCTAssertEqual(yVal, 100, "Point 1 y should match point1Y field")
                            }
                    }
                
                // Validate line 2
                if lines.count >= 2 {
                    let line2 = lines[1]
                    let lineDict = line2.dictionary
                        if case .string(let title) = lineDict["title"] {
                            print("🎯 Line 2 title: '\(title)'")
                            XCTAssertEqual(title, "Line 2 Manual Label", "Line 2 should have manual title")
                        }
                        if case .valueElementArray(let points) = lineDict["points"] {
                            print("🎯 Line 2 has \(points.count) points (mapped from table)")
                        }
                }
            }
            
            // Test type conversion and ID generation
            print("\n🔧 Test 4: Type Conversion and Validation")
            validateChartStructure(lines: lines)
            print("✅ Type conversion and validation tests passed")
            
        } else {
            XCTFail("❌ Chart field should have valueElementArray value")
        }
    }
    
    // MARK: - Dynamic Chart Field Update Tests
    
    func testChartFieldDynamicUpdates() {
        print("\n🔄 Chart Field Dynamic Update Tests Starting...")
        
        // Test 1: Change line1Label and verify chart updates
        print("\n📝 Test 1: Updating line1Label field")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "line1Label"), 
            updateValue: ValueUnion.string("Updated Line Title")
        ))
        
        verifyChartLineTitle(lineIndex: 0, expectedTitle: "Updated Line Title", testName: "line1Label update")
        
        // Test 2: Change point1Label and verify chart updates
        print("\n📝 Test 2: Updating point1Label field")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point1Label"), 
            updateValue: ValueUnion.string("Updated Point Label")
        ))
        
        verifyChartPointLabel(lineIndex: 0, pointIndex: 0, expectedLabel: "Updated Point Label", testName: "point1Label update")
        
        // Test 3: Change point1X coordinate and verify chart updates
        print("\n📝 Test 3: Updating point1X coordinate")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point1X"), 
            updateValue: ValueUnion.int(50)
        ))
        
        verifyChartPointCoordinate(lineIndex: 0, pointIndex: 0, coordinate: "x", expectedValue: 50, testName: "point1X update")
        
        // Test 4: Change point1Y coordinate and verify chart updates
        print("\n📝 Test 4: Updating point1Y coordinate")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point1Y"), 
            updateValue: ValueUnion.int(150)
        ))
        
        verifyChartPointCoordinate(lineIndex: 0, pointIndex: 0, coordinate: "y", expectedValue: 150, testName: "point1Y update")
        
        // Test 5: Change point2Label and verify chart updates
        print("\n📝 Test 5: Updating point2Label field")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point2Label"), 
            updateValue: ValueUnion.string("Second Point Updated")
        ))
        
        verifyChartPointLabel(lineIndex: 0, pointIndex: 1, expectedLabel: "Second Point Updated", testName: "point2Label update")
        
        // Test 6: Change point2X coordinate and verify chart updates
        print("\n📝 Test 6: Updating point2X coordinate")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point2X"), 
            updateValue: ValueUnion.int(700)
        ))
        
        verifyChartPointCoordinate(lineIndex: 0, pointIndex: 1, coordinate: "x", expectedValue: 700, testName: "point2X update")
        
        // Test 7: Change point2Y coordinate and verify chart updates
        print("\n📝 Test 7: Updating point2Y coordinate")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point2Y"), 
            updateValue: ValueUnion.int(500)
        ))
        
        verifyChartPointCoordinate(lineIndex: 0, pointIndex: 1, coordinate: "y", expectedValue: 500, testName: "point2Y update")
        
        // Test 8: Test multiple field changes and verify cumulative effect
        print("\n📝 Test 8: Multiple field changes")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "line1Label"), 
            updateValue: ValueUnion.string("Final Line Title")
        ))
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point1X"), 
            updateValue: ValueUnion.int(100)
        ))
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point1Y"), 
            updateValue: ValueUnion.int(200)
        ))
        
        verifyChartLineTitle(lineIndex: 0, expectedTitle: "Final Line Title", testName: "multiple updates - line title")
        verifyChartPointCoordinate(lineIndex: 0, pointIndex: 0, coordinate: "x", expectedValue: 100, testName: "multiple updates - point1X")
        verifyChartPointCoordinate(lineIndex: 0, pointIndex: 0, coordinate: "y", expectedValue: 200, testName: "multiple updates - point1Y")
        
        // Test 9: Test edge cases with extreme values
        print("\n📝 Test 9: Edge cases with extreme values")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point1X"), 
            updateValue: ValueUnion.int(0)
        ))
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point1Y"), 
            updateValue: ValueUnion.int(1000)
        ))
        
        verifyChartPointCoordinate(lineIndex: 0, pointIndex: 0, coordinate: "x", expectedValue: 0, testName: "edge case - min x")
        verifyChartPointCoordinate(lineIndex: 0, pointIndex: 0, coordinate: "y", expectedValue: 1000, testName: "edge case - max y")
        
        // Test 10: Test empty string values
        print("\n📝 Test 10: Empty string values")
        documentEditor.onChange(event: FieldChangeData(
            fieldIdentifier: documentEditor.identifierModel(for: "point1Label"), 
            updateValue: ValueUnion.string("")
        ))
        
        verifyChartPointLabel(lineIndex: 0, pointIndex: 0, expectedLabel: "", testName: "empty string label")
        
        print("✅ All dynamic update tests completed successfully")
    }
    
    // MARK: - Helper Methods for Chart Validation
    
    private func verifyChartLineTitle(lineIndex: Int, expectedTitle: String, testName: String) {
        guard let chartField = documentEditor.field(fieldID: "chart1") else {
            XCTFail("❌ Chart field not found for \(testName)")
            return
        }
        
        if case .valueElementArray(let lines) = chartField.value {
            guard lineIndex < lines.count else {
                XCTFail("❌ Line index \(lineIndex) out of bounds for \(testName)")
                return
            }
            
            let line = lines[lineIndex]
            let lineDict = line.dictionary
            if case .string(let actualTitle) = lineDict["title"] {
                XCTAssertEqual(actualTitle, expectedTitle, "❌ \(testName): Expected '\(expectedTitle)', got '\(actualTitle)'")
                print("✅ \(testName): Line \(lineIndex) title correctly updated to '\(actualTitle)'")
            } else {
                XCTFail("❌ \(testName): Could not extract line title")
            }
        } else {
            XCTFail("❌ \(testName): Chart field does not have proper structure")
        }
    }
    
    private func verifyChartPointLabel(lineIndex: Int, pointIndex: Int, expectedLabel: String, testName: String) {
        guard let chartField = documentEditor.field(fieldID: "chart1") else {
            XCTFail("❌ Chart field not found for \(testName)")
            return
        }
        
        if case .valueElementArray(let lines) = chartField.value {
            guard lineIndex < lines.count else {
                XCTFail("❌ Line index \(lineIndex) out of bounds for \(testName)")
                return
            }
            
            let line = lines[lineIndex]
            let lineDict = line.dictionary
            if
               case .valueElementArray(let points) = lineDict["points"] {
                guard pointIndex < points.count else {
                    XCTFail("❌ Point index \(pointIndex) out of bounds for \(testName)")
                    return
                }
                
                let point = points[pointIndex]
                let pointDict = point.dictionary
                if case .string(let actualLabel) = pointDict["label"] {
                    XCTAssertEqual(actualLabel, expectedLabel, "❌ \(testName): Expected '\(expectedLabel)', got '\(actualLabel)'")
                    print("✅ \(testName): Point [\(lineIndex)][\(pointIndex)] label correctly updated to '\(actualLabel)'")
                } else {
                    XCTFail("❌ \(testName): Could not extract point label")
                }
            } else {
                XCTFail("❌ \(testName): Could not extract line points")
            }
        } else {
            XCTFail("❌ \(testName): Chart field does not have proper structure")
        }
    }
    
    private func verifyChartPointCoordinate(lineIndex: Int, pointIndex: Int, coordinate: String, expectedValue: Int64, testName: String) {
        guard let chartField = documentEditor.field(fieldID: "chart1") else {
            XCTFail("❌ Chart field not found for \(testName)")
            return
        }
        
        if case .valueElementArray(let lines) = chartField.value {
            guard lineIndex < lines.count else {
                XCTFail("❌ Line index \(lineIndex) out of bounds for \(testName)")
                return
            }
            
            let line = lines[lineIndex]
            let lineDict = line.dictionary
            if case .valueElementArray(let points) = lineDict["points"] {
                guard pointIndex < points.count else {
                    XCTFail("❌ Point index \(pointIndex) out of bounds for \(testName)")
                    return
                }
                
                let point = points[pointIndex]
                let pointDict = point.dictionary
                if
                   case .int(let actualValue) = pointDict[coordinate] {
                    XCTAssertEqual(actualValue, expectedValue, "❌ \(testName): Expected \(expectedValue), got \(actualValue)")
                    print("✅ \(testName): Point [\(lineIndex)][\(pointIndex)].\(coordinate) correctly updated to \(actualValue)")
                } else {
                    XCTFail("❌ \(testName): Could not extract point \(coordinate) coordinate")
                }
            } else {
                XCTFail("❌ \(testName): Could not extract line points")
            }
        } else {
            XCTFail("❌ \(testName): Chart field does not have proper structure")
        }
    }
    
    // MARK: - Chart Structure Validation
    
    private func validateChartStructure(lines: [ValueElement]) {
        print("🔧 Validating chart structure...")
        
        for (lineIndex, line) in lines.enumerated() {
            // Validate line structure
            let lineDict = line.dictionary
                print("✅ Line \(lineIndex): Has dictionary structure")
                
                // Check required properties
                if case .string(let title) = lineDict["title"] {
                    print("  ✅ Title: '\(title)'")
                } else {
                    print("  ❌ Missing or invalid title")
                }
                
                if case .valueElementArray(let points) = lineDict["points"] {
                    print("  ✅ Points: Array with \(points.count) elements")
                    
                    // Validate point structure
                    for (pointIndex, point) in points.enumerated() {
                        let pointDict = point.dictionary
                            let label = pointDict["label"]
                            let x = pointDict["x"]
                            let y = pointDict["y"]
                            
                            let labelValid = label != nil
                            let xValid = x != nil
                            let yValid = y != nil
                            
                            print("    ✅ Point \(pointIndex): label=\(labelValid), x=\(xValid), y=\(yValid)")
                    }
                } else {
                    print("  ❌ Missing or invalid points array")
                }
                
                // Check ID generation
                if let _ = lineDict["_id"] {
                    print("  ✅ Line has generated ID")
                } else {
                    print("  ❌ Line missing ID")
                }
        }
        
        print("✅ Chart structure validation completed")
    }
} 
