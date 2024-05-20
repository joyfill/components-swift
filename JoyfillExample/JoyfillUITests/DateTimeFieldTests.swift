import XCTest

final class DateTimeFieldTests: JoyfillUITestsBaseClass {
    
    func testDatePicker() {
        app.swipeUp()

        let firstDatePicker = app.datePickers.matching(identifier: "DateIdenitfier-MM/DD/YYYY")
        let firstPicker = firstDatePicker.element(boundBy: 0)
        firstPicker.tap()

        let dayWheel = firstDatePicker.pickerWheels.element(boundBy: 0)
        dayWheel.adjust(toPickerWheelValue: "11")
        
        let monthWheel = firstDatePicker.pickerWheels.element(boundBy: 1)
        monthWheel.adjust(toPickerWheelValue: "June")
        
        let yearWheel = firstDatePicker.pickerWheels.element(boundBy: 2)
        yearWheel.adjust(toPickerWheelValue: "2026")
        
        XCTAssertEqual(1781116200000.0, onChangeResultValue().number!)
        XCTAssertEqual(onChangeOptionalResult()!, expectedChange(for: singleSelectionFieldOnChange)!)
    }

    func testTimePicker() {
        app.swipeUp()
        
        let secondDatePicker = app.datePickers.matching(identifier: "DateIdenitfier-hh:mma")
        let secondPicker = app.datePickers.element(boundBy: 1)
        secondPicker.tap()

        let hourWheel = secondDatePicker.pickerWheels.element(boundBy: 0)
        hourWheel.adjust(toPickerWheelValue: "5")
        
        let minuteWheel = secondDatePicker.pickerWheels.element(boundBy: 1)
        minuteWheel.adjust(toPickerWheelValue: "30")
        XCTAssertEqual(946728000000.0, onChangeResultValue().number!)
        XCTAssertEqual(onChangeOptionalResult()!, expectedChange(for: singleSelectionFieldOnChange)!)
    }

//    func testDateTimePicker() {
//        app.swipeUp()
//        app.swipeUp()
//
//        let thirdDatePicker = app.datePickers.matching(identifier: "DateIdenitfier-MM/DD/YYYY hh:mma")
//        let thirdPicker = app.datePickers.element(boundBy: 1)
//        thirdPicker.tap()
//        
//        let hourWheel = thirdDatePicker.pickerWheels.element(boundBy: 1)
//        hourWheel.adjust(toPickerWheelValue: "5")
//
//        let minuteWheel = thirdDatePicker.pickerWheels.element(boundBy: 2)
//        minuteWheel.adjust(toPickerWheelValue: "30")
//
//        let dateWheel = thirdDatePicker.pickerWheels.element(boundBy: 0)
//        dateWheel.adjust(toPickerWheelValue: "Sat, 7 Apr")
//    }
}
