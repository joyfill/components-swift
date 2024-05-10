//
//  ImageFieldTests.swift
//  JoyfillUITests
//
//  Created by Vishnu Dutt on 10/05/24.
//

import XCTest

final class ImageFieldTests: JoyfillUITestsBaseClass {
   
    func testImageFieldDelete() {
        goToImageDetailPageAndDeleteImage()
        emptyImageAssert()
    }

    func testImageUploadFromMainPage() {
        goToImageDetailPageAndDeleteImage()
        emptyImageAssert()

        app.buttons["ImageIdentifier"].tap()
        imageAssert()
    }

    func testImageUploadFromDetailPage() {
        goToImageDetailPage()

        app.buttons["ImageUploadImageIdentifier"].tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        imageAssert()
    }
}

extension ImageFieldTests {
    private func goToImageDetailPage() {
        app.buttons["ImageMoreIdentifier"].tap()
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 0).tap()
    }

    private func goToImageDetailPageAndDeleteImage() {
        goToImageDetailPage()
        app.buttons["ImageDeleteIdentifier"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    private func imageAssert() {
        XCTAssertEqual("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s", onChangeResultValue().imageURLs?.first)
    }

    private func emptyImageAssert() {
        XCTAssertNil(onChangeResultValue().imageURLs)
    }
}
