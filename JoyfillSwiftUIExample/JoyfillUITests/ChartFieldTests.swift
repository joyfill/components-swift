import XCTest
import JoyfillModel

final class ChartFieldTests: JoyfillUITestsBaseClass {

    func goToChartDetailField() {
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        app.buttons["ChartViewIdentifier"].tap()
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
        minYValuesTextField.typeText("10")
        minXValuesTextField.tap()
        minXValuesTextField.typeText("20")
        maxYValuesTextField.tap()
        maxYValuesTextField.typeText("30")
        maxXValuesTextField.tap()
        maxXValuesTextField.typeText("40")

        goBack()

        XCTAssertEqual("Horizontal Label X", onChangeResultChange().xTitle)
        XCTAssertEqual("Vertical Label Y", onChangeResultChange().yTitle)
        XCTAssertEqual(10040.0, onChangeResultChange().xMax)
        XCTAssertEqual(20.0, onChangeResultChange().xMin)
        XCTAssertEqual(10030.0, onChangeResultChange().yMax)
        XCTAssertEqual(10.0, onChangeResultChange().yMin)
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

        minYValuesTextField.tap()
        minYValuesTextField.typeText("10")
        minXValuesTextField.tap()
        minXValuesTextField.typeText("20")
        maxYValuesTextField.tap()
        maxYValuesTextField.typeText("30")
        maxXValuesTextField.tap()
        maxXValuesTextField.typeText("40")

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
        titleTextFieldIdentifier.typeText("Line Title")

        let descriptionTextFieldIdentifier = app.textFields["DescriptionTextFieldIdentifier"]
        descriptionTextFieldIdentifier.tap()
        descriptionTextFieldIdentifier.typeText("Line Description")

        goBack()

        XCTAssertEqual("Line Title", onChangeResultValue().valueElements?[0].title)
        XCTAssertEqual("Line Description", onChangeResultValue().valueElements?[0].description)

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
    }

    func testChartPointsValue() throws {
        goToChartDetailField()
        let horizontalPointsValueIdentifier = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue = horizontalPointsValueIdentifier.element(boundBy: 0)
        horizontalPointsValue.tap()
        horizontalPointsValue.typeText("10")

        let horizontalPointsValueIdentifier1 = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue1 = horizontalPointsValueIdentifier1.element(boundBy: 1)
        horizontalPointsValue1.tap()
        horizontalPointsValue1.typeText("20")

        let verticalPointsValueIdentifier = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue = verticalPointsValueIdentifier.element(boundBy: 0)
        verticalPointsValue.tap()
        verticalPointsValue.typeText("30")

        let verticalPointsValueIdentifier1 = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue1 = verticalPointsValueIdentifier1.element(boundBy: 1)
        verticalPointsValue1.tap()
        verticalPointsValue1.typeText("40")

        let horizontalPointsValueIdentifier2 = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue2 = horizontalPointsValueIdentifier2.element(boundBy: 2)
        horizontalPointsValue2.tap()
        horizontalPointsValue2.typeText("50")

        let verticalPointsValueIdentifier2 = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue2 = verticalPointsValueIdentifier2.element(boundBy: 2)
        verticalPointsValue2.tap()
        verticalPointsValue2.typeText("60")

        goBack()

        XCTAssertEqual(10, onChangeResultValue().valueElements?[0].points?[0].x)
        XCTAssertEqual(30, onChangeResultValue().valueElements?[0].points?[0].y)
        XCTAssertEqual(20, onChangeResultValue().valueElements?[0].points?[1].x)
        XCTAssertEqual(40, onChangeResultValue().valueElements?[0].points?[1].y)
        XCTAssertEqual(50, onChangeResultValue().valueElements?[0].points?[2].x)
        XCTAssertEqual(60, onChangeResultValue().valueElements?[0].points?[2].y)
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
