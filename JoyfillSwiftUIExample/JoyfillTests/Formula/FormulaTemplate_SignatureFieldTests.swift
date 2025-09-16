////
////  FormulaTemplate_SignatureFieldTests.swift
////  JoyfillTests
////
////  Created by Vishnu Dutt on 25/06/25.
////
//
//import XCTest
//import Foundation
//import JoyfillModel
//import Joyfill
//
//class FormulaTemplate_SignatureFieldTests: XCTestCase {
//
//    // MARK: - Setup & Teardown
//    
//    private var documentEditor: DocumentEditor!
//
//    override func setUp() {
//        super.setUp()
//        let document = sampleJSONDocument(fileName: "FormulaTemplate_SignatureField")
//        documentEditor = DocumentEditor(document: document, validateSchema: false)
//    } 
//
//    override func tearDown() {
//        documentEditor = nil
//        super.tearDown()
//    }
//    
//    // MARK: - Signature Field Tests
//    
//    func testSignatureFieldFormulas() {
//        print("\n🧪 === Signature Field Formula Tests ===")
//        print("Testing signature field validation and status formulas")
//        
//        testSignaturePresenceFormula()
//        testSignatureStatusFormula()
//        testSignatureFieldBehavior()
//    }
//    
//    // MARK: - Individual Test Methods
//    
//    private func testSignaturePresenceFormula() {
//        print("\n✅ Test 1: Signature presence detection")
//        print("Formula: not(empty(signature1))")
//        print("Tests whether a signature field has content")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "field_text1")
//        let resultText = result?.text ?? ""
//        
//        print("🎯 Result: '\(resultText)'")
//        
//        // The signature field has a base64 value, so it should be detected as present
//        XCTAssertTrue(resultText == "true" || resultText == "1" || resultText.lowercased() == "true", 
//                     "Should detect signature as present when it has base64 data")
//    }
//    
//    private func testSignatureStatusFormula() {
//        print("\n✅ Test 2: Signature status message")
//        print("Formula: if(not(empty(signature1)), \"Signed\", \"Missing\")")
//        print("Returns appropriate status message based on signature presence")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "field_text2")
//        let resultText = result?.text ?? ""
//        
//        print("🎯 Result: '\(resultText)'")
//        
//        // Since signature has base64 data, status should be "Signed"
//        XCTAssertEqual(resultText, "Signed", 
//                      "Should return 'Signed' when signature field has content")
//    }
//    
//    private func testSignatureFieldBehavior() {
//        print("\n🔍 Test 3: Signature field behavior analysis")
//        
//        // Check the signature field itself
//        let signatureField = documentEditor.field(fieldID: "signature1")
//        let signatureValue = signatureField?.value?.text ?? ""
//        
//        print("Signature field analysis:")
//        print("  Field ID: signature1")
//        print("  Field type: signature")
//        print("  Has value: \(signatureValue.isEmpty ? "No" : "Yes")")
//        print("  Value length: \(signatureValue.count) characters")
//        print("  Is base64: \(signatureValue.hasPrefix("data:image/") ? "Yes" : "No")")
//        
//        XCTAssertNotNil(signatureField, "Signature field should exist")
//        XCTAssertFalse(signatureValue.isEmpty, "Signature field should have content")
//        
//        // Test that empty() function works correctly with signature fields
//        let isEmpty = signatureValue.isEmpty
//        let expectedPresence = !isEmpty
//        
//        print("  Formula logic verification:")
//        print("    empty(signature1): \(isEmpty)")
//        print("    not(empty(signature1)): \(expectedPresence)")
//        print("    Expected status: \(expectedPresence ? "Signed" : "Missing")")
//    }
//    
//    // MARK: - Signature Field Validation Tests
//    
//    private func testSignatureValidationScenarios() {
//        print("\n📝 Test 4: Signature validation scenarios")
//        
//        // Test various signature field states and expected outcomes
//        let testScenarios = [
//            ("signature with base64 data", true, "Signed"),
//            ("empty signature", false, "Missing")
//        ]
//        
//        for (scenario, hasContent, expectedStatus) in testScenarios {
//            print("Scenario: \(scenario)")
//            print("  Expected presence: \(hasContent)")
//            print("  Expected status: '\(expectedStatus)'")
//        }
//        
//        // Current test data has base64 signature data
//        let presenceResult = documentEditor.value(ofFieldWithIdentifier: "field_text1")
//        let statusResult = documentEditor.value(ofFieldWithIdentifier: "field_text2")
//        
//        print("Current results:")
//        print("  Presence: '\(presenceResult?.text ?? "")'")
//        print("  Status: '\(statusResult?.text ?? "")'")
//        
//        // Verify the formulas work correctly for the current signature state
//        XCTAssertNotNil(presenceResult, "Presence formula should return a result")
//        XCTAssertNotNil(statusResult, "Status formula should return a result")
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func debugSignatureField() {
//        print("\n🔍 Signature Field Debug:")
//        
//        if let signatureField = documentEditor.field(fieldID: "signature1") {
//            print("Signature field details:")
//            print("  Type: \(signatureField.type ?? "unknown")")
//            print("  Title: \(signatureField.title ?? "no title")")
//            print("  Has value: \(signatureField.value != nil)")
//            
//            if let value = signatureField.value?.text {
//                let preview = value.count > 50 ? String(value.prefix(50)) + "..." : value
//                print("  Value preview: \(preview)")
//                print("  Full length: \(value.count) characters")
//            }
//        } else {
//            print("❌ Signature field not found")
//        }
//        
//        // Debug formula fields
//        let textFields = ["field_text1", "field_text2"]
//        for fieldID in textFields {
//            if let field = documentEditor.field(fieldID: fieldID) {
//                print("\nText field '\(fieldID)':")
//                print("  Title: \(field.title ?? "no title")")
//                print("  Value: '\(field.value?.text ?? "")'")
//                print("  Has formulas: \(field.dictionary["formulas"] != nil)")
//            }
//        }
//    }
//    
//    private func debugSignatureFormulas() {
//        print("\n🔍 Signature Formula Debug:")
//        
//        // Check the formulas
//        let document = documentEditor.document
//            print("Document has \(document.formulas.count) formulas:")
//            
//            for formula in document.formulas {
//                if let id = formula.id, let expression = formula.expression {
//                    print("  Formula '\(id)': \(expression)")
//                }
//            }
//    }
//}
