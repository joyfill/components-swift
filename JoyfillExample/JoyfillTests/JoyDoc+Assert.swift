import Foundation
import JoyfillModel
import XCTest

extension JoyDoc {
    func assertDocument() {
        XCTAssertEqual(self.id, "6629fc6367b3a40644096182")
        XCTAssertEqual(self.type, "document")
        XCTAssertEqual(self.stage, "published")
        XCTAssertEqual(self.source, "template_6629fab38559d3017b0308b0")
        XCTAssertEqual(self.identifier, "doc_6629fc6367b3a40644096182")
        XCTAssertEqual(self.name, "All Fields Template")
        XCTAssertEqual(self.createdOn, 1714027619864)
        XCTAssertEqual(self.deleted, false)
    }
    
    func assertFileFields() {
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files[0].id, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(files[0].name, "All Fields Template")
        XCTAssertEqual(files[0].version, 1)
        XCTAssertTrue(files[0].styles!.dictionary.isEmpty)
        XCTAssertEqual(files[0].pageOrder, ["6629fab320fca7c8107a6cf6"])
        XCTAssertTrue(files[0].views!.isEmpty)
    }
    
    func assertImageField() {
        XCTAssertEqual(fields[0].type, "image")
        XCTAssertEqual(fields[0].id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(fields[0].identifier, "field_6629fab87c5c8ff831b8d223")
        XCTAssertEqual(fields[0].title, "Image")
        XCTAssertEqual(fields[0].description, "")
        XCTAssertEqual(fields[0].value?.valueElements?[0].id , "6629fad9a6d0c81c8c217fc5")
        XCTAssertEqual(fields[0].value?.valueElements?[0].url, "https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw")
        XCTAssertEqual(fields[0].value?.valueElements?[0].fileName, "6629fad945f22ce76d678f37-1714027225742.png")
        XCTAssertEqual(fields[0].value?.valueElements?[0].filePath, "6628f1034892618fc118503b/documents/template_6629fab38559d3017b0308b0")
        XCTAssertEqual(fields[0].required, false)
        XCTAssertEqual(fields[0].tipTitle, "")
        XCTAssertEqual(fields[0].tipDescription, "")
        XCTAssertEqual(fields[0].tipVisible, false)
        XCTAssertEqual(fields[0].multi, false)
        XCTAssertEqual(fields[0].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertHeadingText() {
        XCTAssertEqual(fields[1].type, "block")
        XCTAssertEqual(fields[1].id, "6629fad980958bff0608cd4a")
        XCTAssertEqual(fields[1].identifier, "field_6629fadcfc73f30cbb7b785a")
        XCTAssertEqual(fields[1].title, "Heading Text")
        XCTAssertEqual(fields[1].description, "")
        XCTAssertEqual(fields[1].value?.text, "Form View")
        XCTAssertEqual(fields[1].required, false)
        XCTAssertEqual(fields[1].tipTitle, "")
        XCTAssertEqual(fields[1].tipDescription, "")
        XCTAssertEqual(fields[1].tipVisible, false)
        XCTAssertEqual(fields[1].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertDisplayText() {
        XCTAssertEqual(fields[2].type, "block")
        XCTAssertEqual(fields[2].id, "6629faf0868164d68b4cf359")
        XCTAssertEqual(fields[2].identifier, "field_6629faf7fb9bfd2cfc6bb830")
        XCTAssertEqual(fields[2].title, "Display Text")
        XCTAssertEqual(fields[2].description, "")
        XCTAssertEqual(fields[2].value?.text, "All Fields ")
        XCTAssertEqual(fields[2].required, false)
        XCTAssertEqual(fields[2].tipTitle, "")
        XCTAssertEqual(fields[2].tipDescription, "")
        XCTAssertEqual(fields[2].tipVisible, false)
        XCTAssertEqual(fields[2].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertEmptySpaceField() {
        XCTAssertEqual(fields[3].type, "block")
        XCTAssertEqual(fields[3].id, "6629fb050c62b1fe457b58e0")
        XCTAssertEqual(fields[3].identifier, "field_6629fb0b3079250a86dac94f")
        XCTAssertEqual(fields[3].title, "Empty Space")
        XCTAssertEqual(fields[3].description, "")
        XCTAssertEqual(fields[3].value?.text, "")
        XCTAssertEqual(fields[3].required, false)
        XCTAssertEqual(fields[3].tipTitle, "")
        XCTAssertEqual(fields[3].tipDescription, "")
        XCTAssertEqual(fields[3].tipVisible, false)
        XCTAssertEqual(fields[3].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertTextField() {
        XCTAssertEqual(fields[4].type, "text")
        XCTAssertEqual(fields[4].id, "6629fb1d92a76d06750ca4a1")
        XCTAssertEqual(fields[4].identifier, "field_6629fb20c9e72451c769df47")
        XCTAssertEqual(fields[1].title, "Heading Text")
        XCTAssertEqual(fields[4].description, "")
        XCTAssertEqual(fields[4].value?.text, "Hello sir")
        XCTAssertEqual(fields[4].required, false)
        XCTAssertEqual(fields[4].tipTitle, "")
        XCTAssertEqual(fields[4].tipDescription, "")
        XCTAssertEqual(fields[4].tipVisible, false)
        XCTAssertEqual(fields[4].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertMultilineTextField() {
        XCTAssertEqual(fields[5].type, "textarea")
        XCTAssertEqual(fields[5].id, "6629fb2b9a487ce1c1f35f6c")
        XCTAssertEqual(fields[5].identifier, "field_6629fb2feff29e90331e4e8e")
        XCTAssertEqual(fields[5].title, "Multiline Text")
        XCTAssertEqual(fields[5].description, "")
        XCTAssertEqual(fields[5].value?.text, "Hello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir")
        XCTAssertEqual(fields[5].required, false)
        XCTAssertEqual(fields[5].tipTitle, "")
        XCTAssertEqual(fields[5].tipDescription, "")
        XCTAssertEqual(fields[5].tipVisible, false)
        XCTAssertEqual(fields[5].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertDateField() {
        XCTAssertEqual(fields[7].type, "date")
        XCTAssertEqual(fields[7].id, "6629fb44c79bb16ce072d233")
        XCTAssertEqual(fields[7].identifier, "field_6629fb44309fbfe84376095e")
        XCTAssertEqual(fields[7].title, "Date")
        XCTAssertEqual(fields[7].description, "")
        XCTAssertEqual(fields[7].value?.number, 1712255400000)
        XCTAssertEqual(fields[7].required, false)
        XCTAssertEqual(fields[7].tipTitle, "")
        XCTAssertEqual(fields[7].tipDescription, "")
        XCTAssertEqual(fields[7].tipVisible, false)
        XCTAssertEqual(fields[7].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertTimeField() {
        XCTAssertEqual(fields[8].type, "date")
        XCTAssertEqual(fields[8].id, "6629fb638e230f348d0a8682")
        XCTAssertEqual(fields[8].identifier, "field_6629fb669a6d216e2a9c8dcd")
        XCTAssertEqual(fields[8].title, "Time")
        XCTAssertEqual(fields[8].description, "")
        XCTAssertEqual(fields[8].value?.number, 1713984174769)
        XCTAssertEqual(fields[8].required, false)
        XCTAssertEqual(fields[8].tipTitle, "")
        XCTAssertEqual(fields[8].tipDescription, "")
        XCTAssertEqual(fields[8].tipVisible, false)
        XCTAssertEqual(fields[8].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertDateTimeField() {
        XCTAssertEqual(fields[9].type, "date")
        XCTAssertEqual(fields[9].id, "6629fb6ec5d88d3aadf548ca")
        XCTAssertEqual(fields[9].identifier, "field_6629fb74e6c43707ad6101f7")
        XCTAssertEqual(fields[9].title, "Date Time")
        XCTAssertEqual(fields[9].description, "")
        XCTAssertEqual(fields[9].value?.number, 1712385780000)
        XCTAssertEqual(fields[9].required, false)
        XCTAssertEqual(fields[9].tipTitle, "")
        XCTAssertEqual(fields[9].tipDescription, "")
        XCTAssertEqual(fields[9].tipVisible, false)
        XCTAssertEqual(fields[9].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertDropdownField() {
        XCTAssertEqual(fields[10].type, "dropdown")
        XCTAssertEqual(fields[10].id, "6629fb77593e3791638628bb")
        XCTAssertEqual(fields[10].identifier, "field_6629fb8e57f251ebbbc8c915")
        XCTAssertEqual(fields[10].title, "Dropdown")
        XCTAssertEqual(fields[10].description, "")
        XCTAssertEqual(fields[10].value?.text, "6628f2e183591f3efa7f76f9")
        XCTAssertEqual(fields[10].required, false)
        XCTAssertEqual(fields[10].tipTitle, "")
        XCTAssertEqual(fields[10].tipDescription, "")
        XCTAssertEqual(fields[10].tipVisible, false)
        XCTAssertEqual(fields[10].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(fields[10].options?[0].id, "6628f2e183591f3efa7f76f9")
        XCTAssertEqual(fields[10].options?[1].id, "6628f2e15cea1b971f6a9383")
        XCTAssertEqual(fields[10].options?[2].id, "6628f2e1817f03440bc70a46")
    }
    
    func assertMultipleChoiceField() {
        XCTAssertEqual(fields[11].type, "multiSelect")
        XCTAssertEqual(fields[11].id, "6629fb9f4d912053577652b1")
        XCTAssertEqual(fields[11].identifier, "field_6629fbb02b40c2f4d0c95b38")
        XCTAssertEqual(fields[11].title, "Multiple Choice")
        XCTAssertEqual(fields[11].description, "")
        XCTAssertEqual(fields[11].value?.multiSelector, ["6628f2e1d0c98c6987cc6021", "6628f2e19c3cba4fdf9e5f19"])
        XCTAssertEqual(fields[11].required, false)
        XCTAssertEqual(fields[11].tipTitle, "")
        XCTAssertEqual(fields[11].tipDescription, "")
        XCTAssertEqual(fields[11].tipVisible, false)
        XCTAssertEqual(fields[11].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(fields[11].options?.count, 3)
        XCTAssertEqual(fields[11].options?[0].id, "6628f2e1d0c98c6987cc6021")
        XCTAssertEqual(fields[11].options?[1].id, "6628f2e19c3cba4fdf9e5f19")
        XCTAssertEqual(fields[11].options?[2].id, "6628f2e1679bcf815adfa0f6")
    }
    
    func assertSingleChoiceField() {
        XCTAssertEqual(fields[12].type, "multiSelect")
        XCTAssertEqual(fields[12].id, "6629fbb2bf4f965b9d04f153")
        XCTAssertEqual(fields[12].identifier, "field_6629fbb5b16c74b78381af3b")
        XCTAssertEqual(fields[12].title, "Single Choice")
        XCTAssertEqual(fields[12].description, "")
        XCTAssertEqual(fields[12].value?.multiSelector, ["6628f2e1fae456e6b850e85e"])
        XCTAssertEqual(fields[12].required, false)
        XCTAssertEqual(fields[12].tipTitle, "")
        XCTAssertEqual(fields[12].tipDescription, "")
        XCTAssertEqual(fields[12].tipVisible, false)
        XCTAssertEqual(fields[12].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(fields[12].options?.count, 3)
        XCTAssertEqual(fields[12].options?[0].id, "6628f2e1fae456e6b850e85e")
        XCTAssertEqual(fields[12].options?[1].id, "6628f2e13e1e340a51d9ecca")
        XCTAssertEqual(fields[12].options?[2].id, "6628f2e16bf0362dd5498eb4")
    }
    
    func assertSignatureField() {
        XCTAssertEqual(fields[13].type, "signature")
        XCTAssertEqual(fields[13].id, "6629fbb8cd16c0c4d308a252")
        XCTAssertEqual(fields[13].identifier, "field_6629fbbcb1f415665455fea4")
        XCTAssertEqual(fields[13].title, "Signature")
        XCTAssertEqual(fields[13].description, "")
        XCTAssertEqual(fields[13].value?.signatureURL, "data:image/png;base64,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")
        XCTAssertEqual(fields[13].required, false)
        XCTAssertEqual(fields[13].tipTitle, "")
        XCTAssertEqual(fields[13].tipDescription, "")
        XCTAssertEqual(fields[13].tipVisible, false)
        XCTAssertEqual(fields[13].file, "6629fab3c0ba3fb775b4a55c")
    }
    
    func assertTableField() {
        XCTAssertEqual(fields[14].type, "table")
        XCTAssertEqual(fields[14].id, "6629fbc0d449f4216e871e3f")
        XCTAssertEqual(fields[14].identifier, "field_6629fbc7915c00c8678c9430")
        XCTAssertEqual(fields[14].title, "Table")
        XCTAssertEqual(fields[14].description, "")
        XCTAssertEqual(fields[14].required, false)
        XCTAssertEqual(fields[14].tipTitle, "")
        XCTAssertEqual(fields[14].tipDescription, "")
        XCTAssertEqual(fields[14].tipVisible, false)
        XCTAssertEqual(fields[14].file, "6629fab3c0ba3fb775b4a55c")
        
//        XCTAssertEqual(fields[14].value?.valueElements?.count, 3)
//        XCTAssertEqual(fields[14].value?.valueElements?[0].id, "6628f2e142ffeada4206bbdb")
//        XCTAssertEqual(fields[14].value?.valueElements?[0].deleted, false)
//        XCTAssertEqual(fields[14].value?.valueElements?[0].cells?["6628f2e11a2b28119985cfbb"]?.text, "Hello")
//        XCTAssertEqual(fields[14].value?.valueElements?[0].cells?["6628f2e123ca77fa82a2c45e"]?.text, "6628f2e1846cc78241aa6b11")
//        
//        XCTAssertEqual(fields[14].value?.valueElements?[1].id, "6628f2e1a6b5e93e8dde45f8")
//        XCTAssertEqual(fields[14].value?.valueElements?[1].deleted, false)
//        XCTAssertEqual(fields[14].value?.valueElements?[1].cells?["6628f2e11a2b28119985cfbb"]?.text, "His")
//        XCTAssertEqual(fields[14].value?.valueElements?[1].cells?["6628f2e123ca77fa82a2c45e"]?.text, "6628f2e1c12db4664e9eb38f")
//        
//        XCTAssertEqual(fields[14].value?.valueElements?[2].id, "6628f2e1750679d671be36b8")
//        XCTAssertEqual(fields[14].value?.valueElements?[2].deleted, false)
//        XCTAssertEqual(fields[14].value?.valueElements?[2].cells?["6628f2e11a2b28119985cfbb"]?.text, "His")
//        XCTAssertEqual(fields[14].value?.valueElements?[2].cells?["6628f2e123ca77fa82a2c45e"]?.text, "6628f2e1c12db4664e9eb38f")
        
        XCTAssertEqual(fields[14].rowOrder?.count, 3)
        XCTAssertEqual(fields[14].rowOrder?[0], "6628f2e142ffeada4206bbdb")
        XCTAssertEqual(fields[14].rowOrder?[1], "6628f2e1a6b5e93e8dde45f8")
        XCTAssertEqual(fields[14].rowOrder?[2], "6628f2e1750679d671be36b8")
        
        XCTAssertEqual(fields[14].tableColumns?.count, 3)
        XCTAssertEqual(fields[14].tableColumns?[0].id, "6628f2e11a2b28119985cfbb")
        XCTAssertEqual(fields[14].tableColumns?[0].type, "text")
        XCTAssertEqual(fields[14].tableColumns?[0].title, "Text Column")
        XCTAssertEqual(fields[14].tableColumns?[0].width, 0)
        XCTAssertEqual(fields[14].tableColumns?[0].identifier, "field_column_6629fbc70c9e53f683a18007")
        
        XCTAssertEqual(fields[14].tableColumns?[1].id, "6628f2e123ca77fa82a2c45e")
        XCTAssertEqual(fields[14].tableColumns?[1].type, "dropdown")
        XCTAssertEqual(fields[14].tableColumns?[1].title, "Dropdown Column")
        XCTAssertEqual(fields[14].tableColumns?[1].width, 0)
        XCTAssertEqual(fields[14].tableColumns?[1].identifier, "field_column_6629fbc7e2493a155a32c509")
        
        XCTAssertEqual(fields[14].tableColumns?[2].id, "663dcdcfcd08ad955955fd95")
        XCTAssertEqual(fields[14].tableColumns?[2].type, "image")
        XCTAssertEqual(fields[14].tableColumns?[2].title, "Image Column")
        XCTAssertEqual(fields[14].tableColumns?[2].width, 0)
        XCTAssertEqual(fields[14].tableColumns?[2].identifier, "")
        
        XCTAssertEqual(fields[14].tableColumnOrder?.count, 3)
        XCTAssertEqual(fields[14].tableColumnOrder?[0], "6628f2e11a2b28119985cfbb")
        XCTAssertEqual(fields[14].tableColumnOrder?[1], "6628f2e123ca77fa82a2c45e")
        XCTAssertEqual(fields[14].tableColumnOrder?[2], "663dcdcfcd08ad955955fd95")
    }
    
    func asssertChartField() {
        XCTAssertEqual(fields[15].type, "chart")
        XCTAssertEqual(fields[15].id, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(fields[15].identifier, "field_6629fbdd498f2c3131051bb4")
        XCTAssertEqual(fields[15].title, "Chart")
        XCTAssertEqual(fields[15].description, "")
        XCTAssertEqual(fields[15].required, false)
        XCTAssertEqual(fields[15].tipTitle, "")
        XCTAssertEqual(fields[15].tipDescription, "")
        XCTAssertEqual(fields[15].tipVisible, false)
        XCTAssertEqual(fields[15].file, "6629fab3c0ba3fb775b4a55c")
        XCTAssertEqual(fields[15].value?.valueElements?[0].id, "662a4ac36cb46cb39dd48090")
        XCTAssertEqual(fields[15].value?.valueElements?[0].points?[0].id, "662a4ac3a09a7fa900990da3")
        XCTAssertEqual(fields[15].value?.valueElements?[0].points?[1].id, "662a4ac332c49d08cc4da9b8")
        XCTAssertEqual(fields[15].value?.valueElements?[0].points?[2].id, "662a4ac305c6948e2ffe8ab1")
        XCTAssertEqual(fields[15].yTitle, "Vertical")
        XCTAssertEqual(fields[15].yMax, 100)
        XCTAssertEqual(fields[15].yMin, 0)
        XCTAssertEqual(fields[15].xTitle, "Horizontal")
        XCTAssertEqual(fields[15].xMax, 100)
        XCTAssertEqual(fields[15].xMin, 0)
    }
    
    func assertPageField() {
        XCTAssertEqual(files[0].pages?.count, 1)
        XCTAssertEqual(files[0].pages?[0].name, "New Page")
        XCTAssertEqual(files[0].pages?[0].hidden, false)
        XCTAssertEqual(files[0].pages?[0].width, 816)
        XCTAssertEqual(files[0].pages?[0].height, 1056)
        XCTAssertEqual(files[0].pages?[0].cols, 24)
        XCTAssertEqual(files[0].pages?[0].rowHeight, 8)
        XCTAssertEqual(files[0].pages?[0].layout, "grid")
        XCTAssertEqual(files[0].pages?[0].presentation, "normal")
        XCTAssertEqual(files[0].pages?[0].margin, 0)
        XCTAssertEqual(files[0].pages?[0].padding, 0)
        XCTAssertEqual(files[0].pages?[0].borderWidth, 0)
        XCTAssertEqual(files[0].pages?[0].backgroundImage, "https://s3.amazonaws.com/docspace.production.documents/5cca363a20d5f31fe3d7d6a2/pdfTemplates/614892aeb47c0f58db8ebd0a/page1631330091520-2f189ce0-1631330091522.png")
        XCTAssertEqual(files[0].pages?[0].id, "6629fab320fca7c8107a6cf6")
    }
    
    func assertImageFieldPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[0].field, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[0].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[0].width, 9)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[0].height, 23)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[0].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[0].y, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[0].id, "6629fab82ddb5cdd73a2f27f")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[0].type, FieldTypes.image)
    }
    
    func assertHeadingTextPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].field, "6629fad980958bff0608cd4a")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].height, 5)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].y, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].fontSize, 28)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].fontWeight, "bold")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].id, "6629fadcacdb1bb9b9bbfdce")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[1].type, FieldTypes.block)
    }
    
    func assertDisplayTextPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[2].field, "6629faf0868164d68b4cf359")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[2].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[2].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[2].height, 5)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[2].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[2].y, 7)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[2].id, "6629faf7cdcf955b0b3d2daa")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[2].type, FieldTypes.block)
    }
    
    func assertEmptySpacePosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].field, "6629fb050c62b1fe457b58e0")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].height, 2)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].y, 5)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].borderColor, "transparent")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].backgroundColor, "transparent")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].id, "6629fb0b7b10702947a43488")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[3].type, FieldTypes.block)
    }
    
    func assertTextPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[4].field, "6629fb1d92a76d06750ca4a1")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[4].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[4].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[4].height, 8)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[4].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[4].y, 35)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[4].id, "6629fb203149d1c34cc6d6f8")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[4].type, FieldTypes.text)
    }
    
    
    func assertMultiLineTextPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[5].field, "6629fb2b9a487ce1c1f35f6c")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[5].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[5].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[5].height, 20)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[5].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[5].y, 43)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[5].id, "6629fb2fca14b3e2ef978349")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[5].type, FieldTypes.textarea)
    }
    
    func assertNumberPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[6].field, "6629fb3df03de10b26270ab3")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[6].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[6].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[6].height, 8)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[6].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[6].y, 63)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[6].id, "6629fb3f2eff74a9ca322bb5")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[6].type, FieldTypes.number)
    }
    
    func assertDatePosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].field, "6629fb44c79bb16ce072d233")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].height, 8)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].y, 71)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].format, "MM/DD/YYYY")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].id, "6629fb4451f3bf2eb2f46567")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[7].type, FieldTypes.date)
    }
    
    func assertTimePosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].field, "6629fb638e230f348d0a8682")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].height, 8)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].y, 79)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].format, "hh:mma")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].id, "6629fb66420b995d026e480b")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[8].type, FieldTypes.date)
    }
    
    func assertDateTimePosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].field, "6629fb6ec5d88d3aadf548ca")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].height, 8)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].y, 87)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].format, "MM/DD/YYYY hh:mma")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].id, "6629fb749d0c1af5e94dbac7")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[9].type, FieldTypes.date)
    }
    
    func assertDropdownPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].field, "6629fb77593e3791638628bb")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].height, 8)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].y, 95)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].targetValue, "6628f2e183591f3efa7f76f9")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].id, "6629fb8ea500024170241af3")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[10].type, FieldTypes.dropdown)
    }
    
    func assertMultiselectPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].field, "6629fb9f4d912053577652b1")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].height, 15)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].y, 103)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].targetValue, "6628f2e1d0c98c6987cc6021")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].id, "6629fbb06e14e0bcaeabf05b")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[11].type, FieldTypes.multiSelect)
    }
    
    func assertSingleSelectPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].field, "6629fbb2bf4f965b9d04f153")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].height, 15)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].y, 118)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].targetValue, "6628f2e1fae456e6b850e85e")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].id, "6629fbb5daa40d68bf26525f")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[12].type, FieldTypes.multiSelect)
    }
    
    func assertSignaturePosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[13].field, "6629fbb8cd16c0c4d308a252")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[13].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[13].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[13].height, 23)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[13].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[13].y, 133)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[13].id, "6629fbbc88ec687f865a53da")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[13].type, FieldTypes.signature)
    }
    
    func assertTablePosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[14].field, "6629fbc0d449f4216e871e3f")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[14].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[14].width, 24)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[14].height, 15)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[14].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[14].y, 156)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[14].id, "6629fbc736d179b9014abae0")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[14].type, FieldTypes.table)
    }
    
    func assertChartPosition() {
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].field, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].displayType, "original")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].width, 12)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].height, 27)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].x, 0)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].y, 171)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].primaryDisplayOnly, true)
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].id, "6629fbddabbd2a54f548bb95")
        XCTAssertEqual(files[0].pages?[0].fieldPositions?[15].type, FieldTypes.chart)
    }
    
    func assertNumberField() {
        XCTAssertEqual(fields[6].type, "number")
        XCTAssertEqual(fields[6].id, "6629fb3df03de10b26270ab3")
        XCTAssertEqual(fields[6].identifier, "field_6629fb3fabb87e37c9578b8b")
        XCTAssertEqual(fields[6].title, "Number")
        XCTAssertEqual(fields[6].description, "")
        XCTAssertEqual(fields[6].value?.number, 98789)
        XCTAssertEqual(fields[6].required, false)
        XCTAssertEqual(fields[6].tipTitle, "")
        XCTAssertEqual(fields[6].tipDescription, "")
        XCTAssertEqual(fields[6].tipVisible, false)
        XCTAssertEqual(fields[6].file, "6629fab3c0ba3fb775b4a55c")
        assertMultilineTextField()
    }
}
