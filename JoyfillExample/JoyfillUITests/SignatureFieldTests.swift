import XCTest

final class SignatureFieldTests: JoyfillUITestsBaseClass {

    func testSignatureField() throws {
        app.swipeUp()
        app.swipeUp()
        app.buttons["SignatureIdentifier"].tap()
        goBack()
    }
}
