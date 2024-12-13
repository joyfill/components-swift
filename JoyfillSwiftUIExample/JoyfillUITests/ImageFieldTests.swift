import XCTest

final class ImageFieldTests: JoyfillUITestsBaseClass {
   
    func testImageFieldDelete() {
        goToImageDetailPageAndDeleteImageAndGoBack()
        emptyImageAssert()
    }

    func testImageUploadFromMainPage() {
        goToImageDetailPageAndDeleteImageAndGoBack()
        emptyImageAssert()

        app.buttons["ImageIdentifier"].tap()
        imageAssert()
    }

    func testImageUploadFromDetailPage() {
        goToImageDetailPage()
        uploadImageOnDetailPageAndGoBack()
        imageAssertCount(count: 2)
        XCTAssertEqual("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s", onChangeResultValue().imageURLs?[1])
    }

    // Upload multiple images and delete all images
    func testMultipleImageUploadFromDetailPage() {
        app.buttons["ImageMoreIdentifier"].tap()
        
        uploadImageOnDetailPage()
        uploadImageOnDetailPage()
        uploadImageOnDetailPage()
        uploadImageOnDetailPage()
        clickOnFirstImage()
        clickOnSecondImage()
        clickOnThirdImage()
        clickOnFourthImage()
        clickOnFifthImage()
        
        app.buttons["ImageDeleteIdentifier"].tap()
        goBack()
        emptyImageAssert()
    }
}

extension ImageFieldTests {
    private func goToImageDetailPage() {
        app.buttons["ImageMoreIdentifier"].tap()
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 0).tap()
    }

    private func goToImageDetailPageAndDeleteImageAndGoBack() {
        goToImageDetailPage()
        app.buttons["ImageDeleteIdentifier"].tap()
        goBack()
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
    
    func clickOnFifthImage() {
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 8).tap()
    }

    private func imageAssert() {
        imageAssertCount(count: 1)
        XCTAssertEqual("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s", onChangeResultValue().imageURLs?.first)
    }

    private func imageAssertCount(count: Int) {
        XCTAssertEqual(count, onChangeResultValue().imageURLs?.count)
    }

    private func emptyImageAssert() {
        XCTAssertNil(onChangeResultValue().imageURLs)
    }

    private func uploadImageOnDetailPageAndGoBack() {
        uploadImageOnDetailPage()
        goBack()
    }

    private func uploadImageOnDetailPage() {
        app.buttons["ImageUploadImageIdentifier"].tap()
    }
}
