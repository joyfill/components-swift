import XCTest
import Foundation
import SwiftUI
import JoyfillModel

final class ValidationTestCase: XCTestCase {
    var document = JoyDoc()
    
    // Test Case for check at same time web and mobile view fields
    func testInValidWebViewWithInValidMobileView_resultShouldBeInValid() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setImageFieldPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    func testInvalidWebViewWithValidMobileView_resultShouldBeValid() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithValue()
            .setRequiredChartFieldWithoutValue()
            .setImageFieldPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    func testValidWebViewWithInValidMobileView_resultShouldBeValid() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setRequiredChartFieldWithValue()
            .setImageFieldPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    func testValidWebViewWithValidMobileView_resultShouldBeValid() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithValue()
            .setRequiredChartFieldWithValue()
            .setImageFieldPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Test Case for All fields one by one
    
    // Invalid Image Field - Result - InValid
    func testInValidWebViewWithInValidMobileImageFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setImageFieldPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid image field - result - valid
    func testInValidWebViewWithValidMobileImageFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithValue()
            .setRequiredChartFieldWithoutValue()
            .setImageFieldPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Text Field - Result - InValid
    func testInValidWebViewWithInValidMobileTextFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setTextPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb1d92a76d06750ca4a1")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Text Field - Result - Valid
    func testInValidWebViewWithValidMobileTextFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setTextPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb1d92a76d06750ca4a1")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Multiline Field - Result - InValid
    func testInValidWebViewWithInValidMobileMultilineTextFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredMultilineTextFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setMultilinePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb2b9a487ce1c1f35f6c")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Multiline Field - Result - Valid
    func testInValidWebViewWithValidMobileMultilineTextFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredMultilineTextFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setMultilinePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb2b9a487ce1c1f35f6c")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Number Field - Result - InValid
    func testInValidWebViewWithInValidMobileNumberFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredNumberFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setNumberPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb3df03de10b26270ab3")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Number Field - Result - Valid
    func testInValidWebViewWithValidMobileNumberFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredNumberFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setNumberPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb3df03de10b26270ab3")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Date Field - Result - InValid
    func testInValidWebViewWithInValidMobileDateFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDateFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setDatePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb44c79bb16ce072d233")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Date Field - Result - Valid
    func testInValidWebViewWithValidMobileDateFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDateFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setDatePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb44c79bb16ce072d233")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Time Field - Result - InValid
    func testInValidWebViewWithInValidMobileTimeFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTimeFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setTimePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb638e230f348d0a8682")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Time Field - Result - Valid
    func testInValidWebViewWithValidMobileTimeFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTimeFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setTimePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb638e230f348d0a8682")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid dateTime Field - Result - InValid
    func testInValidWebViewWithInValidMobileDateTimeFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDateTimeFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setDateTimePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb6ec5d88d3aadf548ca")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid dateTime Field - Result - Valid
    func testInValidWebViewWithValidMobileDateTimeFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDateTimeFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setDateTimePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb6ec5d88d3aadf548ca")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Dropdown Field - Result - InValid
    func testInValidWebViewWithInValidMobileDropdownFieldView() {
        let validationResult = Validator.validate(document:
            document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDropdownFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setDropdownPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb77593e3791638628bb")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Dropdown Field - Result - Valid
    func testInValidWebViewWithValidMobileDropdownFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDropdownFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setDropdownPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb77593e3791638628bb")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Multiselect Field - Result - InValid
    func testInValidWebViewWithInValidMobileMultiSelectFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredMultipleChoiceFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setMultiselectPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb9f4d912053577652b1")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Multiselect Field - Result - Valid
    func testInValidWebViewWithValidMobileMultiSelectFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredMultipleChoiceFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setMultiselectPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fb9f4d912053577652b1")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Single Field - Result - InValid
    func testInValidWebViewWithInValidMobileSingleChoiceFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setSingleSelectPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fbb2bf4f965b9d04f153")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Single Field - Result - Valid
    func testInValidWebViewWithValidMobileSingleChoiceFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredSingleChoiceFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setSingleSelectPositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fbb2bf4f965b9d04f153")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Signature Field - Result - InValid
    func testInValidWebViewWithInValidMobileSignatureFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredSignatureFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setSignaturePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fbb8cd16c0c4d308a252")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Signature Field - Result - Valid
    func testInValidWebViewWithValidMobileSignatureFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredSignatureFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setSignaturePositionInMobile()
            .setChartPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fbb8cd16c0c4d308a252")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Invalid Chart Field - Result - InValid
    func testInValidWebViewWithInValidMobileChartFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredChartFieldWithoutValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setChartPositionInMobile()
            .setSingleSelectPosition())
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .invalid)
    }
    
    // Valid Chart Field - Result - Valid
    func testInValidWebViewWithValidMobileChartFieldView() {
        let validationResult = Validator.validate(document:
             document
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredChartFieldWithValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setChartPositionInMobile()
            .setSingleSelectPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 1)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
    }
    
    // Hidden Field Test cases - result always - valid
    func testRequiredHiddenNumberFieldWithoutValue() {
        let validationResult = Validator.validate(document:
             document
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextField()
            .setRequiredNumberHiddenFieldWithoutValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredNumberHiddenFieldWithoutValuePositionInMobile()
            .setRequiredTextFieldInMobile()
            .setSingleSelectPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 2)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations[1].field.id, "66aa29c05db08120464a2875")
        XCTAssertEqual(validationResult.fieldValidations[1].status, .valid)
    }
    
    func testRequiredHiddenNumberFieldWithValue() {
       let validationResult = Validator.validate(document:
            document
           .setDocument()
           .setFile()
           .setMobileView()
           .setPageFieldInMobileView()
           .setPageField()
           .setRequiredTextField()
           .setRequiredNumberHiddenFieldWithValue()
           .setRequiredSingleChoiceFieldWithoutValue()
           .setRequiredNumberHiddenFieldWithoutValuePositionInMobile()
           .setRequiredTextFieldInMobile()
           .setSingleSelectPosition())
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 2)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations[1].field.id, "66aa29c05db08120464a2875")
        XCTAssertEqual(validationResult.fieldValidations[1].status, .valid)
   }
    
    // Show Hidden Field Test Cases
    func testRequiredShowHiddenFieldWithoutValue() {
       let validationResult = Validator.validate(document:
            document
           .setDocument()
           .setFile()
           .setMobileView()
           .setPageFieldInMobileView()
           .setPageField()
           .setRequiredTextField()
           .setRequiredShowNumberFieldByLogicWithoutValue()
           .setRequiredSingleChoiceFieldWithoutValue()
           .setRequiredTextFieldInMobile()
           .setRequiredShowNumberFieldByLogicWithoutValuePositionInMobile()
           .setSingleSelectPosition())
       
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidations.count, 2)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations[1].field.id, "66aa28f805a4900ae643db9c")
        XCTAssertEqual(validationResult.fieldValidations[1].status, .invalid)
        
   }
    
    func testRequiredShowHiddenFieldWithValue() {
       let validationResult = Validator.validate(document:
            document
           .setDocument()
           .setFile()
           .setMobileView()
           .setPageFieldInMobileView()
           .setPageField()
           .setRequiredTextField()
           .setRequiredShowNumberFieldByLogicWithValue()
           .setRequiredSingleChoiceFieldWithoutValue()
           .setRequiredTextFieldInMobile()
           .setRequiredShowNumberFieldByLogicWithoutValuePositionInMobile()
           .setSingleSelectPosition())
       
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 2)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations[1].field.id, "66aa28f805a4900ae643db9c")
        XCTAssertEqual(validationResult.fieldValidations[1].status, .valid)
        
   }
    
    // Hide field test cases
    func testRequiredShowHiddenFieldWithoutValues() {
       let validationResult = Validator.validate(document:
            document
           .setDocument()
           .setFile()
           .setMobileView()
           .setPageFieldInMobileView()
           .setPageField()
           .setRequiredTextField()
           .setRequiredHideNumberFieldByLogicWithoutValue()
           .setRequiredSingleChoiceFieldWithoutValue()
           .setRequiredTextFieldInMobile()
           .setRequiredHideNumberFieldByLogicWithoutValuePositionInMobile()
           .setSingleSelectPosition())
       
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 2)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations[1].field.id, "66aa28f805a4900ae643db9c")
        XCTAssertEqual(validationResult.fieldValidations[1].status, .valid)
        
   }
    
    func testRequiredHideNumberFieldWithValues() {
       let validationResult = Validator.validate(document:
            document
           .setDocument()
           .setFile()
           .setMobileView()
           .setPageFieldInMobileView()
           .setPageField()
           .setRequiredTextField()
           .setRequiredHideNumberFieldByLogicWithValue()
           .setRequiredSingleChoiceFieldWithoutValue()
           .setRequiredTextFieldInMobile()
           .setRequiredHideNumberFieldByLogicWithoutValuePositionInMobile()
           .setSingleSelectPosition())
       
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations.count, 2)
        XCTAssertEqual(validationResult.fieldValidations.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidations.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidations[1].field.id, "66aa28f805a4900ae643db9c")
        XCTAssertEqual(validationResult.fieldValidations[1].status, .valid)
        
   }
}
