import Foundation
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
        file.views = []
        
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
        var dict = ["url":"https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw",
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
        field.value = .string("data:image/png;base64,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")
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
        column3.id = "663dcdcfcd08ad955955fd95"
        column3.type = "image"
        column3.title = "Image Column"
        column3.width = 0
        column3.identifier = ""
        field.tableColumns = [column1,column2,column3]
        field.tableColumnOrder = [
            "6628f2e11a2b28119985cfbb",
            "6628f2e123ca77fa82a2c45e",
            "663dcdcfcd08ad955955fd95"
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
        if var pages = document.files[0].pages {
            pages.append(page)
            document.files[0].pages = pages
        } else {
            document.files[0].pages = [page]
        }
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
