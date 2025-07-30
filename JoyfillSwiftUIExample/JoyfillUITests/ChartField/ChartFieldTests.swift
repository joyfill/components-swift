import XCTest
import JoyfillModel

final class ChartFieldTests: JoyfillUITestsBaseClass {

    func goToChartDetailField() {
        let chartViewButton = app.buttons["ChartViewIdentifier"]
        
        var attempts = 0
        while !chartViewButton.exists && attempts < 5 {
            app.swipeUp()
            sleep(1)
            attempts += 1
        }
        
        XCTAssertTrue(chartViewButton.waitForExistence(timeout: 5), "Chart view button not found")
        chartViewButton.tap()
    }

    func testChartField() {
        goToChartDetailField()

        app.buttons["ShowHideButtonIdentifier"].tap()
        let verticalTitleTextFieldIdentifier = app.textFields["VerticalTextFieldIdentifier"]
        let horizontalTitleTextFieldIdentifier = app.textFields["HorizontalTextFieldIdentifier"]

        verticalTitleTextFieldIdentifier.tap()
        verticalTitleTextFieldIdentifier.typeText(" Label Y")
        horizontalTitleTextFieldIdentifier.tap()
        horizontalTitleTextFieldIdentifier.typeText(" Label X")

        let minYValuesTextField = app.textFields["MinY"]
        let minXValuesTextField = app.textFields["MinX"]
        let maxYValuesTextField = app.textFields["MaxY"]
        let maxXValuesTextField = app.textFields["MaxX"]

        minYValuesTextField.tap()
        minYValuesTextField.clearText()
        minYValuesTextField.typeText("10")
        minXValuesTextField.tap()
        minXValuesTextField.clearText()
        minXValuesTextField.typeText("20")
        maxYValuesTextField.tap()
        maxYValuesTextField.clearText()
        maxYValuesTextField.typeText("10030")
        maxXValuesTextField.tap()
        maxXValuesTextField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        maxXValuesTextField.clearText()
        maxXValuesTextField.typeText("10040")
        sleep(1)
        goBack()

        XCTAssertEqual("Horizontal Label X", onChangeResultChange().xTitle)
        XCTAssertEqual("Vertical Label Y", onChangeResultChange().yTitle)
        XCTAssertEqual(10040.0, onChangeResultChange().xMax)
        XCTAssertEqual(20.0, onChangeResultChange().xMin)
        XCTAssertEqual(10030.0, onChangeResultChange().yMax)
        XCTAssertEqual(10.0, onChangeResultChange().yMin)
        
        sleep(1)
        goToChartDetailField()
        app.buttons["ShowHideButtonIdentifier"].tap()

        XCTAssertEqual(verticalTitleTextFieldIdentifier.value as? String, "Vertical Label Y", "TextField value is incorrect after navigation")
        XCTAssertEqual(horizontalTitleTextFieldIdentifier.value as? String, "Horizontal Label X", "TextField value is incorrect after navigation")
        XCTAssertEqual(minYValuesTextField.value as? String, "10", "TextField value is incorrect after navigation")
        XCTAssertEqual(minXValuesTextField.value as? String, "20", "TextField value is incorrect after navigation")
        XCTAssertEqual(maxYValuesTextField.value as? String, "10030", "TextField value is incorrect after navigation")
        XCTAssertEqual(maxXValuesTextField.value as? String, "10040", "TextField value is incorrect after navigation")
    }
    
    func testEditAllCoordinatesFieldAfterRemoveLine() {
        goToChartDetailField()
        
        let removeLineButtonIdentifier = app.buttons.matching(identifier: "RemoveLineIdentifier")
        let removeLineButton = removeLineButtonIdentifier.element(boundBy: 0)
        removeLineButton.tap()
        
        goBack()
        goToChartDetailField()

        app.buttons["ShowHideButtonIdentifier"].tap()
        let verticalTitleTextFieldIdentifier = app.textFields["VerticalTextFieldIdentifier"]
        let horizontalTitleTextFieldIdentifier = app.textFields["HorizontalTextFieldIdentifier"]

        verticalTitleTextFieldIdentifier.tap()
        verticalTitleTextFieldIdentifier.typeText(" Label Y")
        horizontalTitleTextFieldIdentifier.tap()
        horizontalTitleTextFieldIdentifier.typeText(" Label X")

        let minYValuesTextField = app.textFields["MinY"]
        let minXValuesTextField = app.textFields["MinX"]
        let maxYValuesTextField = app.textFields["MaxY"]
        let maxXValuesTextField = app.textFields["MaxX"]
        
        XCTAssertTrue(minYValuesTextField.waitForExistence(timeout: 5),"minYValuesTextField field not found")
        minYValuesTextField.tap()
        minYValuesTextField.clearText()
        minYValuesTextField.typeText("10")
        XCTAssertTrue(minXValuesTextField.waitForExistence(timeout: 5),"minYValuesTextField field not found")
        minXValuesTextField.tap()
        minXValuesTextField.clearText()
        minXValuesTextField.typeText("20")
        XCTAssertTrue(maxYValuesTextField.waitForExistence(timeout: 5),"minYValuesTextField field not found")
        maxYValuesTextField.tap()
        maxYValuesTextField.clearText()
        maxYValuesTextField.typeText("10030")
        XCTAssertTrue(maxXValuesTextField.waitForExistence(timeout: 5),"minYValuesTextField field not found")
        maxXValuesTextField.tap()
        maxXValuesTextField.clearText()
        maxXValuesTextField.typeText("10040")

        goBack()

        XCTAssertEqual("Horizontal Label X", onChangeResultChange().xTitle)
        XCTAssertEqual("Vertical Label Y", onChangeResultChange().yTitle)
        XCTAssertEqual(10040.0, onChangeResultChange().xMax)
        XCTAssertEqual(20.0, onChangeResultChange().xMin)
        XCTAssertEqual(10030.0, onChangeResultChange().yMax)
        XCTAssertEqual(10.0, onChangeResultChange().yMin)
    }

    func testChartLineButton() throws {
        goToChartDetailField()
        let addLineButtonIdentifier = app.buttons.matching(identifier: "AddLineIdentifier")
        let addLineButton = addLineButtonIdentifier.element(boundBy: 0)
        addLineButton.tap()
        let removeLineButtonIdentifier = app.buttons.matching(identifier: "RemoveLineIdentifier")
        let removeLineButton = removeLineButtonIdentifier.element(boundBy: 0)
        removeLineButton.tap()

        goBack()

        XCTAssertEqual(1, onChangeResultValue().valueElements?.count)
    }

    func testChartAddPoint() throws {
        goToChartDetailField()
        let addPointButtonIdentifier = app.buttons.matching(identifier: "AddPointIdentifier")
        let addPointButton = addPointButtonIdentifier.element(boundBy: 0)
        addPointButton.tap()

        let removePointButtonIdentifier = app.buttons.matching(identifier: "RemovePointIdentifier")
        let removePointButton = removePointButtonIdentifier.element(boundBy: 0)
        removePointButton.tap()

        goBack()

        XCTAssertEqual(3, onChangeResultValue().valueElements?.first?.points?.count)
    }

    func testChartPointTitleAndDescription() throws {
        goToChartDetailField()
        let titleTextFieldIdentifier = app.textFields["TitleTextFieldIdentifier"]
        titleTextFieldIdentifier.tap()
        titleTextFieldIdentifier.clearText()
        titleTextFieldIdentifier.typeText("Line Title")

        let descriptionTextFieldIdentifier = app.textFields["DescriptionTextFieldIdentifier"]
        descriptionTextFieldIdentifier.tap()
        descriptionTextFieldIdentifier.clearText()
        descriptionTextFieldIdentifier.typeText("Line Description")

        goBack()

        XCTAssertEqual("Line Title", onChangeResultValue().valueElements?[0].title)
        XCTAssertEqual("Line Description", onChangeResultValue().valueElements?[0].description)
        
        sleep(1)
        goToChartDetailField()

        XCTAssertEqual(titleTextFieldIdentifier.value as? String, "Line Title", "TextField value is incorrect after navigation")
        XCTAssertEqual(descriptionTextFieldIdentifier.value as? String, "Line Description", "TextField value is incorrect after navigation")

    }

    func testChartPointsLabel() throws {
        goToChartDetailField()
        let textFields = app.textFields.matching(identifier: "PointLabelTextFieldIdentifier")
        let texts = ["PointLabel1", "PointLabel2", "PointLabel3"]

        for i in 0..<textFields.count {
            let textField = textFields.element(boundBy: i)
            guard textField.exists else {
                XCTFail("Text field \(i) does not exist.")
                return
            }
            textField.tap()
            if i < texts.count {
                textField.typeText("\(texts[i])")
            } else {
                XCTFail("No text provided for text field \(i).")
            }
        }

        goBack()

        XCTAssertEqual("PointLabel1", onChangeResultValue().valueElements?[0].points?[0].label)
        XCTAssertEqual("PointLabel2", onChangeResultValue().valueElements?[0].points?[1].label)
        XCTAssertEqual("PointLabel3", onChangeResultValue().valueElements?[0].points?[2].label)
        
        sleep(1)
        goToChartDetailField()
        
        for i in 0..<textFields.count {
            let textField = textFields.element(boundBy: i)
            XCTAssertEqual(textField.value as? String, texts[i], "Text field \(i) value does not match expected value after navigation.")
        }
    }

    func testChartPointsValue() throws {
        goToChartDetailField()
        let horizontalPointsValueIdentifier = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue = horizontalPointsValueIdentifier.element(boundBy: 0)
        horizontalPointsValue.tap()
        horizontalPointsValue.clearText()
        horizontalPointsValue.typeText("10")

        let horizontalPointsValueIdentifier1 = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue1 = horizontalPointsValueIdentifier1.element(boundBy: 1)
        horizontalPointsValue1.tap()
        horizontalPointsValue1.clearText()
        horizontalPointsValue1.typeText("20")

        let verticalPointsValueIdentifier = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue = verticalPointsValueIdentifier.element(boundBy: 0)
        verticalPointsValue.tap()
        verticalPointsValue.clearText()
        verticalPointsValue.typeText("30")
        app.swipeUp()
        let verticalPointsValueIdentifier1 = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue1 = verticalPointsValueIdentifier1.element(boundBy: 1)
        verticalPointsValue1.tap()
        verticalPointsValue1.clearText()
        verticalPointsValue1.typeText("40")

        let horizontalPointsValueIdentifier2 = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue2 = horizontalPointsValueIdentifier2.element(boundBy: 2)
        horizontalPointsValue2.tap()
        horizontalPointsValue2.clearText()
        horizontalPointsValue2.typeText("50")

        let verticalPointsValueIdentifier2 = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue2 = verticalPointsValueIdentifier2.element(boundBy: 2)
        verticalPointsValue2.tap()
        verticalPointsValue2.clearText()
        verticalPointsValue2.typeText("60")

        goBack()

        XCTAssertEqual(10, onChangeResultValue().valueElements?[0].points?[0].x)
        XCTAssertEqual(30, onChangeResultValue().valueElements?[0].points?[0].y)
        XCTAssertEqual(20, onChangeResultValue().valueElements?[0].points?[1].x)
        XCTAssertEqual(40, onChangeResultValue().valueElements?[0].points?[1].y)
        XCTAssertEqual(50, onChangeResultValue().valueElements?[0].points?[2].x)
        XCTAssertEqual(60, onChangeResultValue().valueElements?[0].points?[2].y)
        
        sleep(1)
        goToChartDetailField()

        XCTAssertEqual(horizontalPointsValue.value as? String, "10", "TextField value is incorrect after navigation")
        XCTAssertEqual(horizontalPointsValue1.value as? String, "20", "TextField value is incorrect after navigation")
        XCTAssertEqual(verticalPointsValue.value as? String, "30", "TextField value is incorrect after navigation")
        XCTAssertEqual(verticalPointsValue1.value as? String, "40", "TextField value is incorrect after navigation")
        XCTAssertEqual(horizontalPointsValue2.value as? String, "50", "TextField value is incorrect after navigation")
        XCTAssertEqual(verticalPointsValue2.value as? String, "60", "TextField value is incorrect after navigation")
    }

}


extension ValueUnion {
    var xTitle: String? {
        return (self.dictionary as! [String: Any])["xTitle"] as? String
    }

    var yTitle: String? {
        return (self.dictionary as! [String: Any])["yTitle"] as? String
    }

    var yMin: Double? {
        return (self.dictionary as! [String: Any])["yMin"] as? Double
    }

    var yMax: Double? {
        return (self.dictionary as! [String: Any])["yMax"] as? Double
    }

    var xMin: Double? {
        return (self.dictionary as! [String: Any])["xMin"] as? Double
    }

    var xMax: Double? {
        return (self.dictionary as! [String: Any])["xMax"] as? Double
    }
}

 
