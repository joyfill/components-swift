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
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 1).tap()
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
