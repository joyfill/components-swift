import XCTest
import Foundation
import SwiftUI
import JoyfillModel

final class JoyfillTests: XCTestCase {
    
    var document: JoyDoc!
    
    override func setUp() {
        super.setUp()
        let path = Bundle.main.path(forResource: "Joydocjson", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        document = JoyDoc(dictionary: dict)
    }
    
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    func testPerformanceExample() throws {
        measure {
        }
    }
    
    func assertDocument(document: JoyDoc) {
        XCTAssertEqual(document.id, "6629fc6367b3a40644096182")
        XCTAssertEqual(document.type, "document")
        XCTAssertEqual(document.stage, "published")
        XCTAssertEqual(document.source, "template_6629fab38559d3017b0308b0")
        XCTAssertEqual(document.identifier, "doc_6629fc6367b3a40644096182")
        XCTAssertEqual(document.name, "All Fields Template")
        XCTAssertEqual(document.createdOn, 1714027619864)
        XCTAssertEqual(document.deleted, false)
    }
    
    func testGetJoyDoc() {
        assertDocument(document: document)
    }
    
    func testSetJoyDoc() {
        var document = JoyDoc()
        document.id = "6629fc6367b3a40644096182"
        document.type = "document"
        document.stage = "published"
        document.source = "template_6629fab38559d3017b0308b0"
        document.identifier = "doc_6629fc6367b3a40644096182"
        document.name = "All Fields Template"
        document.createdOn = 1714027619864
        document.deleted = false
        
        assertDocument(document: document)
    }
    
    func assertFileFields(document: JoyDoc) {
        XCTAssertEqual(document.files.count, 1)
        XCTAssertEqual(document.files[0].id, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(document.files[0].name, "All Fields Template")
        XCTAssertEqual(document.files[0].version, 1)
        XCTAssertTrue(document.files[0].styles!.dictionary.isEmpty)
        XCTAssertEqual(document.files[0].pageOrder, ["6629fab320fca7c8107a6cf6"])
        XCTAssertTrue(document.files[0].views!.isEmpty)
        
        XCTAssertEqual(document.fields.count, 16)
    }
    
    func testGetFileFields() {
        assertFileFields(document: document)
    }
    
    func testSetFileFields() {
        document.files[0].id = "6629fab3c0ba3fb775b4a55c"
        document.files[0].name = "All Fields Template"
        document.files[0].version = 1
        document.files[0].styles?.dictionary.isEmpty
        document.files[0].pageOrder = ["6629fab320fca7c8107a6cf6"]
        document.files[0].views?.isEmpty
        
        assertFileFields(document: document)
    }
    
    func assertImageField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[0].multi, false)
        XCTAssertEqual(document.fields[0].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetImageField() {
        assertImageField(document: document)
    }
    
    func testSetImageField() {
        document.fields[0].type = "image"
        document.fields[0].id = "6629fab36e8925135f0cdd4f"
        document.fields[0].identifier = "field_6629fab87c5c8ff831b8d223"
        document.fields[0].title = "Image"
        document.fields[0].description = ""
        var dict = [
            "url":"https://s3.amazonaws.com/docspace.production.documents/6628f1034892618fc118503b/documents/template_6629fab38559d3017b0308b0/6629fad945f22ce76d678f37-1714027225742.png",
            "fileName":"6629fad945f22ce76d678f37-1714027225742.png",
            "_id":"6629fad9a6d0c81c8c217fc5",
            "filePath":"6628f1034892618fc118503b/documents/template_6629fab38559d3017b0308b0"
        ]
        let arrayOfValueElements = [ValueElement(dictionary: dict)]
        document.fields[0].value = .valueElementArray(arrayOfValueElements)
        document.fields[0].required = false
        document.fields[0].tipTitle = ""
        document.fields[0].tipDescription = ""
        document.fields[0].tipVisible = false
        document.fields[0].multi = false
        document.fields[0].file = "6629fab3c0ba3fb775b4a55c"
        
        assertImageField(document: document)
    }
    
    func assertHeadingText(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[1].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testHeadingText() {
        assertHeadingText(document: document)
    }
    
    func testSetHeadingText() {
        document.fields[1].type = "block"
        document.fields[1].id = "6629fad980958bff0608cd4a"
        document.fields[1].identifier = "field_6629fadcfc73f30cbb7b785a"
        document.fields[1].title = "Heading Text"
        document.fields[1].description = ""
        document.fields[1].value = .string("Form View")
        document.fields[1].required = false
        document.fields[1].tipTitle = ""
        document.fields[1].tipDescription = ""
        document.fields[1].tipVisible = false
        document.fields[1].file = "6629fab3c0ba3fb775b4a55c"
        
        assertHeadingText(document: document)
    }
    
    func assertDisplayText(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[2].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetDisplayText() {
        assertDisplayText(document: document)
    }
    
    func testSetDisplayText() {
        document.fields[2].type = "block"
        document.fields[2].id = "6629faf0868164d68b4cf359"
        document.fields[2].identifier = "field_6629faf7fb9bfd2cfc6bb830"
        document.fields[2].title = "Display Text"
        document.fields[2].description = ""
        document.fields[2].value = .string("All Fields ")
        document.fields[2].required = false
        document.fields[2].tipTitle = ""
        document.fields[2].tipDescription = ""
        document.fields[2].tipVisible = false
        document.fields[2].file = "6629fab3c0ba3fb775b4a55c"
        
        assertDisplayText(document: document)
    }
    
    func assertEmptySpaceField(doucment: JoyDoc) {
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
        XCTAssertEqual(document.fields[3].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetEmptySpaceField() {
        assertEmptySpaceField(doucment: document)
    }
    
    func testSetEmptySpaceField() {
        document.fields[3].type = "block"
        document.fields[3].id = "6629fb050c62b1fe457b58e0"
        document.fields[3].identifier = "field_6629fb0b3079250a86dac94f"
        document.fields[3].title = "Empty Space"
        document.fields[3].description = ""
        document.fields[3].value = .string("")
        document.fields[3].required = false
        document.fields[3].tipTitle = ""
        document.fields[3].tipDescription = ""
        document.fields[3].tipVisible = false
        document.fields[3].file = "6629fab3c0ba3fb775b4a55c"
        
        assertEmptySpaceField(doucment: document)
    }
    
    func assertTextField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[4].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetTextField() {
        assertTextField(document: document)
    }
    
    func testSetTextField() {
        document.fields[4].type = "text"
        document.fields[4].id = "6629fb1d92a76d06750ca4a1"
        document.fields[4].identifier = "field_6629fb20c9e72451c769df47"
        document.fields[4].title = "Heading Text"
        document.fields[4].description = ""
        document.fields[4].value = .string("Hello sir")
        document.fields[4].required = false
        document.fields[4].tipTitle = ""
        document.fields[4].tipDescription = ""
        document.fields[4].tipVisible = false
        document.fields[4].file = "6629fab3c0ba3fb775b4a55c"
        
        assertTextField(document: document)
    }
    
    func assertMultilineTextField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[5].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetMultilineTextField() {
        assertMultilineTextField(document: document)
    }
    
    func testSetMultilineTextField() {
        document.fields[5].type = "textarea"
        document.fields[5].id = "6629fb2b9a487ce1c1f35f6c"
        document.fields[5].identifier = "field_6629fb2feff29e90331e4e8e"
        document.fields[5].title = "Multiline Text"
        document.fields[5].description = ""
        document.fields[5].value = .string("Hello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir")
        document.fields[5].required = false
        document.fields[5].tipTitle = ""
        document.fields[5].tipDescription = ""
        document.fields[5].tipVisible = false
        document.fields[5].file = "6629fab3c0ba3fb775b4a55c"
        
        assertMultilineTextField(document: document)
    }
    
    func assertNumberField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[6].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetNumberField() {
        assertNumberField(document: document)
    }
    
    func testSetNumberField() {
        document.fields[6].type = "number"
        document.fields[6].id = "6629fb3df03de10b26270ab3"
        document.fields[6].identifier = "field_6629fb3fabb87e37c9578b8b"
        document.fields[6].title = "Number"
        document.fields[6].description = ""
        document.fields[6].value = .double(98789)
        document.fields[6].required = false
        document.fields[6].tipTitle = ""
        document.fields[6].tipDescription = ""
        document.fields[6].tipVisible = false
        document.fields[6].file = "6629fab3c0ba3fb775b4a55c"
        
        assertNumberField(document: document)
    }
    
    func assertDateField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[7].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetDateField() {
        assertDateField(document: document)
    }
    
    func testSetDateField() {
        document.fields[7].type = "date"
        document.fields[7].id = "6629fb44c79bb16ce072d233"
        document.fields[7].identifier = "field_6629fb44309fbfe84376095e"
        document.fields[7].title = "Date"
        document.fields[7].description = ""
        document.fields[7].value = .double(1712255400000)
        document.fields[7].required = false
        document.fields[7].tipTitle = ""
        document.fields[7].tipDescription = ""
        document.fields[7].tipVisible = false
        document.fields[7].file = "6629fab3c0ba3fb775b4a55c"
        
        assertDateField(document: document)
    }
    
    func assertTimeField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[8].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetTimeField() {
        assertTimeField(document: document)
    }
    
    func testSetTimeField() {
        document.fields[8].type = "date"
        document.fields[8].id = "v"
        document.fields[8].identifier = "field_6629fb669a6d216e2a9c8dcd"
        document.fields[8].title = "Time"
        document.fields[8].description = ""
        document.fields[8].value = .double(1713984174769)
        document.fields[8].required = false
        document.fields[8].tipTitle = ""
        document.fields[8].tipDescription = ""
        document.fields[8].tipVisible = false
        document.fields[8].file = "6629fab3c0ba3fb775b4a55c"
    }
    
    func assertDateTimeField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[9].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetDateTimeField() {
        assertDateTimeField(document: document)
    }
    
    func testSetDateTimeField() {
        document.fields[9].type = "date"
        document.fields[9].id = "6629fb6ec5d88d3aadf548ca"
        document.fields[9].identifier = "field_6629fb74e6c43707ad6101f7"
        document.fields[9].title = "Date Time"
        document.fields[9].description = ""
        document.fields[9].value = .double(1712385780000)
        document.fields[9].required = false
        document.fields[9].tipTitle = ""
        document.fields[9].tipDescription = ""
        document.fields[9].tipVisible = false
        document.fields[9].file = "6629fab3c0ba3fb775b4a55c"
        
        assertDateTimeField(document: document)
    }
    
    func assertDropdownField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[10].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(document.fields[10].options?.count, 3)
        XCTAssertEqual(document.fields[10].options?[0].id, "6628f2e183591f3efa7f76f9")
        XCTAssertEqual(document.fields[10].options?[1].id, "6628f2e15cea1b971f6a9383")
        XCTAssertEqual(document.fields[10].options?[2].id, "6628f2e1817f03440bc70a46")
    }
    
    func testgetDropdownField() {
        assertDropdownField(document: document)
    }
    
    func testSetDropdownField() {
        document.fields[10].type = "dropdown"
        document.fields[10].id = "6629fb77593e3791638628bb"
        document.fields[10].identifier = "field_6629fb8e57f251ebbbc8c915"
        document.fields[10].title = "Dropdown"
        document.fields[10].description = ""
        document.fields[10].value = .string("6628f2e183591f3efa7f76f9")
        document.fields[10].required = false
        document.fields[10].tipTitle = ""
        document.fields[10].tipDescription = ""
        document.fields[10].tipVisible = false
        document.fields[10].file = "6629fab3c0ba3fb775b4a55c"
        document.fields[10].options?[0].id = "6628f2e183591f3efa7f76f9"
        document.fields[10].options?[1].id = "6628f2e15cea1b971f6a9383"
        document.fields[10].options?[2].id = "6628f2e1817f03440bc70a46"
        
        assertDropdownField(document: document)
    }
    
    func assertMultipleChoiceField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[11].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(document.fields[11].options?.count, 3)
        XCTAssertEqual(document.fields[11].options?[0].id, "6628f2e1d0c98c6987cc6021")
        XCTAssertEqual(document.fields[11].options?[1].id, "6628f2e19c3cba4fdf9e5f19")
        XCTAssertEqual(document.fields[11].options?[2].id, "6628f2e1679bcf815adfa0f6")
    }
    
    func testGetMultipleChoiceField() {
        assertMultipleChoiceField(document: document)
    }
    
    func testSetMultipleChoiceField() {
        document.fields[11].type = "multiSelect"
        document.fields[11].id = "6629fb9f4d912053577652b1"
        document.fields[11].identifier = "field_6629fbb02b40c2f4d0c95b38"
        document.fields[11].title = "Multiple Choice"
        document.fields[11].description = ""
        document.fields[11].value = .array(["6628f2e1d0c98c6987cc6021", "6628f2e19c3cba4fdf9e5f19"])
        document.fields[11].required = false
        document.fields[11].tipTitle = ""
        document.fields[11].tipDescription = ""
        document.fields[11].tipVisible = false
        document.fields[11].file = "6629fab3c0ba3fb775b4a55c"
        document.fields[11].options?[0].id = "6628f2e1d0c98c6987cc6021"
        document.fields[11].options?[1].id = "6628f2e19c3cba4fdf9e5f19"
        document.fields[11].options?[2].id = "6628f2e1679bcf815adfa0f6"
        
        assertMultipleChoiceField(document: document)
    }
    
    func assertSingleChoiceField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[12].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(document.fields[12].options?.count, 3)
        XCTAssertEqual(document.fields[12].options?[0].id, "6628f2e1fae456e6b850e85e")
        XCTAssertEqual(document.fields[12].options?[1].id, "6628f2e13e1e340a51d9ecca")
        XCTAssertEqual(document.fields[12].options?[2].id, "6628f2e16bf0362dd5498eb4")
    }
    
    func testGetSingleChoiceField() {
        assertSingleChoiceField(document: document)
    }
    
    func testSetSingleChoiceField() {
        document.fields[12].type = "multiSelect"
        document.fields[12].id = "6629fbb2bf4f965b9d04f153"
        document.fields[12].identifier = "field_6629fbb5b16c74b78381af3b"
        document.fields[12].title = "Single Choice"
        document.fields[12].description = ""
        document.fields[12].value = .array(["6628f2e1fae456e6b850e85e"])
        document.fields[12].required = false
        document.fields[12].tipTitle = ""
        document.fields[12].tipDescription = ""
        document.fields[12].tipVisible = false
        document.fields[12].file = "6629fab3c0ba3fb775b4a55c"
        document.fields[12].options?[0].id = "6628f2e1fae456e6b850e85e"
        document.fields[12].options?[1].id = "6628f2e13e1e340a51d9ecca"
        document.fields[12].options?[2].id = "6628f2e16bf0362dd5498eb4"
        
        assertSingleChoiceField(document: document)
    }
    
    func assertSignatureField(document: JoyDoc) {
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
        XCTAssertEqual(document.fields[13].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func testGetSignatureField() {
        assertSignatureField(document: document)
    }
    
    func testSetSignatureField() {
        document.fields[13].type = "signature"
        document.fields[13].id = "6629fbb8cd16c0c4d308a252"
        document.fields[13].identifier = "field_6629fbbcb1f415665455fea4"
        document.fields[13].title = "Signature"
        document.fields[13].description = ""
        document.fields[13].value = .string("data:image/png;base64,iVBOR")
        document.fields[13].required = false
        document.fields[13].tipTitle = ""
        document.fields[13].tipDescription = ""
        document.fields[13].tipVisible = false
        document.fields[13].file = "6629fab3c0ba3fb775b4a55c"
        
        assertSignatureField(document: document)
    }
    
    func assertTableField(document: JoyDoc) {
        XCTAssertEqual(document.fields[14].type, "table")
        XCTAssertEqual(document.fields[14].id, "6629fbc0d449f4216e871e3f")
        XCTAssertEqual(document.fields[14].identifier, "field_6629fbc7915c00c8678c9430")
        XCTAssertEqual(document.fields[14].title, "Table")
        XCTAssertEqual(document.fields[14].description, "")
        XCTAssertEqual(document.fields[14].required, false)
        XCTAssertEqual(document.fields[14].tipTitle, "")
        XCTAssertEqual(document.fields[14].tipDescription, "")
        XCTAssertEqual(document.fields[14].tipVisible, false)
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
    }
    
    func testGetTableField() {
        assertTableField(document: document)
    }
    
    func testSetTableField() {
        document.fields[14].type = "table"
        document.fields[14].id = "6629fbc0d449f4216e871e3f"
        document.fields[14].identifier = "field_6629fbc7915c00c8678c9430"
        document.fields[14].title = "Table"
        document.fields[14].description = ""
        document.fields[14].required = false
        document.fields[14].tipTitle = ""
        document.fields[14].tipDescription = ""
        document.fields[14].tipVisible = false
        document.fields[14].file = "6629fab3c0ba3fb775b4a55c"
        
        document.fields[14].rowOrder?[0] = "6628f2e142ffeada4206bbdb"
        document.fields[14].rowOrder?[1] = "6628f2e1a6b5e93e8dde45f8"
        document.fields[14].rowOrder?[2] = "6628f2e1750679d671be36b8"
        
        document.fields[14].tableColumns?[0].id = "6628f2e11a2b28119985cfbb"
        document.fields[14].tableColumns?[0].type = "text"
        document.fields[14].tableColumns?[0].title = "Text Column"
        document.fields[14].tableColumns?[0].width = 0
        document.fields[14].tableColumns?[0].identifier = "field_column_6629fbc70c9e53f683a18007"
        
        document.fields[14].tableColumns?[1].id = "6628f2e123ca77fa82a2c45e"
        document.fields[14].tableColumns?[1].type = "dropdown"
        document.fields[14].tableColumns?[1].title = "Dropdown Column"
        document.fields[14].tableColumns?[1].width = 0
        document.fields[14].tableColumns?[1].identifier = "field_column_6629fbc7e2493a155a32c509"
        
        document.fields[14].tableColumns?[2].id = "6628f2e1355b7d93cea30f3c"
        document.fields[14].tableColumns?[2].type = "text"
        document.fields[14].tableColumns?[2].title = "Text Column"
        document.fields[14].tableColumns?[2].width = 0
        document.fields[14].tableColumns?[2].identifier = "field_column_6629fbc782667100aa64d18d"
        
        document.fields[14].tableColumnOrder?[0] = "6628f2e11a2b28119985cfbb"
        document.fields[14].tableColumnOrder?[1] = "6628f2e123ca77fa82a2c45e"
        document.fields[14].tableColumnOrder?[2] = "6628f2e1355b7d93cea30f3c"
        
        assertTableField(document: document)
    }
    
    func asssertChartField(document: JoyDoc) {
        XCTAssertEqual(document.fields[15].type, "chart")
        XCTAssertEqual(document.fields[15].id, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(document.fields[15].identifier, "field_6629fbdd498f2c3131051bb4")
        XCTAssertEqual(document.fields[15].title, "Chart")
        XCTAssertEqual(document.fields[15].description, "")
        XCTAssertEqual(document.fields[15].required, false)
        XCTAssertEqual(document.fields[15].tipTitle, "")
        XCTAssertEqual(document.fields[15].tipDescription, "")
        XCTAssertEqual(document.fields[15].tipVisible, false)
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
    }
    
    func testgetChartField() {
        asssertChartField(document: document)
    }
    
    func testSetChartField() {
        document.fields[15].type = "chart"
        document.fields[15].id = "6629fbd957d928a973b1b42b"
        document.fields[15].identifier = "field_6629fbdd498f2c3131051bb4"
        document.fields[15].title = "Chart"
        document.fields[15].description = ""
        document.fields[15].required = false
        document.fields[15].tipTitle = ""
        document.fields[15].tipDescription = ""
        document.fields[15].tipVisible = false
        document.fields[15].file = "6629fab3c0ba3fb775b4a55c"
        
        let point1 = Point(dictionary: ["_id" : "662a4ac3a09a7fa900990da3"])
        let point2 = Point(dictionary: ["_id" : "662a4ac332c49d08cc4da9b8"])
        let point3 = Point(dictionary: ["_id" : "662a4ac305c6948e2ffe8ab1"])
        let pointValueElement: ValueElement = ValueElement(id: "662a4ac36cb46cb39dd48090", url: "", points: [point1, point2, point3])
        document.fields[15].value = .valueElementArray([pointValueElement])
        document.fields[15].yTitle = "Vertical"
        document.fields[15].yMax = 100
        document.fields[15].yMin = 0
        document.fields[15].xTitle = "Horizontal"
        document.fields[15].xMax = 100
        document.fields[15].xMin = 0
        
        asssertChartField(document: document)
    }
    
    func assertPageField(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?.count, 1)
        XCTAssertEqual(document.files[0].pages?[0].name, "New Page")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?.count, 16)
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
        XCTAssertEqual(document.files[0].pages?[0].backgroundImage, "https://s3.amazonaws.com/docspace.production.documents/5cca363a20d5f31fe3d7d6a2/pdfTemplates/614892aeb47c0f58db8ebd0a/page1631330091520-2f189ce0-1631330091522.png")
        XCTAssertEqual(document.files[0].pages?[0].id, "6629fab320fca7c8107a6cf6")
    }
    
    func testGetPageField() {
        assertPageField(document: document)
    }
    
    func testSetPageField() {
        document.files[0].pages?[0].name = "New Page"
//        document.files[0].pages?[0].fieldPositions = [FieldPosition]()
        document.files[0].pages?[0].hidden = false
        document.files[0].pages?[0].width = 816
        document.files[0].pages?[0].height = 1056
        document.files[0].pages?[0].cols = 24
        document.files[0].pages?[0].rowHeight = 8
        document.files[0].pages?[0].layout = "grid"
        document.files[0].pages?[0].presentation = "normal"
        document.files[0].pages?[0].margin = 0
        document.files[0].pages?[0].padding = 0
        document.files[0].pages?[0].borderWidth = 0
        document.files[0].pages?[0].backgroundImage = "https://s3.amazonaws.com/docspace.production.documents/5cca363a20d5f31fe3d7d6a2/pdfTemplates/614892aeb47c0f58db8ebd0a/page1631330091520-2f189ce0-1631330091522.png"
        document.files[0].pages?[0].id = "6629fab320fca7c8107a6cf6"
        
        assertPageField(document: document)
    }
    
    func assertImageFieldPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].field, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].width, 9)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].height, 23)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].y, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].id, "6629fab82ddb5cdd73a2f27f")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[0].type, FieldTypes.image)
    }
    
    func testGetImageFieldPosition() {
        assertImageFieldPosition(document: document)
    }
    
    func testSetImageFieldPosition() {
        document.files[0].pages?[0].fieldPositions?[0].field = "6629fab36e8925135f0cdd4f"
        document.files[0].pages?[0].fieldPositions?[0].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[0].width = 9
        document.files[0].pages?[0].fieldPositions?[0].height = 23
        document.files[0].pages?[0].fieldPositions?[0].x = 0
        document.files[0].pages?[0].fieldPositions?[0].y = 12
        document.files[0].pages?[0].fieldPositions?[0].id = "6629fab82ddb5cdd73a2f27f"
        document.files[0].pages?[0].fieldPositions?[0].type = .image
        
        assertImageFieldPosition(document: document)
    }
    
    func assertHeadingTextPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].field, "6629fad980958bff0608cd4a")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].height, 5)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].y, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].fontSize, 28)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].fontWeight, "bold")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].id, "6629fadcacdb1bb9b9bbfdce")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[1].type, FieldTypes.block)
    }
    
    func testGetHeadingTextPosition() {
        assertHeadingText(document: document)
    }
    
    func testSetHeadingTextPosition() {
        document.files[0].pages?[0].fieldPositions?[1].field = "6629fad980958bff0608cd4a"
        document.files[0].pages?[0].fieldPositions?[1].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[1].width = 12
        document.files[0].pages?[0].fieldPositions?[1].height = 5
        document.files[0].pages?[0].fieldPositions?[1].x = 0
        document.files[0].pages?[0].fieldPositions?[1].y = 0
        document.files[0].pages?[0].fieldPositions?[1].fontSize = 28
        document.files[0].pages?[0].fieldPositions?[1].fontWeight = "bold"
        document.files[0].pages?[0].fieldPositions?[1].id = "6629fadcacdb1bb9b9bbfdce"
        document.files[0].pages?[0].fieldPositions?[1].type = .block
        
        assertHeadingText(document: document)
    }
    
    func assertDisplayTextPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[2].field, "6629faf0868164d68b4cf359")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[2].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[2].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[2].height, 5)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[2].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[2].y, 7)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[2].id, "6629faf7cdcf955b0b3d2daa")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[2].type, FieldTypes.block)
    }
    
    func testGetDisplayTextPosition() {
        assertDisplayTextPosition(document: document)
    }
    
    func testSetDisplayTextPosition() {
        document.files[0].pages?[0].fieldPositions?[2].field = "6629faf0868164d68b4cf359"
        document.files[0].pages?[0].fieldPositions?[2].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[2].width = 12
        document.files[0].pages?[0].fieldPositions?[2].height = 5
        document.files[0].pages?[0].fieldPositions?[2].x = 0
        document.files[0].pages?[0].fieldPositions?[2].y = 7
        document.files[0].pages?[0].fieldPositions?[2].fontSize = 28
        document.files[0].pages?[0].fieldPositions?[2].fontWeight = "bold"
        document.files[0].pages?[0].fieldPositions?[2].id = "6629faf7cdcf955b0b3d2daa"
        document.files[0].pages?[0].fieldPositions?[2].type = .block
        
        assertDisplayTextPosition(document: document)
    }
    
    func assertEmptySpacePosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].field, "6629fb050c62b1fe457b58e0")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].height, 2)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].y, 5)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].borderColor, "transparent")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].backgroundColor, "transparent")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].id, "6629fb0b7b10702947a43488")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[3].type, FieldTypes.block)
    }
    
    func testGetEmptySpacePosition() {
        assertEmptySpacePosition(document: document)
    }
    
    func testSetEmptySpacePosition() {
        document.files[0].pages?[0].fieldPositions?[3].field = "6629fb050c62b1fe457b58e0"
        document.files[0].pages?[0].fieldPositions?[3].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[3].width = 12
        document.files[0].pages?[0].fieldPositions?[3].height = 2
        document.files[0].pages?[0].fieldPositions?[3].x = 0
        document.files[0].pages?[0].fieldPositions?[3].y = 5
        document.files[0].pages?[0].fieldPositions?[3].borderColor = "transparent"
        document.files[0].pages?[0].fieldPositions?[3].backgroundColor = "transparent"
        document.files[0].pages?[0].fieldPositions?[3].id = "6629fb0b7b10702947a43488"
        document.files[0].pages?[0].fieldPositions?[3].type = .block
        
        assertEmptySpacePosition(document: document)
    }
    
    func assertTextPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[4].field, "6629fb1d92a76d06750ca4a1")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[4].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[4].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[4].height, 8)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[4].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[4].y, 35)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[4].id, "6629fb203149d1c34cc6d6f8")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[4].type, FieldTypes.text)
    }
    
    func testGetTextPosition() {
        assertTextPosition(document: document)
    }
    
    func testSetTextPosition() {
        document.files[0].pages?[0].fieldPositions?[4].field = "6629fb1d92a76d06750ca4a1"
        document.files[0].pages?[0].fieldPositions?[4].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[4].width = 12
        document.files[0].pages?[0].fieldPositions?[4].height = 8
        document.files[0].pages?[0].fieldPositions?[4].x = 0
        document.files[0].pages?[0].fieldPositions?[4].y = 35
        document.files[0].pages?[0].fieldPositions?[4].id = "6629fb203149d1c34cc6d6f8"
        document.files[0].pages?[0].fieldPositions?[4].type = .text
        
        assertTextPosition(document: document)
    }
    
    func assertMultiLineTextPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[5].field, "6629fb2b9a487ce1c1f35f6c")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[5].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[5].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[5].height, 20)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[5].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[5].y, 43)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[5].id, "6629fb2fca14b3e2ef978349")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[5].type, FieldTypes.textarea)
    }
    
    func testGetMultiLineTextPosition() {
        assertMultiLineTextPosition(document: document)
    }
    
    func testSetMultiLineTextPosition() {
        document.files[0].pages?[0].fieldPositions?[5].field = "6629fb2b9a487ce1c1f35f6c"
        document.files[0].pages?[0].fieldPositions?[5].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[5].width = 12
        document.files[0].pages?[0].fieldPositions?[5].height = 20
        document.files[0].pages?[0].fieldPositions?[5].x = 0
        document.files[0].pages?[0].fieldPositions?[5].y = 43
        document.files[0].pages?[0].fieldPositions?[5].id = "6629fb2fca14b3e2ef978349"
        document.files[0].pages?[0].fieldPositions?[5].type = .textarea
        
        assertMultiLineTextPosition(document: document)
    }
    
    func assertNumberPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[6].field, "6629fb3df03de10b26270ab3")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[6].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[6].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[6].height, 8)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[6].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[6].y, 63)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[6].id, "6629fb3f2eff74a9ca322bb5")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[6].type, FieldTypes.number)
    }
    
    func testGetNumberPosition() {
        assertNumberPosition(document: document)
    }
    
    func testSetNumberPosition() {
        document.files[0].pages?[0].fieldPositions?[6].field = "6629fb3df03de10b26270ab3"
        document.files[0].pages?[0].fieldPositions?[6].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[6].width = 12
        document.files[0].pages?[0].fieldPositions?[6].height = 8
        document.files[0].pages?[0].fieldPositions?[6].x = 0
        document.files[0].pages?[0].fieldPositions?[6].y = 63
        document.files[0].pages?[0].fieldPositions?[6].id = "6629fb3f2eff74a9ca322bb5"
        document.files[0].pages?[0].fieldPositions?[6].type = .number
        
        assertNumberPosition(document: document)
    }
    
    func assertDatePosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].field, "6629fb44c79bb16ce072d233")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].height, 8)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].y, 71)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].format, "MM/DD/YYYY")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].id, "6629fb4451f3bf2eb2f46567")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[7].type, FieldTypes.date)
    }
    
    func testGetDatePosition() {
        assertDatePosition(document: document)
    }
    
    func testSetDatePosition() {
        document.files[0].pages?[0].fieldPositions?[7].field = "6629fb44c79bb16ce072d233"
        document.files[0].pages?[0].fieldPositions?[7].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[7].width = 12
        document.files[0].pages?[0].fieldPositions?[7].height = 8
        document.files[0].pages?[0].fieldPositions?[7].x = 0
        document.files[0].pages?[0].fieldPositions?[7].y = 71
        document.files[0].pages?[0].fieldPositions?[7].format = "MM/DD/YYYY"
        document.files[0].pages?[0].fieldPositions?[7].id = "6629fb4451f3bf2eb2f46567"
        document.files[0].pages?[0].fieldPositions?[7].type = .date
        
        assertDatePosition(document: document)
    }
    
    func assertTimePosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].field, "6629fb638e230f348d0a8682")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].height, 8)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].y, 79)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].format, "hh:mma")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].id, "6629fb66420b995d026e480b")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[8].type, FieldTypes.date)
    }
    
    func testGetTimePosition() {
        assertTimePosition(document: document)
    }
    
    func testSetTimePosition() {
        document.files[0].pages?[0].fieldPositions?[8].field = "6629fb638e230f348d0a8682"
        document.files[0].pages?[0].fieldPositions?[8].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[8].width = 12
        document.files[0].pages?[0].fieldPositions?[8].height = 8
        document.files[0].pages?[0].fieldPositions?[8].x = 0
        document.files[0].pages?[0].fieldPositions?[8].y = 79
        document.files[0].pages?[0].fieldPositions?[8].format = "hh:mma"
        document.files[0].pages?[0].fieldPositions?[8].id = "6629fb66420b995d026e480b"
        document.files[0].pages?[0].fieldPositions?[8].type = .date
        
        assertTimePosition(document: document)
    }
    
    func assertDateTimePosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].field, "6629fb6ec5d88d3aadf548ca")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].height, 8)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].y, 87)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].format, "MM/DD/YYYY hh:mma")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].id, "6629fb749d0c1af5e94dbac7")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[9].type, FieldTypes.date)
    }
    
    func testGetDateTimePosition() {
        assertDateTimePosition(document: document)
    }
    
    func testSetDateTimePosition() {
        document.files[0].pages?[0].fieldPositions?[9].field = "6629fb6ec5d88d3aadf548ca"
        document.files[0].pages?[0].fieldPositions?[9].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[9].width = 12
        document.files[0].pages?[0].fieldPositions?[9].height = 8
        document.files[0].pages?[0].fieldPositions?[9].x = 0
        document.files[0].pages?[0].fieldPositions?[9].y = 87
        document.files[0].pages?[0].fieldPositions?[9].format = "MM/DD/YYYY hh:mma"
        document.files[0].pages?[0].fieldPositions?[9].id = "6629fb749d0c1af5e94dbac7"
        document.files[0].pages?[0].fieldPositions?[9].type = .date
        
        assertDateTimePosition(document: document)
    }
    
    func assertDropdownPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].field, "6629fb77593e3791638628bb")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].height, 8)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].y, 95)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].targetValue, "6628f2e183591f3efa7f76f9")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].id, "6629fb8ea500024170241af3")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[10].type, FieldTypes.dropdown)
    }
    
    func testGetDropdownPosition() {
        assertDropdownPosition(document: document)
    }
    
    func testSetDropdownPosition() {
        document.files[0].pages?[0].fieldPositions?[10].field = "6629fb77593e3791638628bb"
        document.files[0].pages?[0].fieldPositions?[10].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[10].width = 12
        document.files[0].pages?[0].fieldPositions?[10].height = 8
        document.files[0].pages?[0].fieldPositions?[10].x = 0
        document.files[0].pages?[0].fieldPositions?[10].y = 95
        document.files[0].pages?[0].fieldPositions?[10].targetValue = "6628f2e183591f3efa7f76f9"
        document.files[0].pages?[0].fieldPositions?[10].id = "6629fb8ea500024170241af3"
        document.files[0].pages?[0].fieldPositions?[10].type = .dropdown
        
        assertDropdownPosition(document: document)
    }
    
    func assertMultiselectPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].field, "6629fb9f4d912053577652b1")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].height, 15)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].y, 103)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].targetValue, "6628f2e1d0c98c6987cc6021")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].id, "6629fbb06e14e0bcaeabf05b")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[11].type, FieldTypes.multiSelect)
    }
    
    func testGetMultiselectPosition() {
        assertMultiselectPosition(document: document)
    }
    
    func testSetMultiselectPosition() {
        document.files[0].pages?[0].fieldPositions?[11].field = "6629fb9f4d912053577652b1"
        document.files[0].pages?[0].fieldPositions?[11].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[11].width = 12
        document.files[0].pages?[0].fieldPositions?[11].height = 15
        document.files[0].pages?[0].fieldPositions?[11].x = 0
        document.files[0].pages?[0].fieldPositions?[11].y = 103
        document.files[0].pages?[0].fieldPositions?[11].targetValue = "6628f2e1d0c98c6987cc6021"
        document.files[0].pages?[0].fieldPositions?[11].id = "6629fbb06e14e0bcaeabf05b"
        document.files[0].pages?[0].fieldPositions?[11].type = .multiSelect
        
        assertMultiselectPosition(document: document)
    }
    
    func assertSingleSelectPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].field, "6629fbb2bf4f965b9d04f153")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].height, 15)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].y, 118)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].targetValue, "6628f2e1fae456e6b850e85e")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].id, "6629fbb5daa40d68bf26525f")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[12].type, FieldTypes.multiSelect)
    }
    
    func testGetSingleSelectPosition() {
        assertSingleSelectPosition(document: document)
    }
    
    func testSetSingleSelectPosition() {
        document.files[0].pages?[0].fieldPositions?[12].field = "6629fbb2bf4f965b9d04f153"
        document.files[0].pages?[0].fieldPositions?[12].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[12].width = 12
        document.files[0].pages?[0].fieldPositions?[12].height = 15
        document.files[0].pages?[0].fieldPositions?[12].x = 0
        document.files[0].pages?[0].fieldPositions?[12].y = 118
        document.files[0].pages?[0].fieldPositions?[12].targetValue = "6628f2e1fae456e6b850e85e"
        document.files[0].pages?[0].fieldPositions?[12].id = "6629fbb5daa40d68bf26525f"
        document.files[0].pages?[0].fieldPositions?[12].type = .multiSelect
        
        assertSingleSelectPosition(document: document)
    }
    
    func assertSignaturePosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[13].field, "6629fbb8cd16c0c4d308a252")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[13].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[13].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[13].height, 23)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[13].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[13].y, 133)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[13].id, "6629fbbc88ec687f865a53da")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[13].type, FieldTypes.signature)
    }
    
    func testGetSignaturePosition() {
        assertSignaturePosition(document: document)
    }
    
    func testSetSignaturePosition() {
        document.files[0].pages?[0].fieldPositions?[13].field = "6629fbb8cd16c0c4d308a252"
        document.files[0].pages?[0].fieldPositions?[13].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[13].width = 12
        document.files[0].pages?[0].fieldPositions?[13].height = 23
        document.files[0].pages?[0].fieldPositions?[13].x = 0
        document.files[0].pages?[0].fieldPositions?[13].y = 133
        document.files[0].pages?[0].fieldPositions?[13].id = "6629fbbc88ec687f865a53da"
        document.files[0].pages?[0].fieldPositions?[13].type = .signature
        
        assertSignaturePosition(document: document)
    }
    
    func assertTablePosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[14].field, "6629fbc0d449f4216e871e3f")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[14].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[14].width, 24)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[14].height, 15)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[14].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[14].y, 156)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[14].id, "6629fbc736d179b9014abae0")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[14].type, FieldTypes.table)
    }
    
    func testGetTablePosition() {
        assertTablePosition(document: document)
    }
    
    func testSetTablePosition() {
        document.files[0].pages?[0].fieldPositions?[14].field = "6629fbc0d449f4216e871e3f"
        document.files[0].pages?[0].fieldPositions?[14].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[14].width = 24
        document.files[0].pages?[0].fieldPositions?[14].height = 15
        document.files[0].pages?[0].fieldPositions?[14].x = 0
        document.files[0].pages?[0].fieldPositions?[14].y = 156
        document.files[0].pages?[0].fieldPositions?[14].id = "6629fbc736d179b9014abae0"
        document.files[0].pages?[0].fieldPositions?[14].type = .table
        
        assertTablePosition(document: document)
    }
    
    func assertChartPosition(document: JoyDoc) {
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].field, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].displayType, "original")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].width, 12)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].height, 27)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].x, 0)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].y, 171)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].primaryDisplayOnly, true)
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].id, "6629fbddabbd2a54f548bb95")
        XCTAssertEqual(document.files[0].pages?[0].fieldPositions?[15].type, FieldTypes.chart)
    }
    
    func testGetChartPosition() {
        assertChartPosition(document: document)
    }
    
    func testSetChartPosition() {
        document.files[0].pages?[0].fieldPositions?[15].field = "6629fbd957d928a973b1b42b"
        document.files[0].pages?[0].fieldPositions?[15].displayType = "original"
        document.files[0].pages?[0].fieldPositions?[15].width = 12
        document.files[0].pages?[0].fieldPositions?[15].height = 27
        document.files[0].pages?[0].fieldPositions?[15].x = 0
        document.files[0].pages?[0].fieldPositions?[15].y = 171
        document.files[0].pages?[0].fieldPositions?[15].primaryDisplayOnly = true
        document.files[0].pages?[0].fieldPositions?[15].id = "6629fbddabbd2a54f548bb95"
        document.files[0].pages?[0].fieldPositions?[15].type = .chart
        
        assertChartPosition(document: document)
    }
}

