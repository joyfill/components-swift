import XCTest

final class SignatureFieldTests: JoyfillUITestsBaseClass {
    
    func testSaveSignature() throws {
        let signatureDetailButton = app.buttons["SignatureIdentifier"]
        var attempts = 0
        while !signatureDetailButton.exists && attempts < 5 {
            app.swipeUp()
            sleep(1)
            attempts += 1
        }
        
        XCTAssertTrue(signatureDetailButton.waitForExistence(timeout: 5), "Signature button not found")
        signatureDetailButton.tap()
        drawSignatureLine()
        let saveButton = app.buttons["SaveSignatureIdentifier"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
        XCTAssertEqual("Edit Signature", signatureDetailButton.label)
        XCTAssertNotNil(onChangeResultValue().signatureURL?.isEmpty)
    }
    
    func testClearSignature() throws {
        let signatureDetailButton = app.buttons["SignatureIdentifier"]
        
        var attempts = 0
        while !signatureDetailButton.exists && attempts < 5 {
            app.swipeUp()
            sleep(1)
            attempts += 1
        }
        
        XCTAssertTrue(signatureDetailButton.waitForExistence(timeout: 5), "Signature button not found")
        
        signatureDetailButton.tap()
        drawSignatureLine()
        app.buttons["ClearSignatureIdentifier"].tap()
        app.buttons["SaveSignatureIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual("", onChangeResultValue().signatureURL)
    }
    
    func testSaveEmptySignature() throws {
        let signatureDetailButton = app.buttons["SignatureIdentifier"]
        
        var attempts = 0
        while !signatureDetailButton.exists && attempts < 5 {
            app.swipeUp()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            attempts += 1
        }
        
        XCTAssertTrue(signatureDetailButton.waitForExistence(timeout: 5), "Signature button not found")
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
