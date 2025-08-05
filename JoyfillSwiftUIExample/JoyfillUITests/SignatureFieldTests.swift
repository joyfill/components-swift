import XCTest

final class SignatureFieldTests: JoyfillUITestsBaseClass {
    
    func testSaveSignature() throws {
        app.swipeUp()
        app.swipeUp()
        let signatureDetailButton = app.buttons["SignatureIdentifier"]
        signatureDetailButton.tap()
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        XCTAssertEqual("Edit Signature", signatureDetailButton.label)
        XCTAssertNotNil(onChangeResultValue().signatureURL?.isEmpty)
    }
    
    func testClearSignature() throws {
        app.swipeUp()
        app.swipeUp()
        let signatureDetailButton = app.buttons["SignatureIdentifier"]
        signatureDetailButton.tap()
        drawSignatureLine()
        app.buttons["ClearSignatureIdentifier"].tap()
        app.buttons["SaveSignatureIdentifier"].tap()
        XCTAssertEqual("Add Signature", signatureDetailButton.label)
        XCTAssertEqual("", onChangeResultValue().signatureURL)
    }
    
    func testSaveEmptySignature() throws {
        app.swipeUp()
        app.swipeUp()
        let signatureDetailButton = app.buttons["SignatureIdentifier"]
        signatureDetailButton.tap()
        app.buttons["SaveSignatureIdentifier"].tap()
        XCTAssertEqual("Edit Signature", signatureDetailButton.label)
        XCTAssertTrue(((onChangeResultValue().signatureURL?.hasPrefix("data:image/png;base64")) != nil), "Expected signatureURL to start with 'data:image/png;base64'")
    }
    
    func drawSignatureLine() {
        let canvas = app.otherElements["CanvasIdentifier"]
        canvas.tap()
        let startPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let endPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 1))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
    }
}
