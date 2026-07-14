//
//  LandScapeMode.swift
//  JoyfillExample
//
//  Created by Vivek Mac on 14/07/26.
//

import XCTest
import JoyfillModel

final class LandscapeModeUITestCases: JoyfillUITestsBaseClass {

    override func getJSONFileNameForTest() -> String {
        return "LandscapeMode"
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        XCUIDevice.shared.orientation = .landscapeLeft
        _ = waitUntil(5) { self.app.buttons["PageNavigationIdentifier"].isHittable }
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        try super.tearDownWithError()
    }

    // MARK: - Navigation

    private func goToPage(_ name: String) {
        let navButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertTrue(navButton.waitForExistence(timeout: 10), "Page navigation button should exist")
        navButton.tap()

        let rows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let pageButton = rows.element(matching: NSPredicate(format: "label == %@", name))

        let window = app.windows.firstMatch
        let dragStart = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.72))
        let dragEnd = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.38))
        var attempts = 0
        while !(pageButton.exists && pageButton.isHittable) && attempts < 12 {
            dragStart.press(forDuration: 0.05, thenDragTo: dragEnd)
            _ = waitUntil(1) { pageButton.exists && pageButton.isHittable }
            attempts += 1
        }

        XCTAssertTrue(pageButton.waitForExistence(timeout: 5), "\(name) should be selectable in the navigation sheet")
        pageButton.tap()
        _ = waitUntil(3) { self.app.buttons["PageNavigationIdentifier"].exists }
    }

    // MARK: - Text (Page 2)

    func testTextFieldInLandscape() {
        goToPage("Page 2")
        let textField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(textField.waitForExistence(timeout: 5), "Text field should exist")
        textField.tap()
        textField.typeText("Hello Landscape\n")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual("Hello Landscape", onChangeResultValue().text)
    }

    // MARK: - Textarea / multiline (Page 3)

    func testMultilineFieldInLandscape() {
        goToPage("Page 3")
        let multiline = app.textViews["MultilineTextFieldIdentifier"]
        XCTAssertTrue(multiline.waitForExistence(timeout: 5), "Multiline field should exist")
        multiline.tap()
        multiline.typeText("Line one")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.0))
        XCTAssertEqual("Line one", onChangeResultValue().multilineText)
    }

    // MARK: - Number (Page 4)

    func testNumberFieldInLandscape() {
        goToPage("Page 4")
        let numberField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(numberField.waitForExistence(timeout: 5), "Number field should exist")
        numberField.tap()
        numberField.typeText("42")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual(42.0, onChangeResultValue().number)
    }

    // MARK: - Date + Time (Page 5)  — the landscape freeze case

    func testDateTimeFieldInLandscape() {
        goToPage("Page 5")
        let selectPrompt = app.staticTexts["Select a Date -"]
        XCTAssertTrue(selectPrompt.waitForExistence(timeout: 5), "Empty date prompt should exist")
        selectPrompt.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        let initialValue = onChangeResultValue().number
        XCTAssertNotNil(initialValue, "Date field should commit a timestamp value")

        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(dateButton.waitForExistence(timeout: 5), "Date value button should appear after selecting a date")
        dateButton.tap()
        let picker = app.datePickers.firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "Date+time picker should present in landscape without freezing")

        func isDayLabel(_ label: String) -> Bool {
            guard !label.contains(":") else { return false }
            return label.split(whereSeparator: { !$0.isNumber }).contains {
                if let day = Int($0), (1...31).contains(day) { return true }
                return false
            }
        }
        let dayButtons = picker.buttons.allElementsBoundByIndex.filter {
            $0.exists && isDayLabel($0.label)
        }
        let dayButton = dayButtons.first { !$0.isSelected } ?? dayButtons.first
        XCTAssertNotNil(dayButton, "Calendar should offer a day button to change the date")
        dayButton?.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))

        picker.swipeUp()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))

        let timeButton = picker.buttons.allElementsBoundByIndex.first {
            $0.exists && $0.label.contains(":")
        }
        XCTAssertNotNil(timeButton, "Inline picker should expose a time button to change the time")
        timeButton?.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        let wheels = app.pickerWheels
        XCTAssertGreaterThan(wheels.count, 0, "Tapping the time button should reveal time wheels")
        let ampmWheel = wheels.element(boundBy: wheels.count - 1)
        let currentPeriod = (ampmWheel.value as? String) ?? "PM"
        ampmWheel.adjust(toPickerWheelValue: currentPeriod.contains("AM") ? "PM" : "AM")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))

        let dismissRegion = app.buttons["PopoverDismissRegion"]
        if dismissRegion.exists {
            dismissRegion.tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5)).tap()
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))

        let closeButton = app.buttons["Close"]
        if closeButton.exists {
            closeButton.tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        let updatedValue = onChangeResultValue().number
        XCTAssertNotNil(updatedValue, "Date field should still hold a timestamp after editing")
        XCTAssertNotEqual(initialValue, updatedValue, "Changing date & time in the picker should update the committed value")
    }

    // MARK: - Dropdown (Page 6)

    func testDropdownFieldInLandscape() {
        goToPage("Page 6")
        let dropdown = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        XCTAssertTrue(dropdown.waitForExistence(timeout: 5), "Dropdown field should exist")
        dropdown.tap()
        let yesOption = app.buttons.matching(identifier: "DropdownoptionIdentifier")
            .element(matching: NSPredicate(format: "label == %@", "Yes"))
        XCTAssertTrue(yesOption.waitForExistence(timeout: 3), "Dropdown options should appear")
        yesOption.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual("Yes", dropdown.label, "Dropdown should show the selected value")
        XCTAssertEqual("6a549f7fb51131ecc3540ba0", onChangeResultValue().text, "Backend should receive the 'Yes' option id")
    }

    // MARK: - MultiSelect (multi) (Page 7)

    func testMultiSelectFieldInLandscape() {
        goToPage("Page 7")
        let firstOption = app.buttons.matching(identifier: "MultiSelectionIdenitfier").firstMatch
        XCTAssertTrue(firstOption.waitForExistence(timeout: 5), "Multi-select options should exist")
        firstOption.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        let selected = onChangeResultValue().multiSelector
        XCTAssertNotNil(selected, "Multi-select value should not be nil")
        XCTAssertTrue(selected?.contains("6a549f7fee329b7eeba3946b") == true, "Should contain the 'Yes' option id")
    }

    // MARK: - MultiSelect (single) (Page 8)

    func testSingleChoiceFieldInLandscape() {
        goToPage("Page 8")
        let firstOption = app.buttons.matching(identifier: "SingleSelectionIdentifier").firstMatch
        XCTAssertTrue(firstOption.waitForExistence(timeout: 5), "Single-choice options should exist")
        firstOption.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        let selected = onChangeResultValue().multiSelector
        XCTAssertNotNil(selected, "Single-choice value should not be nil")
        XCTAssertTrue(selected?.contains("6a549f7f826a2fa0be596cbe") == true, "Should contain the 'Yes' option id")
    }

    // MARK: - Signature (Page 9)

    func testSignatureFieldInLandscape() {
        goToPage("Page 9")
        let signatureButton = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: 0)
        XCTAssertTrue(signatureButton.waitForExistence(timeout: 5), "Signature button should exist")
        signatureButton.tap()

        let canvas = app.otherElements["CanvasIdentifier"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5), "Signature canvas should appear")
        canvas.tap()
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 1))
        start.press(forDuration: 0.1, thenDragTo: end)

        app.buttons["SaveSignatureIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse((onChangeResultValue().signatureURL ?? "").isEmpty, "Signature URL should be committed")
    }

    // MARK: - Image (Page 1)

    func testImageFieldInLandscape() {
        goToPage("Page 1")
        let imageButton = app.buttons.matching(identifier: "ImageIdentifier").element(boundBy: 0)
        XCTAssertTrue(imageButton.waitForExistence(timeout: 5), "Image field should exist")
        imageButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.0))
        XCTAssertEqual(1, onChangeResultValue().imageURLs?.count, "One image should be uploaded")
    }

    // MARK: - Table (Page 10)

    func testTableFieldInLandscape() {
        goToPage("Page 10")
        let detail = app.buttons.matching(identifier: "TableDetailViewIdentifier").firstMatch
        XCTAssertTrue(detail.waitForExistence(timeout: 5), "Table detail button should exist")
        detail.tap()

        let textCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(textCell.waitForExistence(timeout: 5), "Table text cell should exist")
        textCell.tap()
        textCell.clearText()
        textCell.typeText("Cell1")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual("Cell1", textCell.value as? String, "Cell should hold the typed text")
        goBack()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        let committed = onChangeResultValue().valueElements?.contains {
            $0.cells?["6a549f7f5b9e6b25aac10b1f"]?.text == "Cell1"
        } ?? false
        XCTAssertTrue(committed, "Text cell edit should commit to the model via onChange")
    }

    // MARK: - Chart (Page 11)

    func testChartFieldInLandscape() {
        goToPage("Page 11")
        let chartButton = app.buttons.matching(identifier: "ChartViewIdentifier").firstMatch
        XCTAssertTrue(chartButton.waitForExistence(timeout: 5), "Chart view button should exist")
        chartButton.tap()

        let addLine = app.buttons["AddLineIdentifier"]
        XCTAssertTrue(addLine.waitForExistence(timeout: 5), "Add-line button should exist")
        addLine.tap()

        let horizontal = app.textFields.matching(identifier: "HorizontalPointsValue").element(boundBy: 0)
        let vertical = app.textFields.matching(identifier: "VerticalPointsValue").element(boundBy: 0)
        XCTAssertTrue(horizontal.waitForExistence(timeout: 5), "Horizontal coordinate field should exist")
        horizontal.tap()
        horizontal.typeText("11")
        vertical.tap()
        vertical.typeText("22")
        app.dismissKeyboardIfVisible()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertNotNil(onChangeResultValue().valueElements?.first?.points?.first, "A chart point should be committed")
        goBack()
    }

    // MARK: - Collection (Page 12)

    func testCollectionFieldInLandscape() {
        goToPage("Page 12")
        let detail = app.buttons.matching(identifier: "CollectionDetailViewIdentifier").firstMatch
        XCTAssertTrue(detail.waitForExistence(timeout: 5), "Collection detail button should exist")
        detail.tap()

        let addRow = app.buttons.matching(identifier: "TableAddRowIdentifier").firstMatch
        XCTAssertTrue(addRow.waitForExistence(timeout: 5), "Add-row button should exist")
        addRow.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        let textCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(textCell.waitForExistence(timeout: 5), "Collection text cell should exist")
        textCell.tap()
        textCell.typeText("C")
        app.dismissKeyboardIfVisible()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual("C", textCell.value as? String, "Cell should hold the typed text")
        goBack()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        let committed = onChangeResultValue().valueElements?.contains {
            $0.cells?["6813008e76da519a97819c69"]?.text == "C"
        } ?? false
        XCTAssertTrue(committed, "Text cell edit should commit to the model via onChange")
    }

    // MARK: - Table row-edit form (Page 10)

    func testTableRowFormInLandscape() {
        goToPage("Page 10")
        let detail = app.buttons.matching(identifier: "TableDetailViewIdentifier").firstMatch
        XCTAssertTrue(detail.waitForExistence(timeout: 5), "Table detail button should exist")
        detail.tap()

        openRowEditForm(selectAllIdentifier: "SelectAllRowSelectorButton")

        assertRowFormFieldsVisibleAndScrollable([
            "EditRowsTextFieldIdentifier",
            "EditRowsDropdownFieldIdentifier",
            "EditRowsImageFieldIdentifier",
            "EditRowsNumberFieldIdentifier",
            "EditRowsDateFieldIdentifier",
            "EditRowsBarcodeFieldIdentifier",
            "EditRowsSignatureFieldIdentifier",
        ])
    }

    // MARK: - Collection row-edit form (Page 12)

    func testCollectionRowFormInLandscape() {
        goToPage("Page 12")
        let detail = app.buttons.matching(identifier: "CollectionDetailViewIdentifier").firstMatch
        XCTAssertTrue(detail.waitForExistence(timeout: 5), "Collection detail button should exist")
        detail.tap()

        let addRow = app.buttons.matching(identifier: "TableAddRowIdentifier").firstMatch
        XCTAssertTrue(addRow.waitForExistence(timeout: 5), "Add-row button should exist")
        addRow.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))

        openRowEditForm(selectAllIdentifier: "SelectParentAllRowSelectorButton")

        assertRowFormFieldsVisibleAndScrollable([
            "EditRowsTextFieldIdentifier",
            "EditRowsDropdownFieldIdentifier",
            "EditRowsImageFieldIdentifier",
            "EditRowsDateFieldIdentifier",
            "EditRowsBarcodeFieldIdentifier",
            "EditRowsSignatureFieldIdentifier",
        ])
    }

    // MARK: - Row-form helpers

    private func openRowEditForm(selectAllIdentifier: String) {
        let selectAll = app.images[selectAllIdentifier]
        XCTAssertTrue(selectAll.waitForExistence(timeout: 5), "Row selector (\(selectAllIdentifier)) should exist")
        selectAll.tap()

        let moreButton = app.buttons["TableMoreButtonIdentifier"]
        XCTAssertTrue(moreButton.waitForExistence(timeout: 5), "More button should appear after selecting rows")
        moreButton.tap()

        let editRows = app.buttons["TableEditRowsIdentifier"]
        XCTAssertTrue(editRows.waitForExistence(timeout: 5), "Edit-rows option should exist in the More menu")
        editRows.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    }

    private func assertRowFormFieldsVisibleAndScrollable(_ expected: [String]) {
        for id in expected {
            XCTAssertTrue(rowFormField(id).waitForExistence(timeout: 5), "Row form should contain \(id)")
        }

        let lastField = rowFormField(expected.last!)
        var attempts = 0
        while !isOnScreen(lastField) && attempts < 10 {
            scrollSheetUp()
            _ = waitUntil(1) { self.isOnScreen(lastField) }
            attempts += 1
        }
        XCTAssertTrue(isOnScreen(lastField),
                      "The last field (\(expected.last!)) should be reachable — visible already or after scrolling")
    }

    private func rowFormField(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func scrollSheetUp() {
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    private func isOnScreen(_ element: XCUIElement) -> Bool {
        guard element.exists else { return false }
        let frame = element.frame
        guard frame.height > 0 else { return false }
        let window = app.windows.firstMatch.frame
        return frame.minY >= window.minY && frame.maxY <= window.maxY
    }
}
