//
//  JoyfillTests.swift
//  JoyfillTests
//
//  Created by Vikash on 25/04/24.
//

import XCTest
import Foundation
import SwiftUI
import JoyfillModel

final class JoyfillTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testJoyDoc() {
        let path = Bundle.main.path(forResource: "Joydocjson", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        
        var document = JoyDoc(dictionary: dict)
        
        XCTAssertEqual(document.id, "6629fc6367b3a40644096182")
        XCTAssertEqual(document.type, "document")
        XCTAssertEqual(document.stage, "published")
        XCTAssertEqual(document.source, "template_6629fab38559d3017b0308b0")
        XCTAssertTrue(document.metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.identifier, "doc_6629fc6367b3a40644096182")
        XCTAssertEqual(document.name, "All Fields Template")
        XCTAssertEqual(document.createdOn, 1714027619864)
        
        // Test cases for file fields
        XCTAssertEqual(document.files.count, 1)
        XCTAssertEqual(document.files[0].id, "6629fab3c0ba3fb775b4a55c")
        XCTAssertTrue(document.files[0].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.files[0].name, "All Fields Template")
        XCTAssertEqual(document.files[0].version, 1)
        XCTAssertTrue(document.files[0].styles!.dictionary.isEmpty)
        XCTAssertEqual(document.files[0].pageOrder, ["6629fab320fca7c8107a6cf6"])
        XCTAssertTrue(document.files[0].views!.isEmpty)
        
        // Test cases for file fields
        XCTAssertEqual(document.fields.count, 16)
        
        //Test cases for first(image) field
        XCTAssertEqual(document.fields[0].type, "image")
        XCTAssertEqual(document.fields[0].id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(document.fields[0].identifier, "field_6629fab87c5c8ff831b8d223")
        XCTAssertEqual(document.fields[0].title, "Image")
        XCTAssertEqual(document.fields[0].description, "")
        XCTAssertEqual(document.fields[0].value?.valueElements?[0].id , "6629fad9a6d0c81c8c217fc5")
        XCTAssertEqual(document.fields[0].value?.valueElements?[0].url, "https://s3.amazonaws.com/docspace.production.documents/6628f1034892618fc118503b/documents/template_6629fab38559d3017b0308b0/6629fad945f22ce76d678f37-1714027225742.png")
        XCTAssertEqual(document.fields[0].value?.valueElements?[0].fileName, "6629fad945f22ce76d678f37-1714027225742.png")
        XCTAssertEqual(document.fields[0].value?.valueElements?[0].filePath, "6628f1034892618fc118503b/documents/template_6629fab38559d3017b0308b0")
        XCTAssertEqual(document.fields[0].required, false)
        XCTAssertEqual(document.fields[0].tipTitle, "")
        XCTAssertEqual(document.fields[0].tipDescription, "")
        XCTAssertEqual(document.fields[0].tipVisible, false)
        XCTAssertTrue(document.fields[0].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[0].multi, false)
        XCTAssertEqual(document.fields[0].file, "6629fab3c0ba3fb775b4a55c")
        
        //Test cases for second(block) field
        XCTAssertEqual(document.fields[1].type, "block")
        XCTAssertEqual(document.fields[1].id, "6629fad980958bff0608cd4a")
        XCTAssertEqual(document.fields[1].identifier, "field_6629fadcfc73f30cbb7b785a")
        XCTAssertEqual(document.fields[1].title, "Heading Text")
        XCTAssertEqual(document.fields[1].description, "")
        XCTAssertEqual(document.fields[1].value?.text, "Form View")
        XCTAssertEqual(document.fields[1].required, false)
        XCTAssertEqual(document.fields[1].tipTitle, "")
        XCTAssertEqual(document.fields[1].tipDescription, "")
        XCTAssertEqual(document.fields[1].tipVisible, false)
        XCTAssertTrue(document.fields[1].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[1].file, "6629fab3c0ba3fb775b4a55c")
        
        //Test cases for third(block) field
        XCTAssertEqual(document.fields[2].type, "block")
        XCTAssertEqual(document.fields[2].id, "6629faf0868164d68b4cf359")
        XCTAssertEqual(document.fields[2].identifier, "field_6629faf7fb9bfd2cfc6bb830")
        XCTAssertEqual(document.fields[2].title, "Display Text")
        XCTAssertEqual(document.fields[2].description, "")
        XCTAssertEqual(document.fields[2].value?.text, "All Fields ")
        XCTAssertEqual(document.fields[2].required, false)
        XCTAssertEqual(document.fields[2].tipTitle, "")
        XCTAssertEqual(document.fields[2].tipDescription, "")
        XCTAssertEqual(document.fields[2].tipVisible, false)
        XCTAssertTrue(document.fields[2].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[2].file, "6629fab3c0ba3fb775b4a55c")
        
        //Test cases for fourth(emptyspace) field
        XCTAssertEqual(document.fields[3].type, "block")
        XCTAssertEqual(document.fields[3].id, "6629fb050c62b1fe457b58e0")
        XCTAssertEqual(document.fields[3].identifier, "field_6629fb0b3079250a86dac94f")
        XCTAssertEqual(document.fields[3].title, "Empty Space")
        XCTAssertEqual(document.fields[3].description, "")
        XCTAssertEqual(document.fields[3].value?.text, "")
        XCTAssertEqual(document.fields[3].required, false)
        XCTAssertEqual(document.fields[3].tipTitle, "")
        XCTAssertEqual(document.fields[3].tipDescription, "")
        XCTAssertEqual(document.fields[3].tipVisible, false)
        XCTAssertTrue(document.fields[3].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[3].file, "6629fab3c0ba3fb775b4a55c")

        // Test cases for the fifth (text) field
        XCTAssertEqual(document.fields[4].type, "text")
        XCTAssertEqual(document.fields[4].id, "6629fb1d92a76d06750ca4a1")
        XCTAssertEqual(document.fields[4].identifier, "field_6629fb20c9e72451c769df47")
        XCTAssertEqual(document.fields[1].title, "Heading Text")
        XCTAssertEqual(document.fields[4].description, "")
        XCTAssertEqual(document.fields[4].value?.text, "Hello sir")
        XCTAssertEqual(document.fields[4].required, false)
        XCTAssertEqual(document.fields[4].tipTitle, "")
        XCTAssertEqual(document.fields[4].tipDescription, "")
        XCTAssertEqual(document.fields[4].tipVisible, false)
        XCTAssertTrue(document.fields[4].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[4].file, "6629fab3c0ba3fb775b4a55c")

        // Test cases for the sixth (multiline text) field
        XCTAssertEqual(document.fields[5].type, "textarea")
        XCTAssertEqual(document.fields[5].id, "6629fb2b9a487ce1c1f35f6c")
        XCTAssertEqual(document.fields[5].identifier, "field_6629fb2feff29e90331e4e8e")
        XCTAssertEqual(document.fields[5].title, "Multiline Text")
        XCTAssertEqual(document.fields[5].description, "")
        XCTAssertEqual(document.fields[5].value?.text, "Hello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir")
        XCTAssertEqual(document.fields[5].required, false)
        XCTAssertEqual(document.fields[5].tipTitle, "")
        XCTAssertEqual(document.fields[5].tipDescription, "")
        XCTAssertEqual(document.fields[5].tipVisible, false)
        XCTAssertTrue(document.fields[5].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[5].file, "6629fab3c0ba3fb775b4a55c")

        // Test cases for the seventh (number) field
        XCTAssertEqual(document.fields[6].type, "number")
        XCTAssertEqual(document.fields[6].id, "6629fb3df03de10b26270ab3")
        XCTAssertEqual(document.fields[6].identifier, "field_6629fb3fabb87e37c9578b8b")
        XCTAssertEqual(document.fields[6].title, "Number")
        XCTAssertEqual(document.fields[6].description, "")
        XCTAssertEqual(document.fields[6].value?.number, 98789)
        XCTAssertEqual(document.fields[6].required, false)
        XCTAssertEqual(document.fields[6].tipTitle, "")
        XCTAssertEqual(document.fields[6].tipDescription, "")
        XCTAssertEqual(document.fields[6].tipVisible, false)
        XCTAssertTrue(document.fields[6].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[6].file, "6629fab3c0ba3fb775b4a55c")

        // Test cases for the eight (date) field
        XCTAssertEqual(document.fields[7].type, "date")
        XCTAssertEqual(document.fields[7].id, "6629fb44c79bb16ce072d233")
        XCTAssertEqual(document.fields[7].identifier, "field_6629fb44309fbfe84376095e")
        XCTAssertEqual(document.fields[7].title, "Date")
        XCTAssertEqual(document.fields[7].description, "")
        XCTAssertEqual(document.fields[7].value?.number, 1712255400000)
        XCTAssertEqual(document.fields[7].required, false)
        XCTAssertEqual(document.fields[7].tipTitle, "")
        XCTAssertEqual(document.fields[7].tipDescription, "")
        XCTAssertEqual(document.fields[7].tipVisible, false)
        XCTAssertTrue(document.fields[7].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[7].file, "6629fab3c0ba3fb775b4a55c")

        // Test cases for the ninth (time) field
        XCTAssertEqual(document.fields[8].type, "date")
        XCTAssertEqual(document.fields[8].id, "6629fb638e230f348d0a8682")
        XCTAssertEqual(document.fields[8].identifier, "field_6629fb669a6d216e2a9c8dcd")
        XCTAssertEqual(document.fields[8].title, "Time")
        XCTAssertEqual(document.fields[8].description, "")
        XCTAssertEqual(document.fields[8].value?.number, 1713984174769)
        XCTAssertEqual(document.fields[8].required, false)
        XCTAssertEqual(document.fields[8].tipTitle, "")
        XCTAssertEqual(document.fields[8].tipDescription, "")
        XCTAssertEqual(document.fields[8].tipVisible, false)
        XCTAssertTrue(document.fields[8].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[8].file, "6629fab3c0ba3fb775b4a55c")

        // Test cases for the tenth (date time) field
        XCTAssertEqual(document.fields[9].type, "date")
        XCTAssertEqual(document.fields[9].id, "6629fb6ec5d88d3aadf548ca")
        XCTAssertEqual(document.fields[9].identifier, "field_6629fb74e6c43707ad6101f7")
        XCTAssertEqual(document.fields[9].title, "Date Time")
        XCTAssertEqual(document.fields[9].description, "")
        XCTAssertEqual(document.fields[9].value?.number, 1712385780000)
        XCTAssertEqual(document.fields[9].required, false)
        XCTAssertEqual(document.fields[9].tipTitle, "")
        XCTAssertEqual(document.fields[9].tipDescription, "")
        XCTAssertEqual(document.fields[9].tipVisible, false)
        XCTAssertTrue(document.fields[9].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[9].file, "6629fab3c0ba3fb775b4a55c")
        
        // Test cases for the eleventh (dropdown) field
        XCTAssertEqual(document.fields[10].type, "dropdown")
        XCTAssertEqual(document.fields[10].id, "6629fb77593e3791638628bb")
        XCTAssertEqual(document.fields[10].identifier, "field_6629fb8e57f251ebbbc8c915")
        XCTAssertEqual(document.fields[10].title, "Dropdown")
        XCTAssertEqual(document.fields[10].description, "")
        XCTAssertEqual(document.fields[10].value?.text, "6628f2e183591f3efa7f76f9")
        XCTAssertEqual(document.fields[10].required, false)
        XCTAssertEqual(document.fields[10].tipTitle, "")
        XCTAssertEqual(document.fields[10].tipDescription, "")
        XCTAssertEqual(document.fields[10].tipVisible, false)
        XCTAssertTrue(document.fields[10].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[10].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(document.fields[10].options?.count, 3)
        XCTAssertEqual(document.fields[10].options?[0].id, "6628f2e183591f3efa7f76f9")
        XCTAssertEqual(document.fields[10].options?[1].id, "6628f2e15cea1b971f6a9383")
        XCTAssertEqual(document.fields[10].options?[2].id, "6628f2e1817f03440bc70a46")

        // Test cases for the twelve (multiple choice) field
        XCTAssertEqual(document.fields[11].type, "multiSelect")
        XCTAssertEqual(document.fields[11].id, "6629fb9f4d912053577652b1")
        XCTAssertEqual(document.fields[11].identifier, "field_6629fbb02b40c2f4d0c95b38")
        XCTAssertEqual(document.fields[11].title, "Multiple Choice")
        XCTAssertEqual(document.fields[11].description, "")
        XCTAssertEqual(document.fields[11].value?.multiSelector, ["6628f2e1d0c98c6987cc6021", "6628f2e19c3cba4fdf9e5f19"])
        XCTAssertEqual(document.fields[11].required, false)
        XCTAssertEqual(document.fields[11].tipTitle, "")
        XCTAssertEqual(document.fields[11].tipDescription, "")
        XCTAssertEqual(document.fields[11].tipVisible, false)
        XCTAssertTrue(document.fields[11].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[11].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(document.fields[11].options?.count, 3)
        XCTAssertEqual(document.fields[11].options?[0].id, "6628f2e1d0c98c6987cc6021")
        XCTAssertEqual(document.fields[11].options?[1].id, "6628f2e19c3cba4fdf9e5f19")
        XCTAssertEqual(document.fields[11].options?[2].id, "6628f2e1679bcf815adfa0f6")

        // Test cases for the thirteen (single choice) field
        XCTAssertEqual(document.fields[12].type, "multiSelect")
        XCTAssertEqual(document.fields[12].id, "6629fbb2bf4f965b9d04f153")
        XCTAssertEqual(document.fields[12].identifier, "field_6629fbb5b16c74b78381af3b")
        XCTAssertEqual(document.fields[12].title, "Single Choice")
        XCTAssertEqual(document.fields[12].description, "")
        XCTAssertEqual(document.fields[12].value?.multiSelector, ["6628f2e1fae456e6b850e85e"])
        XCTAssertEqual(document.fields[12].required, false)
        XCTAssertEqual(document.fields[12].tipTitle, "")
        XCTAssertEqual(document.fields[12].tipDescription, "")
        XCTAssertEqual(document.fields[12].tipVisible, false)
        XCTAssertTrue(document.fields[12].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[12].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(document.fields[12].options?.count, 3)
        XCTAssertEqual(document.fields[12].options?[0].id, "6628f2e1fae456e6b850e85e")
        XCTAssertEqual(document.fields[12].options?[1].id, "6628f2e13e1e340a51d9ecca")
        XCTAssertEqual(document.fields[12].options?[2].id, "6628f2e16bf0362dd5498eb4")

        // Test cases for the fourteen (signature) field
        XCTAssertEqual(document.fields[13].type, "signature")
        XCTAssertEqual(document.fields[13].id, "6629fbb8cd16c0c4d308a252")
        XCTAssertEqual(document.fields[13].identifier, "field_6629fbbcb1f415665455fea4")
        XCTAssertEqual(document.fields[13].title, "Signature")
        XCTAssertEqual(document.fields[13].description, "")
        XCTAssertEqual(document.fields[13].value?.signatureURL, "data:image/png;base64,iVBOR")
        XCTAssertEqual(document.fields[13].required, false)
        XCTAssertEqual(document.fields[13].tipTitle, "")
        XCTAssertEqual(document.fields[13].tipDescription, "")
        XCTAssertEqual(document.fields[13].tipVisible, false)
        XCTAssertTrue(document.fields[13].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[13].file, "6629fab3c0ba3fb775b4a55c")

        // Test cases for the fifteen (table) field
        XCTAssertEqual(document.fields[14].type, "table")
        XCTAssertEqual(document.fields[14].id, "6629fbc0d449f4216e871e3f")
        XCTAssertEqual(document.fields[14].identifier, "field_6629fbc7915c00c8678c9430")
        XCTAssertEqual(document.fields[14].title, "Table")
        XCTAssertEqual(document.fields[14].description, "")
        XCTAssertEqual(document.fields[14].required, false)
        XCTAssertEqual(document.fields[14].tipTitle, "")
        XCTAssertEqual(document.fields[14].tipDescription, "")
        XCTAssertEqual(document.fields[14].tipVisible, false)
        XCTAssertTrue(document.fields[14].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[14].file, "6629fab3c0ba3fb775b4a55c")
        
        XCTAssertEqual(document.fields[14].value?.valueElements?.count, 3)
        XCTAssertEqual(document.fields[14].value?.valueElements?[0].id, "6628f2e142ffeada4206bbdb")
        XCTAssertEqual(document.fields[14].value?.valueElements?[0].deleted, false)
        XCTAssertEqual(document.fields[14].value?.valueElements?[0].cells?["6628f2e11a2b28119985cfbb"]?.text, "Hello")
        XCTAssertEqual(document.fields[14].value?.valueElements?[0].cells?["6628f2e123ca77fa82a2c45e"]?.text, "6628f2e1846cc78241aa6b11")
        
        XCTAssertEqual(document.fields[14].value?.valueElements?[1].id, "6628f2e1a6b5e93e8dde45f8")
        XCTAssertEqual(document.fields[14].value?.valueElements?[1].deleted, false)
        XCTAssertEqual(document.fields[14].value?.valueElements?[1].cells?["6628f2e11a2b28119985cfbb"]?.text, "His")
        XCTAssertEqual(document.fields[14].value?.valueElements?[1].cells?["6628f2e123ca77fa82a2c45e"]?.text, "6628f2e1c12db4664e9eb38f")
        
        XCTAssertEqual(document.fields[14].value?.valueElements?[2].id, "6628f2e1750679d671be36b8")
        XCTAssertEqual(document.fields[14].value?.valueElements?[2].deleted, false)
        XCTAssertEqual(document.fields[14].value?.valueElements?[2].cells?["6628f2e11a2b28119985cfbb"]?.text, "His")
        XCTAssertEqual(document.fields[14].value?.valueElements?[2].cells?["6628f2e123ca77fa82a2c45e"]?.text, "6628f2e1c12db4664e9eb38f")
        
        XCTAssertEqual(document.fields[14].rowOrder?.count, 3)
        XCTAssertEqual(document.fields[14].rowOrder?[0], "6628f2e142ffeada4206bbdb")
        XCTAssertEqual(document.fields[14].rowOrder?[1], "6628f2e1a6b5e93e8dde45f8")
        XCTAssertEqual(document.fields[14].rowOrder?[2], "6628f2e1750679d671be36b8")
        
        XCTAssertEqual(document.fields[14].tableColumns?.count, 3)
        XCTAssertEqual(document.fields[14].tableColumns?[0].id, "6628f2e11a2b28119985cfbb")
        XCTAssertEqual(document.fields[14].tableColumns?[0].type, "text")
        XCTAssertEqual(document.fields[14].tableColumns?[0].title, "Text Column")
        XCTAssertEqual(document.fields[14].tableColumns?[0].width, 0)
        XCTAssertEqual(document.fields[14].tableColumns?[0].identifier, "field_column_6629fbc70c9e53f683a18007")
        
        XCTAssertEqual(document.fields[14].tableColumns?[1].id, "6628f2e123ca77fa82a2c45e")
        XCTAssertEqual(document.fields[14].tableColumns?[1].type, "dropdown")
        XCTAssertEqual(document.fields[14].tableColumns?[1].title, "Dropdown Column")
        XCTAssertEqual(document.fields[14].tableColumns?[1].width, 0)
        XCTAssertEqual(document.fields[14].tableColumns?[1].identifier, "field_column_6629fbc7e2493a155a32c509")
        
        XCTAssertEqual(document.fields[14].tableColumns?[2].id, "6628f2e1355b7d93cea30f3c")
        XCTAssertEqual(document.fields[14].tableColumns?[2].type, "text")
        XCTAssertEqual(document.fields[14].tableColumns?[2].title, "Text Column")
        XCTAssertEqual(document.fields[14].tableColumns?[2].width, 0)
        XCTAssertEqual(document.fields[14].tableColumns?[2].identifier, "field_column_6629fbc782667100aa64d18d")
        
        XCTAssertEqual(document.fields[14].tableColumnOrder?.count, 3)
        XCTAssertEqual(document.fields[14].tableColumnOrder?[0], "6628f2e11a2b28119985cfbb")
        XCTAssertEqual(document.fields[14].tableColumnOrder?[1], "6628f2e123ca77fa82a2c45e")
        XCTAssertEqual(document.fields[14].tableColumnOrder?[2], "6628f2e1355b7d93cea30f3c")

        // Test cases for the fourteen (chart) field
        XCTAssertEqual(document.fields[15].type, "chart")
        XCTAssertEqual(document.fields[15].id, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(document.fields[15].identifier, "field_6629fbdd498f2c3131051bb4")
        XCTAssertEqual(document.fields[15].title, "Chart")
        XCTAssertEqual(document.fields[15].description, "")
        XCTAssertEqual(document.fields[15].required, false)
        XCTAssertEqual(document.fields[15].tipTitle, "")
        XCTAssertEqual(document.fields[15].tipDescription, "")
        XCTAssertEqual(document.fields[15].tipVisible, false)
        XCTAssertTrue(document.fields[15].metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.fields[15].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(document.fields[15].value?.valueElements?[0].id, "662a4ac36cb46cb39dd48090")
        XCTAssertEqual(document.fields[15].value?.valueElements?[0].points?[0].id, "662a4ac3a09a7fa900990da3")
        XCTAssertEqual(document.fields[15].value?.valueElements?[0].points?[1].id, "662a4ac332c49d08cc4da9b8")
        XCTAssertEqual(document.fields[15].value?.valueElements?[0].points?[2].id, "662a4ac305c6948e2ffe8ab1")
        XCTAssertEqual(document.fields[15].yTitle, "Vertical")
        XCTAssertEqual(document.fields[15].yMax, 100)
        XCTAssertEqual(document.fields[15].yMin, 0)
        XCTAssertEqual(document.fields[15].xTitle, "Horizontal")
        XCTAssertEqual(document.fields[15].xMax, 100)
        XCTAssertEqual(document.fields[15].xMin, 0)

        
        // Test cases for page fields
        XCTAssertEqual(document.files[0].pages?.count, 1)
        XCTAssertEqual(document.files[0].pages?[0].name, "New Page")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?.count, 16)
        XCTAssertTrue(document.metadata!.dictionary.isEmpty)
        XCTAssertEqual(document.files[0].pages?[0].hidden, false)
        XCTAssertEqual(document.files[0].pages?[0].width, 816)
        XCTAssertEqual(document.files[0].pages?[0].height, 1056)
        XCTAssertEqual(document.files[0].pages?[0].cols, 24)
        XCTAssertEqual(document.files[0].pages?[0].rowHeight, 8)
        XCTAssertEqual(document.files[0].pages?[0].layout, "grid")
        XCTAssertEqual(document.files[0].pages?[0].presentation, "normal")
        XCTAssertEqual(document.files[0].pages?[0].margin, 0)
        XCTAssertEqual(document.files[0].pages?[0].padding, 0)
        XCTAssertEqual(document.files[0].pages?[0].borderWidth, 0)
        XCTAssertEqual(document.files[0].pages?[0].id, "6629fab320fca7c8107a6cf6")
        
        // Test cases for field position for image field
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].field, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].width, 9)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].height, 23)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].y, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].id, "6629fab82ddb5cdd73a2f27f")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].type, FieldTypes.image)
        
    }
    
}