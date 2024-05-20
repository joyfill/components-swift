import XCTest
import JoyfillModel

class JoyfillUITestsBaseClass: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        self.app = XCUIApplication()
        app.launchArguments.append("JoyfillUITests")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func goBack() {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

}

extension JoyfillUITestsBaseClass {
    func onChangeResultValue() -> ValueUnion {
        let result = onChangeResult()
        let change = result.change!
        let value = change["value"]!

        let valueUnion = ValueUnion(value: value)!
        return valueUnion
    }

    func onChangeResultChange() -> ValueUnion {
        let change = onChangeResult().change!
        let valueUnion = ValueUnion(value: change)!
        return valueUnion
    }

    func onChangeResult() -> Change {
        return onChangeOptionalResult()!
    }
    
    func onChangeOptionalResult() -> Change? {
        let resultField = app.staticTexts["resultfield"]
        let jsonString = resultField.label
        print("resultField.label: \(resultField.label)")
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] {
                    let change = Change(dictionary: dictionary)
                    return change
                }
            } catch {
                print("Failed to decode JSON string to model: \(error)")
            }
        } else {
            print("Failed to convert string to data")
        }
        return nil
    }

    func expectedChange(for jsonString: String) -> Change? {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] {
                    let change = Change(dictionary: dictionary)
                    return change
                }
            } catch {
                print("Failed to decode JSON string to model: \(error)")
            }
        } else {
            print("Failed to convert string to data")
        }
        return nil
    }
}

extension Change: Equatable {
    var chnageValue: ValueUnion? {
        return ValueUnion(value: change as Any)
    }

    public static func == (lhs: Change, rhs: Change) -> Bool {
        return lhs.id == rhs.id &&
        lhs.v == rhs.v &&
        lhs.sdk == rhs.sdk &&
        lhs.target == rhs.target &&
        lhs.identifier == rhs.identifier &&
        lhs.fileId == rhs.fileId &&
        lhs.pageId == rhs.pageId &&
        lhs.fieldId == rhs.fieldId &&
        lhs.fieldIdentifier == rhs.fieldIdentifier &&
        lhs.fieldPositionId == rhs.fieldPositionId &&
//        lhs.chnageValue == rhs.chnageValue &&
//        lhs.createdOn == rhs.createdOn &&
        lhs.xTitle == rhs.xTitle
    }
}
