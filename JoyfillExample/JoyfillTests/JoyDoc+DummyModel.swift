import Foundation
import XCTest
import JoyfillModel

extension JoyDoc {
    func setDocument() -> JoyDoc {
        var document = self
        document.id = "6629fc6367b3a40644096182"
        document.type = "document"
        document.stage = "published"
        document.source = "template_6629fab38559d3017b0308b0"
        document.identifier = "doc_6629fc6367b3a40644096182"
        document.name = "All Fields Template"
        document.createdOn = 1714027619864
        document.deleted = false
        document.files = []
        document.fields = []
        return document
    }
    
    func setFile() -> JoyDoc {
        var file = File()
        file.id = "6629fab3c0ba3fb775b4a55c"
        file.name = "All Fields Template"
        file.version = 1
        file.styles = Metadata(dictionary: [:])
        file.pageOrder = ["6629fab320fca7c8107a6cf6"]
        file.views?.isEmpty
        
        var document = self
        document.files.append(file)
        return document
    }
    
    func setImagefields() -> JoyDoc {
        var field = JoyDocField()
        field.type = "image"
        field.id = "6629fab36e8925135f0cdd4f"
        field.identifier = "field_6629fab87c5c8ff831b8d223"
        field.title = "Image"
        field.description = ""
        var dict = ["url":"https://s3.amazonaws.com/docspace.production.documents/6628f1034892618fc118503b/documents/template_6629fab38559d3017b0308b0/6629fad945f22ce76d678f37-1714027225742.png",
                    "fileName":"6629fad945f22ce76d678f37-1714027225742.png",
                    "_id":"6629fad9a6d0c81c8c217fc5",
                    "filePath":"6628f1034892618fc118503b/documents/template_6629fab38559d3017b0308b0"
        ]
        let arrayOfValueElements = [ValueElement(dictionary: dict)]
        field.value = .valueElementArray(arrayOfValueElements)
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.multi = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setHeadingText() -> JoyDoc {
        var field = JoyDocField()
        field.type = "block"
        field.id = "6629fad980958bff0608cd4a"
        field.identifier = "field_6629fadcfc73f30cbb7b785a"
        field.title = "Heading Text"
        field.description = ""
        field.value = .string("Form View")
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setDisplayText() -> JoyDoc {
        var field = JoyDocField()
        field.type = "block"
        field.id = "6629faf0868164d68b4cf359"
        field.identifier = "field_6629faf7fb9bfd2cfc6bb830"
        field.title = "Display Text"
        field.description = ""
        field.value = .string("All Fields ")
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setEmptySpaceField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "block"
        field.id = "6629fb050c62b1fe457b58e0"
        field.identifier = "field_6629fb0b3079250a86dac94f"
        field.title = "Empty Space"
        field.description = ""
        field.value = .string("")
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setTextField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "text"
        field.id = "6629fb1d92a76d06750ca4a1"
        field.identifier = "field_6629fb20c9e72451c769df47"
        field.title = "Heading Text"
        field.description = ""
        field.value = .string("Hello sir")
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setMultilineTextField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "textarea"
        field.id = "6629fb2b9a487ce1c1f35f6c"
        field.identifier = "field_6629fb2feff29e90331e4e8e"
        field.title = "Multiline Text"
        field.description = ""
        field.value = .string("Hello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir")
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setNumberField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "number"
        field.id = "6629fb3df03de10b26270ab3"
        field.identifier = "field_6629fb3fabb87e37c9578b8b"
        field.title = "Number"
        field.description = ""
        field.value = .double(98789)
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setDateField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb44c79bb16ce072d233"
        field.identifier = "field_6629fb44309fbfe84376095e"
        field.title = "Date"
        field.description = ""
        field.value = .double(1712255400000)
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setTimeField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb638e230f348d0a8682"
        field.identifier = "field_6629fb669a6d216e2a9c8dcd"
        field.title = "Time"
        field.description = ""
        field.value = .double(1713984174769)
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setDateTimeField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb6ec5d88d3aadf548ca"
        field.identifier = "field_6629fb74e6c43707ad6101f7"
        field.title = "Date Time"
        field.description = ""
        field.value = .double(1712385780000)
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setDropdownField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "dropdown"
        field.id = "6629fb77593e3791638628bb"
        field.identifier = "field_6629fb8e57f251ebbbc8c915"
        field.title = "Dropdown"
        field.description = ""
        field.value = .string("6628f2e183591f3efa7f76f9")
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.options = [Option(), Option(), Option()]
        field.options?[0].id = "6628f2e183591f3efa7f76f9"
        field.options?[1].id = "6628f2e15cea1b971f6a9383"
        field.options?[2].id = "6628f2e1817f03440bc70a46"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setMultipleChoiceField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "multiSelect"
        field.id = "6629fb9f4d912053577652b1"
        field.identifier = "field_6629fbb02b40c2f4d0c95b38"
        field.title = "Multiple Choice"
        field.description = ""
        field.value = .array(["6628f2e1d0c98c6987cc6021", "6628f2e19c3cba4fdf9e5f19"])
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.options = [Option(), Option(), Option()]
        field.options?[0].id = "6628f2e1d0c98c6987cc6021"
        field.options?[1].id = "6628f2e19c3cba4fdf9e5f19"
        field.options?[2].id = "6628f2e1679bcf815adfa0f6"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setSingleChoiceField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "multiSelect"
        field.id = "6629fbb2bf4f965b9d04f153"
        field.identifier = "field_6629fbb5b16c74b78381af3b"
        field.title = "Single Choice"
        field.description = ""
        field.value = .array(["6628f2e1fae456e6b850e85e"])
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.options = [Option(), Option(), Option()]
        field.options?[0].id = "6628f2e1fae456e6b850e85e"
        field.options?[1].id = "6628f2e13e1e340a51d9ecca"
        field.options?[2].id = "6628f2e16bf0362dd5498eb4"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setSignatureField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "signature"
        field.id = "6629fbb8cd16c0c4d308a252"
        field.identifier = "field_6629fbbcb1f415665455fea4"
        field.title = "Signature"
        field.description = ""
        field.value = .string("data:image/png;base64,iVBOR")
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setTableField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "table"
        field.id = "6629fbc0d449f4216e871e3f"
        field.identifier = "field_6629fbc7915c00c8678c9430"
        field.title = "Table"
        field.description = ""
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.rowOrder = [
            "6628f2e142ffeada4206bbdb",
            "6628f2e1a6b5e93e8dde45f8",
            "6628f2e1750679d671be36b8"
        ]
        var column1 = FieldTableColumn()
        column1.id = "6628f2e11a2b28119985cfbb"
        column1.type = "text"
        column1.title = "Text Column"
        column1.width = 0
        column1.identifier = "field_column_6629fbc70c9e53f683a18007"
        var column2 = FieldTableColumn()
        column2.id = "6628f2e123ca77fa82a2c45e"
        column2.type = "dropdown"
        column2.title = "Dropdown Column"
        column2.width = 0
        column2.identifier = "field_column_6629fbc7e2493a155a32c509"
        var column3 = FieldTableColumn()
        column3.id = "6628f2e1355b7d93cea30f3c"
        column3.type = "text"
        column3.title = "Text Column"
        column3.width = 0
        column3.identifier = "field_column_6629fbc782667100aa64d18d"
        field.tableColumns = [column1,column2,column3]
        field.tableColumnOrder = [
            "6628f2e11a2b28119985cfbb",
            "6628f2e123ca77fa82a2c45e",
            "6628f2e1355b7d93cea30f3c"
        ]
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setChartField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "chart"
        field.id = "6629fbd957d928a973b1b42b"
        field.identifier = "field_6629fbdd498f2c3131051bb4"
        field.title = "Chart"
        field.description = ""
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        let point1 = Point(dictionary: ["_id" : "662a4ac3a09a7fa900990da3"])
        let point2 = Point(dictionary: ["_id" : "662a4ac332c49d08cc4da9b8"])
        let point3 = Point(dictionary: ["_id" : "662a4ac305c6948e2ffe8ab1"])
        let pointValueElement: ValueElement = ValueElement(id: "662a4ac36cb46cb39dd48090", points: [point1, point2, point3])
        field.value = .valueElementArray([pointValueElement])
        field.yTitle = "Vertical"
        field.yMax = 100
        field.yMin = 0
        field.xTitle = "Horizontal"
        field.xMax = 100
        field.xMin = 0
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setPageField() -> JoyDoc {
        var page = Page()
        page.name = "New Page"
        page.hidden = false
        page.width = 816
        page.height = 1056
        page.cols = 24
        page.rowHeight = 8
        page.layout = "grid"
        page.presentation = "normal"
        page.margin = 0
        page.padding = 0
        page.borderWidth = 0
        page.backgroundImage = "https://s3.amazonaws.com/docspace.production.documents/5cca363a20d5f31fe3d7d6a2/pdfTemplates/614892aeb47c0f58db8ebd0a/page1631330091520-2f189ce0-1631330091522.png"
        page.id = "6629fab320fca7c8107a6cf6"
        var document = self
        document.files[0].pages?.append(page)
        return document
    }
    
    func setImageFieldPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fab36e8925135f0cdd4f"
        fieldPosition.displayType = "original"
        fieldPosition.width = 9
        fieldPosition.height = 23
        fieldPosition.x = 0
        fieldPosition.y = 12
        fieldPosition.id = "6629fab82ddb5cdd73a2f27f"
        fieldPosition.type = .image
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    
    func setHeadingTextPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fad980958bff0608cd4a"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 5
        fieldPosition.x = 0
        fieldPosition.y = 0
        fieldPosition.fontSize = 28
        fieldPosition.fontWeight = "bold"
        fieldPosition.id = "6629fadcacdb1bb9b9bbfdce"
        fieldPosition.type = .block
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setDisplayTextPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629faf0868164d68b4cf359"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 5
        fieldPosition.x = 0
        fieldPosition.y = 7
        fieldPosition.fontSize = 28
        fieldPosition.fontWeight = "bold"
        fieldPosition.id = "6629faf7cdcf955b0b3d2daa"
        fieldPosition.type = .block
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setEmptySpacePosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb050c62b1fe457b58e0"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 2
        fieldPosition.x = 0
        fieldPosition.y = 5
        fieldPosition.borderColor = "transparent"
        fieldPosition.backgroundColor = "transparent"
        fieldPosition.id = "6629fb0b7b10702947a43488"
        fieldPosition.type = .block
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setTextPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb1d92a76d06750ca4a1"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 35
        fieldPosition.id = "6629fb203149d1c34cc6d6f8"
        fieldPosition.type = .text
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setMultiLineTextPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb2b9a487ce1c1f35f6c"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 20
        fieldPosition.x = 0
        fieldPosition.y = 43
        fieldPosition.id = "6629fb2fca14b3e2ef978349"
        fieldPosition.type = .textarea
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setNumberPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb3df03de10b26270ab3"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 63
        fieldPosition.id = "6629fb3f2eff74a9ca322bb5"
        fieldPosition.type = .number
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setDatePosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb44c79bb16ce072d233"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 71
        fieldPosition.format = "MM/DD/YYYY"
        fieldPosition.id = "6629fb4451f3bf2eb2f46567"
        fieldPosition.type = .date
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setTimePosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb638e230f348d0a8682"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 79
        fieldPosition.format = "hh:mma"
        fieldPosition.id = "6629fb66420b995d026e480b"
        fieldPosition.type = .date
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setDateTimePosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb6ec5d88d3aadf548ca"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 87
        fieldPosition.format = "MM/DD/YYYY hh:mma"
        fieldPosition.id = "6629fb749d0c1af5e94dbac7"
        fieldPosition.type = .date
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setDropdownPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb77593e3791638628bb"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 95
        fieldPosition.targetValue = "6628f2e183591f3efa7f76f9"
        fieldPosition.id = "6629fb8ea500024170241af3"
        fieldPosition.type = .dropdown
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setMultiselectPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb9f4d912053577652b1"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 15
        fieldPosition.x = 0
        fieldPosition.y = 103
        fieldPosition.targetValue = "6628f2e1d0c98c6987cc6021"
        fieldPosition.id = "6629fbb06e14e0bcaeabf05b"
        fieldPosition.type = .multiSelect
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setSingleSelectPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fbb2bf4f965b9d04f153"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 15
        fieldPosition.x = 0
        fieldPosition.y = 118
        fieldPosition.targetValue = "6628f2e1fae456e6b850e85e"
        fieldPosition.id = "6629fbb5daa40d68bf26525f"
        fieldPosition.type = .multiSelect
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setSignaturePosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fbb8cd16c0c4d308a252"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 23
        fieldPosition.x = 0
        fieldPosition.y = 133
        fieldPosition.id = "6629fbbc88ec687f865a53da"
        fieldPosition.type = .signature
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setTablePosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fbc0d449f4216e871e3f"
        fieldPosition.displayType = "original"
        fieldPosition.width = 24
        fieldPosition.height = 15
        fieldPosition.x = 0
        fieldPosition.y = 156
        fieldPosition.id = "6629fbc736d179b9014abae0"
        fieldPosition.type = .table
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setChartPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fbd957d928a973b1b42b"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 27
        fieldPosition.x = 0
        fieldPosition.y = 171
        fieldPosition.primaryDisplayOnly = true
        fieldPosition.id = "6629fbddabbd2a54f548bb95"
        fieldPosition.type = .chart
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
}
