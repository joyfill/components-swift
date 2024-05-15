import XCTest

final class DateTimeFieldTests: JoyfillUITestsBaseClass {
    
    func testDatePickerr() {
        app.swipeUp()
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(firstDatePicker.exists, "The first date picker does not exist.")
        firstDatePicker.tap()
        
        let dayWheel = firstDatePicker.pickerWheels.element(boundBy: 0)
        dayWheel.adjust(toPickerWheelValue: "11")
        
        let monthWheel = firstDatePicker.pickerWheels.element(boundBy: 1)
        monthWheel.adjust(toPickerWheelValue: "June")
        
        let yearWheel = firstDatePicker.pickerWheels.element(boundBy: 2)
        yearWheel.adjust(toPickerWheelValue: "2026")
    }
    func testTimePickerrr() {
        app.swipeUp()
        
        let secondDatePicker = app.datePickers.element(boundBy: 1)
        XCTAssertTrue(secondDatePicker.exists, "The second date picker does not exist.")
        secondDatePicker.tap()
        
        let hourWheel = secondDatePicker.pickerWheels.element(boundBy: 0)
        hourWheel.adjust(toPickerWheelValue: "5")
        
        let minuteWheel = secondDatePicker.pickerWheels.element(boundBy: 1)
        minuteWheel.adjust(toPickerWheelValue: "30")
    }
    func testDateTimePicker() {
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        
        let thirdDatePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(thirdDatePicker.exists, "The third date picker does not exist.")
        thirdDatePicker.tap()
        
        let dateWheel = thirdDatePicker.pickerWheels.element(boundBy: 0)
        dateWheel.adjust(toPickerWheelValue: "21 Apr")
        
        let hourWheel = thirdDatePicker.pickerWheels.element(boundBy: 1)
        hourWheel.adjust(toPickerWheelValue: "5")
        
        let minuteWheel = thirdDatePicker.pickerWheels.element(boundBy: 2)
        minuteWheel.adjust(toPickerWheelValue: "30")
    }
}
