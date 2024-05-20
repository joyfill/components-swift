import XCTest

final class ImageFieldTests: JoyfillUITestsBaseClass {
   
    func testImageFieldDelete() {
        goToImageDetailPageAndDeleteImageAndGoBack()
        emptyImageAssert()
        XCTAssertEqual(onChangeOptionalResult()!, expectedChange(for: imageDeleteFieldOnChange)!)
    }

    func testImageUploadFromMainPage() {
        goToImageDetailPageAndDeleteImageAndGoBack()
        emptyImageAssert()

        app.buttons["ImageIdentifier"].tap()
        imageAssert()
        XCTAssertEqual(onChangeOptionalResult()!, expectedChange(for: imageUploadFromMainPageFieldOnChange)!)
    }

    func testImageUploadFromDetailPage() {
        goToImageDetailPage()
        uploadImageOnDetailPageAndGoBack()
        imageAssert()
        XCTAssertEqual(onChangeOptionalResult()!, expectedChange(for: imageUploadFromDetailPageFieldOnChange)!)
    }

    func testMultipleImageUploadFromDetailPage() {
        goToImageDetailPage()
        uploadImageOnDetailPage()
//        uploadImageOnDetailPageAndGoBack()
//        imageAssertCount(count: 2)
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
