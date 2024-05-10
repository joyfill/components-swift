import XCTest

final class JoyfillUITestsLaunchTests: JoyfillUITestsBaseClass {

    func testLaunch() throws {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
