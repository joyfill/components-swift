//
//  ImageFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 09/07/25.
//


import XCTest
import JoyfillModel

final class ImageFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "ImageFieldTestData"
    }
    
    
    func testImageFieldExists() {
        XCTAssertTrue(app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 0).exists)
        XCTAssertTrue(app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 1).exists)
        XCTAssertTrue(app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 2).exists)
    }
    
    func testSingleImageUpload() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 0)
        imageButton.tap()
        uploadTestImage()
        app.swipeUp()
        app.swipeDown()
        assertImageCount(expectedCount: 1)
        clickOnFirstImage()
        deleteSelectedImages()
        emptyImageAssert()
    }
    
    func testSingleImageOverwrite() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 0)
        imageButton.tap()
        uploadTestImage()
        assertImageCount(expectedCount: 1)
    }

    func testSingleImageDelete() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 0)
        imageButton.tap()
        uploadTestImage()
        clickOnFirstImage()
        deleteSelectedImages()
        emptyImageAssert()
    }
 
    func testMultiImageUpload() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 1)
        imageButton.tap()
        uploadTestImage()
        assertImageCount(expectedCount: 4)
    }

    func testMultiImageDelete() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 1)
        imageButton.tap()
        uploadTestImage()
        assertImageCount(expectedCount: 4)
        clickOnFirstImage()
        clickOnSecondImage()
        clickOnThirdImage()
        clickOnFourthImage()
        deleteSelectedImages()
        emptyImageAssert()
    }
  
    func testSingleImageOverwriteForNil() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 2)
        imageButton.tap()
        uploadTestImage()
        assertImageCount(expectedCount: 1)
    }

    func testSingleImageDeleteForNil() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 2)
        imageButton.tap()
        uploadTestImage()
        clickOnFirstImage()
        deleteSelectedImages()
        emptyImageAssert()
    }
    
    func testRequiredFieldAsteriskPresence() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 0)
        XCTAssertTrue(imageButton.exists, "Required field label should display")

        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should be visible for required field")
        imageButton.tap()
        assertImageCount(expectedCount: 1)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
    
    func testCheckHiddenFieldIsNotShown() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 4)
        XCTAssertFalse(imageButton.exists, "Hidden field should be hide")
    }
    
    func testFieldHeaderRendering() {
        let shortTitle = app.staticTexts["Image"]
        XCTAssertTrue(shortTitle.exists)
        
        let longTitle = app.staticTexts["This image is read only and testing for multiline header text."]
        XCTAssertTrue(longTitle.exists)
        
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 2)
        XCTAssertTrue(imageButton.exists, "Without header field should be hide")
    }

    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let alert = app.alerts["Tooltip Title"]
        XCTAssertTrue(alert.exists, "Alert should be visible")
        
        let alertTitle = alert.staticTexts["Tooltip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["Tooltip Description"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }
    
    func testReadonlyFieldShouldNotClickable() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 3)
        XCTAssertFalse(imageButton.isEnabled, "Readonly field should not be editable")
        imageButton.tap()
    }
    
    func testImageFieldOnFocusAndOnBlur() {
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 0)
        XCTAssertTrue(imageButton.exists, "Image field should exist")
        
        // Tap to focus (simulate focus)
        imageButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0)) // Allow any focus logic to process
        
        // Simulate blur by tapping outside (background)
        app.otherElements.firstMatch.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        // Fetch the payload and verify image field state was registered correctly
        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "686e205f779bc2a989ef0401")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_686e29c75d5345859568b24c")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "686e29c7dcb0658c92bb7d42")
        XCTAssertEqual(payload["fileId"] as? String, "66a14ced9dc829a95e272506")
        XCTAssertEqual(payload["target"] as? String, "field.update")
        XCTAssertEqual(payload["identifier"] as? String, "template_6849dbb509ede5510725c910")
        XCTAssertEqual(payload["_id"] as? String, "66a14cedd6e1ebcdf176a8da")
        XCTAssertEqual(payload["sdk"] as? String, "swift")
        
        if let change = payload["change"] as? [String: Any],
           let values = change["value"] as? [[String: Any]],
           let first = values.first {
            XCTAssertNotNil(first["_id"], "Image item should have an _id")
            let urlString = first["url"] as? String
            //validate URL is well-formed
            XCTAssertNotNil(URL(string: urlString ?? ""), "URL should be valid")
            
        } else if let changeJSON = payload["change"] as? String,
                  let changeData = changeJSON.data(using: .utf8),
                  let changeObj = try? JSONSerialization.jsonObject(with: changeData) as? [String: Any],
                  let values = changeObj["value"] as? [[String: Any]],
                  let first = values.first {
            
            XCTAssertNotNil(first["_id"], "Image item should have an _id")
            let urlString = first["url"] as? String
            XCTAssertNotNil(URL(string: urlString ?? ""), "URL should be valid")
            
        } else {
            XCTFail("'change.value' missing or in unexpected format")
        }
    }
    
    func testHideImageFieldByTextField() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 1)
        originalPageButton.tap()
        
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 0)
        XCTAssertTrue(imageButton.exists)
        
        let textField = app.textFields.element(boundBy: 0)
        XCTAssert(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.clearText()
        textField.typeText("hide")
        XCTAssertFalse(imageButton.exists)
        
        textField.tap()
        textField.clearText()
        textField.typeText("show")
        XCTAssertTrue(imageButton.exists)
    }
    
    // MARK: - Helper Methods

    func assertImageCount(expectedCount: Int) {
        XCTAssertEqual(expectedCount, onChangeResultValue().imageURLs?.count)
    }
    
    func emptyImageAssert() {
        XCTAssertNil(onChangeResultValue().imageURLs)
    }
    
    func deleteSelectedImages() {
        app.buttons["ImageDeleteIdentifier"].tap()
        swipeSheetDown()
        emptyImageAssert()
    }
    
    func clickOnFirstImage() {
        // Try the simplified approach first, then fall back to original complex hierarchy
        let simpleFirstImage = app.images.matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 1)
        let complexFirstImage = app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 1)
        
        var found = simpleFirstImage.waitForExistence(timeout: 3)
        var imageToTap = simpleFirstImage
        
        if !found {
            found = complexFirstImage.waitForExistence(timeout: 3)
            imageToTap = complexFirstImage
        }
        
        if !found {
            app.swipeUp()
            found = simpleFirstImage.waitForExistence(timeout: 2)
            imageToTap = simpleFirstImage
        }
        
        XCTAssertTrue(found, "First image with DetailPageImageSelectionIdentifier not found")
        imageToTap.tap()
    }
    
    func clickOnSecondImage() {
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 2).tap()
    }
    
    func clickOnThirdImage() {
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 4).tap()
    }
    
    func clickOnFourthImage() {
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 6).tap()
    }

    func uploadTestImage() {
        let moreButton = app.buttons.matching(identifier: "ImageMoreIdentifier").element(boundBy: 0)
        moreButton.tap()
        let uploadMoreButton = app.buttons.matching(identifier: "ImageUploadImageIdentifier").element(boundBy: 0)
        uploadMoreButton.tap()
        uploadMoreButton.tap()
        uploadMoreButton.tap()
    }
}
