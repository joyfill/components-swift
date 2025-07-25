import XCTest
import JoyfillModel
import Joyfill

@testable import JoyfillExample

final class OnChangeHandlerUITests: JoyfillUITestsBaseClass {
    
    func goToCollectionView(index: Int = 0) {
        let goToTableDetailView = app.buttons.matching(identifier: "CollectionDetailViewIdentifier")
        let tapOnSecondTableView = goToTableDetailView.element(boundBy: index)
        tapOnSecondTableView.tap()
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    func drawSignatureLine() {
        let signatureCanvas = app.otherElements["SignatureCanvasIdentifier"]
        XCTAssertTrue(signatureCanvas.exists, "Signature canvas should exist")
        
        let startPoint = signatureCanvas.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.3))
        let endPoint = signatureCanvas.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.7))
        
        startPoint.press(forDuration: 0, thenDragTo: endPoint)
    }
    
    func testChangeText() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView(index: 1)
       
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("A", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("First")

        let firstValueCount = app.textViews.countMatchingValue("FirstA")
        print("Number of textViews with value \"FirstA\": \(firstValueCount)")
        XCTAssertEqual(2, firstValueCount, "Expected exactly two textViews with value 'FirstA' (one in each form)")
    }
    
    func testChangeNumberCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView(index: 1)
       
        let firstTableTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("12.2", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.clearText()
        
        firstTableTextField.typeText("12345")

        let firstValueCount = app.textFields.countMatchingValue("12345")
        print("Number of number fields with value \"12345\": \(firstValueCount)")
        XCTAssertEqual(2, firstValueCount, "Expected exactly two number fields with value '12345' (one in each form)")
    }
    
    fileprivate func selectAllMultiSlectOptions() {
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        XCTAssertGreaterThan(optionsButtons.count, 0)
        let firstOptionButton = optionsButtons.element(boundBy: 0)
        firstOptionButton.tap()
        let secOptionButton = optionsButtons.element(boundBy: 1)
        secOptionButton.tap()
        let thirdOptionButton = optionsButtons.element(boundBy: 2)
        thirdOptionButton.tap()
    }
    
    func testChangeMultiCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView(index: 1)
        
        let multiSelectionButtons = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertGreaterThan(multiSelectionButtons.count, 0)
        let firstButton = multiSelectionButtons.element(boundBy: 0)
        firstButton.tap()
        
        selectAllMultiSlectOptions()

        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()

        goBack()
        
        let multiSelectionButton = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertGreaterThan(multiSelectionButton.count, 0)
        let firstButto = multiSelectionButton.element(boundBy: 0)
        firstButto.tap()
        
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
//            XCTAssertEqual(optionButton.value as? String, "Selected")
        let optionButton = optionsButtons.element(boundBy: 0)
        let optionButton2 = optionsButtons.element(boundBy: 1)
        let optionButton3 = optionsButtons.element(boundBy: 2)
        XCTAssertEqual(optionButton.value as? String, "Not selected")
        XCTAssertEqual(optionButton2.value as? String, "Selected")
        XCTAssertEqual(optionButton3.value as? String, "Selected")
    }
    
    func testChangeDropdownCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView(index: 1)
        
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes D1", dropdownButtons.element(boundBy: 0).label)
        XCTAssertEqual("Yes D1", dropdownButtons.element(boundBy: 1).label)
        XCTAssertEqual("Yes D1", dropdownButtons.element(boundBy: 2).label)
        
        XCTAssertEqual("No D1", dropdownButtons.element(boundBy: 3).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 0)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 2)
        firstOption.tap()
        goBack()
        
        let secdropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("N/A D1", secdropdownButtons.element(boundBy: 0).label)
    }
    
    func testChangeDateCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView(index: 1)
        
        let dateFields = app.images.matching(identifier: "CalendarImageIdentifier")
        XCTAssertEqual(dateFields.count, 4, "Date fields should exist")
        
        let dateField1 = dateFields.element(boundBy: 0)
        let dateField2 = dateFields.element(boundBy: 1)
        dateField1.tap()
        dateField2.tap()
        goBack()
        
        let secDateFields = app.images.matching(identifier: "CalendarImageIdentifier")
        XCTAssertEqual(secDateFields.count, 0, "Date fields should exist")
    }
    
    func testChangeImageCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView(index: 1)
        
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        XCTAssertGreaterThan(imageButtons.count, 0, "Image buttons should exist")
        
        let firstImageButton = imageButtons.element(boundBy: 0)
        firstImageButton.tap()
        
        let uploadImageButton = app.buttons["ImageUploadImageIdentifier"]
        if uploadImageButton.exists {
            uploadImageButton.tap()
            dismissSheet()
        }
        goBack()
        
        let secImageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        XCTAssertGreaterThan(secImageButtons.count, 0, "Image buttons should exist")
        
        let imageButton = imageButtons.element(boundBy: 0)
        imageButton.tap()
        
        let allImages = app.images.matching(identifier: "DetailPageImageSelectionIdentifier")

        let circleImages = allImages.matching(NSPredicate(format: "label == %@", "circle"))

        let circleCount = circleImages.count
        XCTAssertEqual(circleCount, 1)
    }
    
}

extension XCUIElementQuery {
    func countMatchingValue(_ text: String) -> Int {
        var matchCount = 0
        for index in 0..<self.count {
            let element = self.element(boundBy: index)
            if let value = element.value as? String, value == text {
                matchCount += 1
            }
        }
        return matchCount
    }
}
