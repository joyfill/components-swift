import XCTest
import JoyfillModel
import Joyfill

@testable import JoyfillExample

final class OnChangeHandlerUITests: JoyfillUITestsBaseClass {
    
    func goTOCollectionView() {
        let goToTableDetailView = app.buttons.matching(identifier: "CollectionDetailViewIdentifier")
        let tapOnSecondTableView = goToTableDetailView.element(boundBy: 0)
        tapOnSecondTableView.tap()
    }

    func testNavigateToCollectionView() {
        goTOCollectionView()
        
        let updatedCells: [String: Any] = [
            "6813008e76da519a97819c69": "hello ji",
            "6813008e36be88d98ed5a90a": "6813008e634fdf79fe013b42"
        ]
        let payload: [String: Any] = [
            "rowId": "68778a33c3be6b500ec16320",
            "row": [
                "_id": "68778a33c3be6b500ec16320",
                "cells": updatedCells
            ]
        ]
        
        let change = JoyfillModel.Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowUpdate",
            _id: "67fa8d7805eb82ed29fff882",
            identifier: "template_67fa8d780ee252702a043dc2",
            fileId: "67fa8d789ae291ded87f04a0",
            pageId: "67fa8d78a51f7a3c45fdb360",
            fieldId: "687789f69f7a033dbcd82dbc",
            fieldIdentifier: "field_687789fb9283b64de42bc315",
            fieldPositionId: "687789fbce366f43c71ecd2c",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
                
        sleep(2)
        
//        XCTAssertTrue(app.staticTexts["value"] == false)
    }
}
