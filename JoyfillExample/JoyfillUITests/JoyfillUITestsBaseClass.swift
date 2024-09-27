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
    
    func onChangeResultChanges() -> [ValueUnion] {
        let results = onChangeOptionalResults().map { $0.change }
        return results.compactMap {
            ValueUnion(value: $0)!
        }
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
                if let dicts = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String: Any]] {
                    let change = Change(dictionary: dicts.first!)
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
    
    func onChangeOptionalResults() -> [Change] {
        let resultField = app.staticTexts["resultfield"]
        let jsonString = resultField.label
        print("resultField.label: \(resultField.label)")
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let dicts = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String: Any]] {
                    return dicts.map(Change.init)
                }
            } catch {
                print("Failed to decode JSON string to model: \(error)")
            }
        } else {
            print("Failed to convert string to data")
        }
        return []
    }
}
