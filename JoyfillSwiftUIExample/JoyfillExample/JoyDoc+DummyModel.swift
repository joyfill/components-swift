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
    
    func setCollectionFieldPosition() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "67ddc52d35de157f6d7ebb63" // Collection field id
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 10
        fieldPosition.x = 0
        fieldPosition.y = 50
        fieldPosition.id = "67ddc52d35de157f6d7ebb63_pos" // Unique id for the field position
        fieldPosition.type = .collection  // Ensure your FieldPositionType enum supports .collection; otherwise, use .table
        
        var document = self
        // Append the new field position to the first page of the first view of the first file.
        if document.files.count > 0,
           let _ = document.files[0].views,
           let _ = document.files[0].views?[0].pages {
            document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
        }
        return document
    }
        
    func setCollectionField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "collection"
        field.id = "67ddc52d35de157f6d7ebb63" // Reference id
        field.identifier = "field_67ddc530213a11e84876b001" // Reference identifier
        field.title = "Collection"
        field.description = ""
        
        // Build the collection rows using our model initializers.
        let collectionValue: [ValueElement] = [
            // First row
            ValueElement(dictionary: [
                "_id": "67ddc5327e6841a074d9240b",
                "cells": [
                    "67ddc5adbb96a9b9f9ff1480": "Grok ",
                    "67ddc2ndblock9f9ff1480": "hi yfgbfr",
                    "67ddc4db157f14f67da0616a": "joyfill",
                    "67ddc59c4aba2df34a6dd1c4": ValueUnion.double(300)
                ],
                "children": [String: Any]()
            ]),
            // Second row with nested children
            ValueElement(dictionary: [
                "_id": "67ddc537b7c2fce05d0c8615",
                "cells": [
                    "67ddc5adbb96a9b9f9ff1480": "First",
                    "67ddc4db157f14f67da0616a": "joyfill"
                ],
                "children": [
                    "67ddc5c9910a394a1324bfbe": [
                        "value": [
                            ValueElement(dictionary: [
                                "_id": "67ddd18bc3a74e6b350987f9",
                                "cells": [
                                    "67ddc61edce16f8b9f8dbf4b": "Grok "
                                ],
                                "children": [String: Any]()
                            ]),
                            ValueElement(dictionary: [
                                "_id": "67ddd191ab6a428ea69c77ad",
                                "cells": [
                                    "67ddc61edce16f8b9f8dbf4b": "First "
                                ],
                                "children": [
                                    "67ddc5f5c2477e8457956fb4": [
                                        "value": [
                                            ValueElement(dictionary: [
                                                "_id": "67ddd1a5e6d0d62d55a7aaad",
                                                "cells": [String: Any](),
                                                "children": [String: Any]()
                                            ]),
                                            ValueElement(dictionary: [
                                                "_id": "67ddd1a656a259a9b6ab1263",
                                                "cells": [String: Any](),
                                                "children": [String: Any]()
                                            ]),
                                            ValueElement(dictionary: [
                                                "_id": "67ddd1a779642224075bf23c",
                                                "cells": [String: Any](),
                                                "children": [String: Any]()
                                            ])
                                        ]
                                    ]
                                ]
                            ]),
                            ValueElement(dictionary: [
                                "_id": "67ddd193eae737b64c24851a",
                                "cells": [String: Any](),
                                "children": [String: Any]()
                            ])
                        ]
                    ],
                    "67ddcf4f622984fb4518cbc2": [
                        "value": [
                            ValueElement(dictionary: [
                                "_id": "67ddd1994c086e45784edb76",
                                "cells": [String: Any](),
                                "children": [String: Any]()
                            ]),
                            ValueElement(dictionary: [
                                "_id": "67ddd19f8577eb22eee2c57d",
                                "cells": [String: Any](),
                                "children": [String: Any]()
                            ]),
                            ValueElement(dictionary: [
                                "_id": "67ddd1a03789211ac5f657e3",
                                "cells": [String: Any](),
                                "children": [String: Any]()
                            ])
                        ]
                    ]
                ]
            ]),
            // Third row
            ValueElement(dictionary: [
                "_id": "67ddc538123468491bc1d6ac",
                "cells": [
                    "67ddc5adbb96a9b9f9ff1480": "First "
                ],
                "children": [String: Any]()
            ]),
            // Fourth row
            ValueElement(dictionary: [
                "_id": "67ddc53924f0bd68beb066ca",
                "cells": [
                    "67ddc4db157f14f67da0616a": "joyfill"
                ],
                "children": [String: Any]()
            ])
        ]
        
        // Assign the collection value using the model representation.
        field.value = .valueElementArray(collectionValue)
        
        let collectionSchema: [String: Any] = [
                "collectionSchemaId": [
                    "title": "Main Collection",
                    "root": true,
                    "children": [
                        "67ddc5c9910a394a1324bfbe",
                        "67ddcf4f622984fb4518cbc2"
                    ],
                    "tableColumns": [
                        [
                            "_id": "67ddc4db157f14f67da0616a",
                            "type": "text",
                            "title": "Text Column",
                            "identifier": "field_column_67ddc4e0457002b72007e321",
                            "value": "Text Column: Grok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from X"
                        ],
                        [
                            "_id": "67ddc4db898e2fb0ad3a8d19",
                            "type": "dropdown",
                            "title": "Dropdown Column",
                            "options": [
                                [
                                    "_id": "67ddc4dbde8b8bfe6322da24",
                                    "value": "Yes",
                                    "deleted": false
                                ],
                                [
                                    "_id": "67ddc4db94dba485b1642a23",
                                    "value": "No",
                                    "deleted": false
                                ],
                                [
                                    "_id": "67ddc4db3bc809de86ac85d0",
                                    "value": "N/A",
                                    "deleted": false
                                ]
                            ],
                            "identifier": "field_column_67ddc4e093c80641691e8afe",
                            "value": "Grok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from X"
                        ],
                        [
                            "_id": "67ddc59c4aba2df34a6dd1c4",
                            "type": "number",
                            "title": "Number Column",
                            "deleted": false,
                            "width": 0
                        ],
                        [
                            "_id": "67ddc5981816e52ad55b71e6",
                            "type": "multiSelect",
                            "title": "Multiselect Column",
                            "deleted": false,
                            "width": 0,
                            "options": [
                                [
                                    "_id": "67ddc59812e6c0eff62bab58",
                                    "value": "Option 1",
                                    "deleted": false
                                ],
                                [
                                    "_id": "67ddc598fc5c30cacb3459ec",
                                    "value": "Option 2",
                                    "deleted": false
                                
                                ],
                                [
                                    "_id": "67ddc598e4f75aaead71e431",
                                    "value": "Option 3",
                                    "deleted": false
                                ]
                            ],
                            "optionOrder": [
                                "67ddc59812e6c0eff62bab58",
                                "67ddc598fc5c30cacb3459ec",
                                "67ddc598e4f75aaead71e431"
                            ]
                        ]
                    ]
                ],
                "67ddc5c9910a394a1324bfbe": [
                    "title": "Child Table Title",
                    "children": [
                        "67ddc5f5c2477e8457956fb4"
                    ],
                    "tableColumns": [
                        [
                            "_id": "67ddc5c9cb21736a10919b22",
                            "type": "text",
                            "title": "Text Column",
                            "width": 0,
                            "deleted": false
                        ],
                        [
                            "_id": "67ddc609791020b851791f0d",
                            "type": "dropdown",
                            "title": "Dropdown Column",
                            "deleted": false,
                            "width": 0,
                            "options": [
                                [
                                    "_id": "67ddc609599f3ba9fb2f7b2e",
                                    "value": "Yes",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": NSNull()
                                    ]
                                ],
                                [
                                    "_id": "67ddc6091d62cd644f1ccdbb",
                                    "value": "No",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": NSNull()
                                    ]
                                ],
                                [
                                    "_id": "67ddc609a9f8e1a573852153",
                                    "value": "N/A",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": NSNull()
                                    ]
                                ]
                            ],
                            "optionOrder": [
                                "67ddc609599f3ba9fb2f7b2e",
                                "67ddc6091d62cd644f1ccdbb",
                                "67ddc609a9f8e1a573852153"
                            ]
                        ],
                        [
                            "_id": "67ddc60c4f70b8ef5c7a5e3d",
                            "type": "multiSelect",
                            "title": "Multiselect Column",
                            "deleted": false,
                            "width": 0,
                            "options": [
                                [
                                    "_id": "67ddc60c79c89a55825ffb0b",
                                    "value": "Option 1",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": "#f0f0f0"
                                    ]
                                ],
                                [
                                    "_id": "67ddc60c27eb845be497ec8f",
                                    "value": "Option 2",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": "#f0f0f0"
                                    ]
                                ],
                                [
                                    "_id": "67ddc60cbab030d3bf6f260e",
                                    "value": "Option 3",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": "#f0f0f0"
                                    ]
                                ]
                            ],
                            "optionOrder": [
                                "67ddc60c79c89a55825ffb0b",
                                "67ddc60c27eb845be497ec8f",
                                "67ddc60cbab030d3bf6f260e"
                            ]
                        ],
                        [
                            "_id": "67ddc60e1a015ed76fc404fc",
                            "type": "image",
                            "title": "Image Column",
                            "deleted": false,
                            "width": 0,
                            "maxImageWidth": 190,
                            "maxImageHeight": 120
                        ],
                        [
                            "_id": "67ddc6136fbc59b8d02d2723",
                            "type": "number",
                            "title": "Number Column",
                            "deleted": false,
                            "width": 0
                        ],
                        [
                            "_id": "67ddc618ef820f6b8cbc9879",
                            "type": "date",
                            "title": "Date Column",
                            "deleted": false,
                            "width": 0
                        ],
                        [
                            "_id": "67ddc61edce16f8b9f8dbf4b",
                            "type": "block",
                            "title": "Label Column",
                            "width": 0,
                            "deleted": false,
                            "value": "Grok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from XGrok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from X"
                        ],
                        [
                            "_id": "67ddc2ndblock9f9ff1480",
                            "type": "block",
                            "title": "Label Column2323",
                            "width": 0,
                            "deleted": false,
                            "value": "ourehwbfuvyberfhvbeurfbvouwofvyicjhgbvretlweuygficewnfr ru vheoriuhv eiuhv hv iurhtoeurhvduhgvh ev viuehdofuvgweorygh97645268673495234 52345 234 523453 4576 4568745678. 6786"
                        ],
                        [
                            "_id": "67ddc5b323b5b9fc08f3f824",
                            "type": "barcode",
                            "title": "Barcode Column",
                            "width": 0,
                            "deleted": false
                        ],
                        [
                            "_id": "67ddc5b5e2f8843d6d5f6771",
                            "type": "signature",
                            "title": "Signature Column",
                            "width": 0,
                            "deleted": false
                        ]
                    ]
                ],
                "67ddc5f5c2477e8457956fb4": [
                    "title": "Grand Child Table Title",
                    "children": [],
                    "tableColumns": [
                        [
                            "_id": "67ddc5f5107180be0f5befd6",
                            "type": "text",
                            "title": "Text Column",
                            "width": 0,
                            "deleted": false
                        ],
                        [
                            "_id": "67ddd16604dc88ca60898821",
                            "type": "dropdown",
                            "title": "Dropdown Column",
                            "deleted": false,
                            "width": 0,
                            "options": [
                                [
                                    "_id": "67ddd1664a80f93bf1584051",
                                    "value": "Yes",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": NSNull()
                                    ]
                                ],
                                [
                                    "_id": "67ddd1665198425a6554f362",
                                    "value": "No",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": NSNull()
                                    ]
                                ],
                                [
                                    "_id": "67ddd1664e6d82d74191f5b9",
                                    "value": "N/A",
                                    "deleted": false,
                                    "styles": [
                                        "backgroundColor": NSNull()
                                    ]
                                ]
                            ],
                            "optionOrder": [
                                "67ddd1664a80f93bf1584051",
                                "67ddd1665198425a6554f362",
                                "67ddd1664e6d82d74191f5b9"
                            ]
                        ],
                        [
                            "_id": "67ddd16991439221b58a7148",
                            "type": "date",
                            "title": "Date 3rd Column",
                            "deleted": false,
                            "width": 0,
                            "maxImageWidth": 190,
                            "maxImageHeight": 120
                        ]
                    ]
                ],
                "67ddcf4f622984fb4518cbc2": [
                    "title": "2nd Child Table Title: Grok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from X.",
                    "children": [],
                    "tableColumns": [
                        [
                            "_id": "67ddcf4fa46f548aaade239d",
                            "type": "text",
                            "title": "Text Column",
                            "width": 0,
                            "deleted": false
                        ],
                        [
                            "_id": "67ddd17186d63f89705763d9",
                            "type": "barcode",
                            "title": "Barcode Column",
                            "width": 0,
                            "deleted": false
                        ],
                        [
                            "_id": "67ddd174efad8934d569ff8c",
                            "type": "signature",
                            "title": "Signature Column",
                            "width": 0,
                            "deleted": false
                        ]
                    ]
                ]
            ]
        
        field.schema = collectionSchema.mapValues { Schema(dictionary: $0 as! [String: Any]) }
        
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setFile() -> JoyDoc {
        var file = File()
        file.id = "6629fab3c0ba3fb775b4a55c"
        file.name = "All Fields Template"
        file.version = 1
        file.styles = Metadata(dictionary: [:])
        file.pageOrder = ["6629fab320fca7c8107a6cf6", "66600801dc1d8b4f72f54917", "66852e19e780e2aef89ab2c4", "66852e1b8d389f71128a2b86", "66852e1f3bde6be7d0e3966c", "66a0fdb24fc544e2f274060a", "66a1eacc327a9bd5db3b5469", "66a1ead16fbc343e4b5bde0a", "66a383809036dc395dd78ad7", "66a383a3dda2112f45eacde5", "66a383a6574181c946e6fac2", "66aa2463d832a298793aeb28", "66aa286569ad25c65517385e", "66aa297ad6ff5d3f06588fbf", "66aa29c00c2300ab34cc0d7d","6629fab320fca7c8107a6cf6page16"]
        file.views = []
        
        var document = self
        document.files.append(file)
        return document
    }
    
    func setMobileView() -> JoyDoc {
        var view = ModelView()
        view.id = "6629fab320fca7c8107a6cf6"
        view.type = "mobile"
        var document = self
        document.files[0].views = [view]
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
        field.multi = true
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - invalid
    func setRequiredImagefieldsWithoutValue(hidden: Bool = false) -> JoyDoc {
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
        field.value = .valueElementArray([])
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.multi = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.hidden = hidden
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - valid
    func setRequiredImagefieldsWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "image"
        field.id = "6629fab36e8925135f0cdd4f"
        field.identifier = "field_6629fab87c5c8ff831b8d223"
        field.title = "Image"
        field.description = ""
        let dict = ["url":"https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw",
                    "fileName":"6629fad945f22ce76d678f37-1714027225742.png",
                    "_id":"6629fad9a6d0c81c8c217fc5",
                    "filePath":"6628f1034892618fc118503b/documents/template_6629fab38559d3017b0308b0"
        ]
        let arrayOfValueElements = [ValueElement(dictionary: dict)]
        field.value = .valueElementArray(arrayOfValueElements)
        field.required = true
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
        field.tipTitle = "ToolTip Title"
        field.tipDescription = "ToolTip Description"
        field.tipVisible = true
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - invalid
    func setRequiredTextFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "text"
        field.id = "6629fb1d92a76d06750ca4a1"
        field.identifier = "field_6629fb20c9e72451c769df47"
        field.title = "Heading Text"
        field.description = ""
        field.value = .string("")
        field.required = true
        field.tipTitle = "ToolTip Title"
        field.tipDescription = "ToolTip Description"
        field.tipVisible = true
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - valid
    func setRequiredTextFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "text"
        field.id = "6629fb1d92a76d06750ca4a1"
        field.identifier = "field_6629fb20c9e72451c769df47"
        field.title = "Heading Text"
        field.description = ""
        field.value = .string("Valid")
        field.required = true
        field.tipTitle = "ToolTip Title"
        field.tipDescription = "ToolTip Description"
        field.tipVisible = true
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
    
    func setRequiredMultilineTextFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "textarea"
        field.id = "6629fb2b9a487ce1c1f35f6c"
        field.identifier = "field_6629fb2feff29e90331e4e8e"
        field.title = "Multiline Text"
        field.description = ""
        field.value = .string("")
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - Valid
    func setRequiredMultilineTextFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "textarea"
        field.id = "6629fb2b9a487ce1c1f35f6c"
        field.identifier = "field_6629fb2feff29e90331e4e8e"
        field.title = "Multiline Text"
        field.description = ""
        field.value = .string("Valid")
        field.required = true
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
    
    // Status - invalid
    func setRequiredNumberFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "number"
        field.id = "6629fb3df03de10b26270ab3"
        field.identifier = "field_6629fb3fabb87e37c9578b8b"
        field.title = "Number"
        field.description = ""
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - valid
    func setRequiredNumberFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "number"
        field.id = "6629fb3df03de10b26270ab3"
        field.identifier = "field_6629fb3fabb87e37c9578b8b"
        field.title = "Number"
        field.description = ""
        field.value = .double(1230)
        field.required = true
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
    
    // Status - invalid
    func setRequiredDateFieldWithoutValue(hidden: Bool = false) -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb44c79bb16ce072d233"
        field.identifier = "field_6629fb44309fbfe84376095e"
        field.title = "Date"
        field.description = ""
//        field.value = .double(0)
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.hidden = hidden
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - valid
    func setRequiredDateFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb44c79bb16ce072d233"
        field.identifier = "field_6629fb44309fbfe84376095e"
        field.title = "Date"
        field.description = ""
        field.value = .double(1712255400000)
        field.required = true
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
    
    // Status - invalid
    func setRequiredTimeFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb638e230f348d0a8682"
        field.identifier = "field_6629fb669a6d216e2a9c8dcd"
        field.title = "Time"
        field.description = ""
//        field.value = .double(0)
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - valid
    func setRequiredTimeFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb638e230f348d0a8682"
        field.identifier = "field_6629fb669a6d216e2a9c8dcd"
        field.title = "Time"
        field.description = ""
        field.value = .double(1713984174769)
        field.required = true
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
    
    // Status - invalid
    func setRequiredDateTimeFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb6ec5d88d3aadf548ca"
        field.identifier = "field_6629fb74e6c43707ad6101f7"
        field.title = "Date Time"
        field.description = ""
//        field.value = .double(0)
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - valid
    func setRequiredDateTimeFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "date"
        field.id = "6629fb6ec5d88d3aadf548ca"
        field.identifier = "field_6629fb74e6c43707ad6101f7"
        field.title = "Date Time"
        field.description = ""
        field.value = .double(1712385780000)
        field.required = true
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
    
    // Status - invalid
    func setRequiredDropdownFieldWithoutValue(hidden: Bool = false) -> JoyDoc {
        var field = JoyDocField()
        field.type = "dropdown"
        field.id = "6629fb77593e3791638628bb"
        field.identifier = "field_6629fb8e57f251ebbbc8c915"
        field.title = "Dropdown"
        field.description = ""
        field.value = .string("")
        field.required = true
        field.hidden = hidden
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
    
    // Status - valid
    func setRequiredDropdownFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "dropdown"
        field.id = "6629fb77593e3791638628bb"
        field.identifier = "field_6629fb8e57f251ebbbc8c915"
        field.title = "Dropdown"
        field.description = ""
        field.value = .string("6628f2e183591f3efa7f76f9")
        field.required = true
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
        field.value = .array(["6628f2e1d0c98c6987cc6021"])
        field.required = false
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.options = [Option(), Option(), Option()]
        field.options?[0].id = "6628f2e1d0c98c6987cc6021"
        field.options?[1].id = "6628f2e19c3cba4fdf9e5f19"
        field.options?[2].id = "6628f2e1679bcf815adfa0f6"
        field.options?[0].deleted = false
        field.options?[1].deleted = false
        field.options?[2].deleted = true
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - invalid
    func setRequiredMultipleChoiceFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "multiSelect"
        field.id = "6629fb9f4d912053577652b1"
        field.identifier = "field_6629fbb02b40c2f4d0c95b38"
        field.title = "Multiple Choice"
        field.description = ""
        field.value = .array([])
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.options = [Option(), Option(), Option()]
        field.options?[0].id = "6628f2e1d0c98c6987cc6021"
        field.options?[1].id = "6628f2e19c3cba4fdf9e5f19"
        field.options?[2].id = "6628f2e1679bcf815adfa0f6"
        field.options?[0].deleted = false
        field.options?[1].deleted = false
        field.options?[2].deleted = true
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - valid
    func setRequiredMultipleChoiceFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "multiSelect"
        field.id = "6629fb9f4d912053577652b1"
        field.identifier = "field_6629fbb02b40c2f4d0c95b38"
        field.title = "Multiple Choice"
        field.description = ""
        field.value = .array(["6628f2e1d0c98c6987cc6021"])
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.options = [Option(), Option(), Option()]
        field.options?[0].id = "6628f2e1d0c98c6987cc6021"
        field.options?[1].id = "6628f2e19c3cba4fdf9e5f19"
        field.options?[2].id = "6628f2e1679bcf815adfa0f6"
        field.options?[0].deleted = false
        field.options?[1].deleted = false
        field.options?[2].deleted = true
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
    
    // Status - invalid
    func setRequiredSingleChoiceFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "multiSelect"
        field.id = "6629fbb2bf4f965b9d04f153"
        field.identifier = "field_6629fbb5b16c74b78381af3b"
        field.title = "Single Choice"
        field.description = ""
        field.value = .array([])
        field.required = true
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
    
    // Status - valid
    func setRequiredSingleChoiceFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "multiSelect"
        field.id = "6629fbb2bf4f965b9d04f153"
        field.identifier = "field_6629fbb5b16c74b78381af3b"
        field.title = "Single Choice"
        field.description = ""
        field.value = .array(["6628f2e1fae456e6b850e85e"])
        field.required = true
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
    
    // Status - invalid
    func setRequiredSignatureFieldWithoutValue(hidden: Bool = false) -> JoyDoc {
        var field = JoyDocField()
        field.type = "signature"
        field.id = "6629fbb8cd16c0c4d308a252"
        field.identifier = "field_6629fbbcb1f415665455fea4"
        field.title = "Signature"
        field.description = ""
        field.value = .string("")
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.hidden = hidden
        var document = self
        document.fields.append(field)
        return document
    }
    
    // Status - valid
    func setRequiredSignatureFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "signature"
        field.id = "6629fbb8cd16c0c4d308a252"
        field.identifier = "field_6629fbbcb1f415665455fea4"
        field.title = "Signature"
        field.description = ""
        field.value = .string("data:image/png;base64,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")
        field.required = true
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
        column1.type = .text
        column1.title = "Text Column"
        column1.width = 0
        column1.identifier = "field_column_6629fbc70c9e53f683a18007"
        var column2 = FieldTableColumn()
        column2.id = "6628f2e123ca77fa82a2c45e"
        column2.type = .dropdown
        column2.title = "Dropdown Column"
        column2.width = 0
        column2.identifier = "field_column_6629fbc7e2493a155a32c509"
        var column3 = FieldTableColumn()
        column3.id = "663dcdcfcd08ad955955fd95"
        column3.type = .image
        column3.title = "Image Column"
        column3.width = 0
        column3.identifier = ""
        field.tableColumns = [column1,column2,column3]
        field.tableColumnOrder = [
            "6628f2e123ca77fa82a2c45e",
            "6628f2e11a2b28119985cfbb",
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
    
    // Status - invalid
    func setRequiredChartFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "chart"
        field.id = "6629fbd957d928a973b1b42b"
        field.identifier = "field_6629fbdd498f2c3131051bb4"
        field.title = "Chart"
        field.description = ""
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        let point1 = Point(dictionary: ["_id" : "662a4ac3a09a7fa900990da3"])
        let point2 = Point(dictionary: ["_id" : "662a4ac332c49d08cc4da9b8"])
        let point3 = Point(dictionary: ["_id" : "662a4ac305c6948e2ffe8ab1"])
        let pointValueElement: ValueElement = ValueElement(id: "662a4ac36cb46cb39dd48090", points: [point1, point2, point3])
        field.value = .valueElementArray([])
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
    
    // Status - valid
    func setRequiredChartFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "chart"
        field.id = "6629fbd957d928a973b1b42b"
        field.identifier = "field_6629fbdd498f2c3131051bb4"
        field.title = "Chart"
        field.description = ""
        field.required = true
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
    
    // Set Hidden Field
    
    // Page 15 - Number Field
    // Status - valid
    func setRequiredNumberHiddenFieldWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        
        field.type = "number"
        field.id = "66aa29c05db08120464a2875"
        field.identifier = "field_66aa2913e525be6fc66e0bcb"
        field.title = "Number"
        field.description = ""
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.hidden = true
        field.file = "66a0fdb2acd89d30121053b9"
        
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setRequiredNumberHiddenFieldWithoutValuePositionInMobile() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "66aa29c05db08120464a2875"
        fieldPosition.displayType = "original"
        fieldPosition.width = 4
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 8
        fieldPosition.id = "66aa29136c6f17d56a2d9f67"
        fieldPosition.type = .number
        var document = self
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    // Status - valid
    func setRequiredNumberHiddenFieldWithValue() -> JoyDoc {
        var field = JoyDocField()
        
        field.type = "number"
        field.id = "66aa29c05db08120464a2875"
        field.identifier = "field_66aa2913e525be6fc66e0bcb"
        field.title = "Number"
        field.description = ""
        field.value = .double(12345)
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.hidden = true
        field.file = "66a0fdb2acd89d30121053b9"
        
        var document = self
        document.fields.append(field)
        return document
    }
    
    
    // Set Field Postions
    func setPageFieldInMobileView() -> JoyDoc {
        var page = Page()
        page.name = "Page 1"
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
        if var pages = document.files[0].views?[0].pages {
            pages.append(page)
            document.files[0].views?[0].pages = pages
        } else {
            document.files[0].views?[0].pages = [page]
        }
        return document
    }
    
    // Set Field Postions
    func setPageField() -> JoyDoc {
        var page = Page()
        page.name = "Page 1"
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
    
    func setImageFieldPositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
    
    func setTextPositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
    
    func setMultilinePositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
    
    func setNumberPositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
        fieldPosition.format = .dateOnly
        fieldPosition.id = "6629fb4451f3bf2eb2f46567"
        fieldPosition.type = .date
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setDatePositionInMobile() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb44c79bb16ce072d233"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 71
        fieldPosition.format = .dateOnly
        fieldPosition.id = "6629fb4451f3bf2eb2f46567"
        fieldPosition.type = .date
        var document = self
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
        fieldPosition.format = .timeOnly
        fieldPosition.id = "6629fb66420b995d026e480b"
        fieldPosition.type = .date
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setTimePositionInMobile() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb638e230f348d0a8682"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 79
        fieldPosition.format = .timeOnly
        fieldPosition.id = "6629fb66420b995d026e480b"
        fieldPosition.type = .date
        var document = self
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
        fieldPosition.format = .dateTime
        fieldPosition.id = "6629fb749d0c1af5e94dbac7"
        fieldPosition.type = .date
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setDateTimePositionInMobile() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "6629fb6ec5d88d3aadf548ca"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 87
        fieldPosition.format = .dateTime
        fieldPosition.id = "6629fb749d0c1af5e94dbac7"
        fieldPosition.type = .date
        var document = self
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
    
    func setDropdownPositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
    
    func setMultiselectPositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
    
    func setSingleSelectPositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
    
    func setSignaturePositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
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
    
    func setChartPositionInMobile() -> JoyDoc {
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
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    // Condition Field
    func setRequiredTextField() -> JoyDoc {
        var field = JoyDocField()
        field.type = "text"
        field.id = "66aa2865da10ac1c7b7acb1d"
        field.identifier = "field_66aa2520d3285f2fcf8e53b3"
        field.title = "Text"
        field.description = ""
        field.value = .string("Hello")  // Assuming the user enters "Hello"
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "66a0fdb2acd89d30121053b9"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setRequiredTableField(hideColumn: Bool, isTableRequired: Bool, isColumnRequired: Bool, areCellsEmpty: Bool, isZeroRows: Bool, isColumnsZero: Bool, isRowOrderNil: Bool) -> JoyDoc {
        var field = JoyDocField()
        field.type = "table"
        field.id = "67612793c4e6a5e6a05e64a3"
        field.identifier = "field_676127963e76996d780e6c51"
        field.title = "Table"
        field.description = ""
        field.required = isTableRequired
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        if !isRowOrderNil {
            field.rowOrder = [
                "676127938056dcd158942bad",
                "67612793f70928da78973744",
                "67612793a6cd1f9d39c8433b",
                "67612793a6cd1f9d39c8433c",
                "67612793a6cd1f9d39c8433d"
            ]
        }
        var column1 = FieldTableColumn()
        column1.id = "676127938fb7c5fd4321a2f4"
        column1.type = .text
        column1.title = "Text Column"
        column1.width = 0
        column1.identifier = "field_column_6629fbc70c9e53f683a18007"
        column1.required = isColumnRequired
        
        var column2 = FieldTableColumn()
        column2.id = "67612793b5f860ae8d6a4ae6"
        column2.type = .dropdown
        column2.title = "Dropdown Column"
        column2.width = 0
        column2.identifier = "field_column_6629fbc7e2493a155a32c509"
        column2.required = isColumnRequired
        
        var column3 = FieldTableColumn()
        column3.id = "67612793c76286eb2763c366"
        column3.type = .date
        column3.title = "Date Column"
        column3.width = 0
        column3.identifier = ""
        column3.value = .double(1712385780000)
//        column3.required = isColumnRequired
        
        if !isColumnsZero {
            field.tableColumns = [column1,column2,column3]
        }
        
        field.tableColumnOrder = [
            "676127938fb7c5fd4321a2f4",
            "67612793b5f860ae8d6a4ae6",
            "67612793c76286eb2763c366"
        ]
        
        var valueElements1 = ValueElement()
        valueElements1.id = "676127938056dcd158942bad"
        valueElements1.deleted = false
        let cells1: [String: ValueUnion] = [
            "676127938fb7c5fd4321a2f4": ValueUnion.string("Value for Row 1, Column 1"),
            "67612793b5f860ae8d6a4ae6": ValueUnion.string("67612793a4c7301ba4da1d69"),
            "67612793c76286eb2763c366": ValueUnion.double(1712385780000)
        ]
        
        let cellsOnHideColumn: [String: ValueUnion] = [
            "67612793b5f860ae8d6a4ae6": ValueUnion.string("67612793a4c7301ba4da1d69"),
            "67612793c76286eb2763c366": ValueUnion.double(1712385780000)
        ]
        valueElements1.cells = hideColumn ? cellsOnHideColumn : cells1

        var valueElements2 = ValueElement()
        valueElements2.id = "67612793f70928da78973744"
        valueElements2.deleted = false
        let cells2: [String: ValueUnion] = [
            "676127938fb7c5fd4321a2f4": ValueUnion.string("Value for Row 2, Column 2"),
            "67612793b5f860ae8d6a4ae6": ValueUnion.string("67612793a4c7301ba4da1d69"),
            "67612793c76286eb2763c366": ValueUnion.double(1712385780000)
        ]
        valueElements2.cells = areCellsEmpty ? [:] : cells2

        var valueElements3 = ValueElement()
        valueElements3.id = "67612793a6cd1f9d39c8433b"
        valueElements3.deleted = false
        let cells3: [String: ValueUnion] = [
            "676127938fb7c5fd4321a2f4": ValueUnion.string("Value for Row 2, Column 2"),
            "67612793b5f860ae8d6a4ae6": ValueUnion.string("67612793a4c7301ba4da1d69"),
            "67612793c76286eb2763c366": ValueUnion.double(1712385780000)
        ]
        valueElements3.cells = cells3
        
        // Delete true a row
        var valueElements4 = ValueElement()
        valueElements4.id = "67612793a6cd1f9d39c8433c"
        valueElements4.deleted = true
        let cells4: [String: ValueUnion] = [
            "676127938fb7c5fd4321a2f4": ValueUnion.string("Value for Row 2, Column 2"),
            "67612793b5f860ae8d6a4ae6": ValueUnion.string("67612793a4c7301ba4da1d69"),
            "67612793c76286eb2763c366": ValueUnion.double(1712385780000)
        ]
        valueElements4.cells = cells4
        
        // Nil cells for a row
        var valueElements5 = ValueElement()
        valueElements5.id = "67612793a6cd1f9d39c8433d"
        valueElements5.deleted = false
        
        //For case zero rows

        let value = ValueUnion.valueElementArray([valueElements1, valueElements2, valueElements3, valueElements4, valueElements5])
        if !isZeroRows {
            field.value = value
        }
        
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setTableFieldPosition(hideColumn: Bool) -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "67612793c4e6a5e6a05e64a3"
        fieldPosition.displayType = "original"
        fieldPosition.width = 24
        fieldPosition.height = 24
        fieldPosition.x = 0
        fieldPosition.y = 0
        fieldPosition.id = "6629fbc736d179b9014abae0"
        fieldPosition.type = .table
        fieldPosition.titleDisplay = "none"
        
        var tableColumn1 = TableColumn()
        tableColumn1.id = "676127938fb7c5fd4321a2f4"
        tableColumn1.format = .empty
        tableColumn1.hidden = hideColumn
        
        var tableColumn2 = TableColumn()
        tableColumn2.id = "67612793b5f860ae8d6a4ae6"
        tableColumn2.format = .empty
        tableColumn2.hidden = hideColumn
        
        var tableColumn3 = TableColumn()
        tableColumn3.id = "67612793c76286eb2763c366"
        tableColumn3.format = .empty
//        tableColumn3.hidden = hideColumn
        
        fieldPosition.tableColumns = [tableColumn1, tableColumn2, tableColumn3]
        var document = self
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    func setRequiredTextFieldInMobile() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "66aa2865da10ac1c7b7acb1d"
        fieldPosition.displayType = "original"
        fieldPosition.width = 4
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 0
        fieldPosition.primaryDisplayOnly = true
        fieldPosition.id = "66aa2520173f61daed286798"
        fieldPosition.type = .text
        var document = self
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    // Field is show when condition is true
    // Status - invalid ( Field without value )
    func setRequiredShowNumberFieldByLogicWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        field.type = "number"
        field.id = "66aa28f805a4900ae643db9c"
        field.identifier = "field_66aa2913e525be6fc66e0bcb"
        field.title = "Number"
        field.description = ""
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.hidden = true
        field.file = "66a0fdb2acd89d30121053b9"
        // Create the dictionary for the logic
        let logicDictionary: [String: Any] = [
            "action": "show",
            "eval": "and",
            "conditions": [
                [
                    "file": "66a0fdb2acd89d30121053b9",
                    "page": "66aa286569ad25c65517385e",
                    "field": "66aa2865da10ac1c7b7acb1d",
                    "condition": "=",
                    "value": "Hello",
                    "_id": "66aa2a7c4bbc669133bad221"
                ]
            ],
            "_id": "66aa2a7c4bbc669133bad220"
        ]
    // Initialize Logic with the dictionary
        if let logic = Logic(field: logicDictionary) {
            field.logic = logic
        }
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setRequiredShowNumberFieldByLogicWithoutValuePositionInMobile() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "66aa28f805a4900ae643db9c"
        fieldPosition.displayType = "original"
        fieldPosition.width = 4
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 8
        fieldPosition.id = "66aa29136c6f17d56a2d9f67"
        fieldPosition.type = .number
        var document = self
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    // Status - valid ( Field with value )
    func setRequiredShowNumberFieldByLogicWithValue() -> JoyDoc {
        var field = JoyDocField()
        
        field.type = "number"
        field.id = "66aa28f805a4900ae643db9c"
        field.identifier = "field_66aa2913e525be6fc66e0bcb"
        field.title = "Number"
        field.description = ""
        field.value = .double(123)
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.hidden = true
        field.file = "66a0fdb2acd89d30121053b9"
        // Create the dictionary for the logic
        let logicDictionary: [String: Any] = [
            "action": "show",
            "eval": "and",
            "conditions": [
                [
                    "file": "66a0fdb2acd89d30121053b9",
                    "page": "66aa286569ad25c65517385e",
                    "field": "66aa2865da10ac1c7b7acb1d",
                    "condition": "=",
                    "value": "Hello",
                    "_id": "66aa2a7c4bbc669133bad221"
                ]
            ],
            "_id": "66aa2a7c4bbc669133bad220"
        ]
        
        // Initialize Logic with the dictionary
        if let logic = Logic(field: logicDictionary) {
            field.logic = logic
        }
        
        var document = self
        document.fields.append(field)
        return document
    }

    // Field is hide when condition is true
    // Status - invalid ( Field without value )
    func setRequiredHideNumberFieldByLogicWithoutValue() -> JoyDoc {
        var field = JoyDocField()
        
        field.type = "number"
        field.id = "66aa28f805a4900ae643db9c"
        field.identifier = "field_66aa2913e525be6fc66e0bcb"
        field.title = "Number"
        field.description = ""
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.hidden = false
        field.file = "66a0fdb2acd89d30121053b9"
        
        // Create the dictionary for the logic
        let logicDictionary: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "file": "66a0fdb2acd89d30121053b9",
                    "page": "66aa286569ad25c65517385e",
                    "field": "66aa2865da10ac1c7b7acb1d",
                    "condition": "=",
                    "value": "Hello",
                    "_id": "66aa2a7c4bbc669133bad221"
                ]
            ],
            "_id": "66aa2a7c4bbc669133bad220"
        ]
        
        // Initialize Logic with the dictionary
        if let logic = Logic(field: logicDictionary) {
            field.logic = logic
        }
        
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setRequiredHideNumberFieldByLogicWithoutValuePositionInMobile() -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = "66aa28f805a4900ae643db9c"
        fieldPosition.displayType = "original"
        fieldPosition.width = 4
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 8
        fieldPosition.id = "66aa29136c6f17d56a2d9f67"
        fieldPosition.type = .number
        var document = self
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    // Status - valid ( Field with value )
    func setRequiredHideNumberFieldByLogicWithValue() -> JoyDoc {
        var field = JoyDocField()
        
        field.type = "number"
        field.id = "66aa28f805a4900ae643db9c"
        field.identifier = "field_66aa2913e525be6fc66e0bcb"
        field.title = "Number"
        field.description = ""
        field.value = .double(12345)
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.hidden = false
        field.file = "66a0fdb2acd89d30121053b9"
        
        // Create the dictionary for the logic
        let logicDictionary: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "file": "66a0fdb2acd89d30121053b9",
                    "page": "66aa286569ad25c65517385e",
                    "field": "66aa2865da10ac1c7b7acb1d",
                    "condition": "=",
                    "value": "Hello",
                    "_id": "66aa2a7c4bbc669133bad221"
                ]
            ],
            "_id": "66aa2a7c4bbc669133bad220"
        ]
        
        // Initialize Logic with the dictionary
        if let logic = Logic(field: logicDictionary) {
            field.logic = logic
        }
        
        var document = self
        document.fields.append(field)
        return document
    }
    
// Conditional logic methods
    
    func setConditionalLogicToField(fieldID: String, logic: Logic?) -> JoyDoc {
        var document = self
        if let index = document.fields.firstIndex(where: { $0.id == fieldID }) {
            document.fields[index].logic = logic
        }
        return document
    }
    
    func setConditionalLogic(pageID: String, logic: Logic?) -> JoyDoc {
        var updatedDocument = self
        if let pageIndex = updatedDocument.files[0].views?[0].pages?.firstIndex(where: { $0.id == pageID }) {
            updatedDocument.files[0].views?[0].pages?[pageIndex].logic = logic
        }
        return updatedDocument
    }
    
    func setNumberField(hidden: Bool, value: ValueUnion) -> JoyDoc {
        var field = JoyDocField()
        field.type = "number"
        field.id = "6629fb3df03de10b26270ab3"
        field.identifier = "field_6629fb3fabb87e37c9578b8b"
        field.title = "Number"
        field.description = ""
        field.value = value
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        field.hidden = hidden
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setTextField(hidden: Bool, value: ValueUnion, required: Bool = false) -> JoyDoc {
        var field = JoyDocField()
        field.type = "text"
        field.id = "66aa2865da10ac1c7b7acb1d"
        field.identifier = "field_66aa2520d3285f2fcf8e53b3"
        field.title = "Text"
        field.description = ""
        field.value = value
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "66a0fdb2acd89d30121053b9"
        field.hidden = hidden
        field.required = required
        var document = self
        document.fields.append(field)
        return document
    }
    
    //Set Dropdown Field
    func setDropdownField(hidden: Bool, value: ValueUnion) -> JoyDoc {
        var field = JoyDocField()
        field.type = "dropdown"
        field.id = "6781040987a55e48b4507a38"
        field.identifier = "field_678104b10279a22deca9beb6"
        field.title = "Dropdown"
        field.description = ""
        
        var option1 = Option()
        option1.id = "677e2bfab0d5dce4162c36c1"
        option1.value = "Yes"
        option1.deleted = false
        var option2 = Option()
        option2.id = "677e2bfaf81647d2f6a016a0"
        option2.value = "No"
        option2.deleted = false
        var option3 = Option()
        option3.id = "677e2bfa0f4ed64ef5055bcf"
        option3.value = "N/A"
        option3.deleted = false
        
        field.options = [option1, option2, option3]
        field.value = value
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "66a0fdb2acd89d30121053b9"
        field.hidden = hidden
        var document = self
        document.fields.append(field)
        return document
    }
    
    //Set MultiSelect Field
    func setMultiSelectField(hidden: Bool, value: ValueUnion, multi: Bool) -> JoyDoc {
        var field = JoyDocField()
        field.type = "multiSelect"
        field.id = "678104b387d3004e70120ac6"
        field.identifier = "field_6781058d099fc0a3107973fb"
        field.title = "Multiple Choice"
        field.description = ""
        
        var option1 = Option()
        option1.id = "677e2bfa1ff43cf15d159310"
        option1.value = "Yes"
        option1.deleted = false
        var option2 = Option()
        option2.id = "677e2bfa9c5249a2acd3644f"
        option2.value = "No"
        option2.deleted = false
        var option3 = Option()
        option3.id = "677e2bfa152e9f549edf0813"
        option3.value = "N/A"
        option3.deleted = false
        
        field.options = [option1, option2, option3]
        field.value = value
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "66a0fdb2acd89d30121053b9"
        field.hidden = hidden
        field.multi = multi
        var document = self
        document.fields.append(field)
        return document
    }
    
    //Set multiline field
    func setMultilineTextField(hidden: Bool, value: ValueUnion, required: Bool = false) -> JoyDoc {
        var field = JoyDocField()
        field.type = "textarea"
        field.id = "6629fb2b9a487ce1c1f35f6c"
        field.identifier = "field_6629fb2feff29e90331e4e8e"
        field.title = "Multiline Text"
        field.hidden = hidden
        field.description = ""
        field.value = value
        field.required = required
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setTwoPageField(page1hidden: Bool, page2hidden: Bool) -> JoyDoc {
        var page1 = Page()
        page1.name = "Page 1"
        page1.hidden = false
        page1.width = 816
        page1.height = 1056
        page1.cols = 24
        page1.rowHeight = 8
        page1.layout = "grid"
        page1.presentation = "normal"
        page1.margin = 0
        page1.padding = 0
        page1.borderWidth = 0
        page1.hidden = page1hidden
        page1.backgroundImage = "https://s3.amazonaws.com/docspace.production.documents/5cca363a20d5f31fe3d7d6a2/pdfTemplates/614892aeb47c0f58db8ebd0a/page1631330091520-2f189ce0-1631330091522.png"
        page1.id = "6629fab320fca7c8107a6cf6"
        
        var page2 = Page()
        page2.name = "Page 2"
        page2.hidden = false
        page2.width = 816
        page2.height = 1056
        page2.cols = 24
        page2.rowHeight = 8
        page2.layout = "grid"
        page2.presentation = "normal"
        page2.margin = 0
        page2.padding = 0
        page2.borderWidth = 0
        page2.hidden = page2hidden
        page2.backgroundImage = "https://s3.amazonaws.com/docspace.production.documents/5cca363a20d5f31fe3d7d6a2/pdfTemplates/614892aeb47c0f58db8ebd0a/page1631330091520-2f189ce0-1631330091522.png"
        page2.id = "66600801dc1d8b4f72f54917"
        
        
        var document = self
        if var pages = document.files[0].views?[0].pages {
            pages.append(page1)
            pages.append(page2)
            document.files[0].views?[0].pages = pages
        } else {
            document.files[0].pages = [page1, page2]
        }
        return document
    }
    
    func setFieldPositionToPage(pageId: String, idAndTypes: [String : FieldTypes]) -> JoyDoc {
        
        var document = self
        
        var fieldsPositions = [FieldPosition]()
        for idAndType in idAndTypes {
            var fieldPosition = FieldPosition()
            fieldPosition.field = idAndType.key
            fieldPosition.id = UUID().uuidString
            fieldPosition.type = idAndType.value
            fieldsPositions.append(fieldPosition)
        }
                
        if var pages = document.files[0].views?[0].pages {
            let pageIndex = pages.firstIndex { page in
                page.id == pageId
            }
            pages[pageIndex ?? 0].fieldPositions = fieldsPositions
            
            document.files[0].views?[0].pages = pages
        }
        
        return document
    }
    
    func setConditionalLogicInCollectionField(schemaKey: String, logic: Logic?) -> JoyDoc {
        var document = self
        if let collectionFieldIndex = document.fields.firstIndex(where: { $0.type == "collection" }) {
            if var schemaDict = document.fields[collectionFieldIndex].schema {
                if var targetSchema = schemaDict[schemaKey] {
                    var dict = targetSchema.dictionary
                    dict["logic"] = logic?.dictionary
                    targetSchema = Schema(dictionary: dict)
                    schemaDict[schemaKey] = targetSchema
                }
                document.fields[collectionFieldIndex].schema = schemaDict
            }
        }
        return document
    }
    
    func setCollectionFieldRequired() -> JoyDoc {
        var field = JoyDocField()
        field.type = "collection"
        field.id = "67ddc52d35de157f6d7ebb63" // Reference id
        field.identifier = "field_67ddc530213a11e84876b001" // Reference identifier
        field.title = "Collection"
        field.description = ""
        
        // Build the collection rows using our model initializers.
        let collectionValue: [ValueElement] = [
            // First row
            ValueElement(dictionary: [
                "_id": "67ddc5327e6841a074d9240b",
                "cells": [
                    "67ddc5adbb96a9b9f9ff1480": "Grok ",
                    "67ddc2ndblock9f9ff1480": "hi yfgbfr",
                    "67ddc4db157f14f67da0616a": "joyfill",
                    "67ddc59c4aba2df34a6dd1c4": ValueUnion.double(300)
                ],
                "children": [String: Any]()
            ]),
            // Second row with nested children
            ValueElement(dictionary: [
                "_id": "67ddc537b7c2fce05d0c8615",
                "cells": [
                    "67ddc5adbb96a9b9f9ff1480": "First",
                    "67ddc4db157f14f67da0616a": "joyfill"
                ],
                "children": [
                    "67ddc5c9910a394a1324bfbe": [
                        "value": [
                            ValueElement(dictionary: [
                                "_id": "67ddd18bc3a74e6b350987f9",
                                "cells": [
                                    "67ddc61edce16f8b9f8dbf4b": "Grok "
                                ],
                                "children": [String: Any]()
                            ]),
                            ValueElement(dictionary: [
                                "_id": "67ddd191ab6a428ea69c77ad",
                                "cells": [
                                    "67ddc61edce16f8b9f8dbf4b": "First "
                                ],
                                "children": [
                                    "67ddc5f5c2477e8457956fb4": [
                                        "value": [
                                            ValueElement(dictionary: [
                                                "_id": "67ddd1a5e6d0d62d55a7aaad",
                                                "cells": [String: Any](),
                                                "children": [String: Any]()
                                            ]),
                                            ValueElement(dictionary: [
                                                "_id": "67ddd1a656a259a9b6ab1263",
                                                "cells": [String: Any](),
                                                "children": [String: Any]()
                                            ]),
                                            ValueElement(dictionary: [
                                                "_id": "67ddd1a779642224075bf23c",
                                                "cells": [String: Any](),
                                                "children": [String: Any]()
                                            ])
                                        ]
                                    ]
                                ]
                            ]),
                            ValueElement(dictionary: [
                                "_id": "67ddd193eae737b64c24851a",
                                "cells": [String: Any](),
                                "children": [String: Any]()
                            ])
                        ]
                    ],
                    "67ddcf4f622984fb4518cbc2": [
                        "value": [
                            ValueElement(dictionary: [
                                "_id": "67ddd1994c086e45784edb76",
                                "cells": [String: Any](),
                                "children": [String: Any]()
                            ]),
                            ValueElement(dictionary: [
                                "_id": "67ddd19f8577eb22eee2c57d",
                                "cells": [String: Any](),
                                "children": [String: Any]()
                            ]),
                            ValueElement(dictionary: [
                                "_id": "67ddd1a03789211ac5f657e3",
                                "cells": [String: Any](),
                                "children": [String: Any]()
                            ])
                        ]
                    ]
                ]
            ]),
            // Third row
            ValueElement(dictionary: [
                "_id": "67ddc538123468491bc1d6ac",
                "cells": [
                    "67ddc5adbb96a9b9f9ff1480": "First "
                ],
                "children": [String: Any]()
            ]),
            // Fourth row
            ValueElement(dictionary: [
                "_id": "67ddc53924f0bd68beb066ca",
                "cells": [
                    "67ddc4db157f14f67da0616a": "joyfill"
                ],
                "children": [String: Any]()
            ])
        ]
        
        // Assign the collection value using the model representation.
        field.value = .valueElementArray(collectionValue)
        
        let collectionSchema: [String: Any] = [
            "collectionSchemaId": [
                "title": "Main Collection",
                "root": true,
                "children": [
                    "67ddc5c9910a394a1324bfbe",
                    "67ddcf4f622984fb4518cbc2"
                ],
                "tableColumns": [
                    [
                        "_id": "67ddc4db157f14f67da0616a",
                        "type": "text",
                        "title": "Text Column",
                        "identifier": "field_column_67ddc4e0457002b72007e321",
                        "value": "Text Column: Grok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from X",
                        "required": true
                    ],
                    [
                        "_id": "67ddc4db898e2fb0ad3a8d19",
                        "type": "dropdown",
                        "title": "Dropdown Column",
                        "options": [
                            [
                                "_id": "67ddc4dbde8b8bfe6322da24",
                                "value": "Yes",
                                "deleted": false
                            ],
                            [
                                "_id": "67ddc4db94dba485b1642a23",
                                "value": "No",
                                "deleted": false
                            ],
                            [
                                "_id": "67ddc4db3bc809de86ac85d0",
                                "value": "N/A",
                                "deleted": false
                            ]
                        ],
                        "identifier": "field_column_67ddc4e093c80641691e8afe",
                        "value": "Grok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from X"
                    ],
                    [
                        "_id": "67ddc59c4aba2df34a6dd1c4",
                        "type": "number",
                        "title": "Number Column",
                        "deleted": false,
                        "width": 0
                    ],
                    [
                        "_id": "67ddc5981816e52ad55b71e6",
                        "type": "multiSelect",
                        "title": "Multiselect Column",
                        "deleted": false,
                        "width": 0,
                        "options": [
                            [
                                "_id": "67ddc59812e6c0eff62bab58",
                                "value": "Option 1",
                                "deleted": false
                            ],
                            [
                                "_id": "67ddc598fc5c30cacb3459ec",
                                "value": "Option 2",
                                "deleted": false
                                
                            ],
                            [
                                "_id": "67ddc598e4f75aaead71e431",
                                "value": "Option 3",
                                "deleted": false
                            ]
                        ],
                        "optionOrder": [
                            "67ddc59812e6c0eff62bab58",
                            "67ddc598fc5c30cacb3459ec",
                            "67ddc598e4f75aaead71e431"
                        ]
                    ]
                ]
            ],
            "67ddc5c9910a394a1324bfbe": [
                "title": "Child Table Title",
                "children": [
                    "67ddc5f5c2477e8457956fb4"
                ],
                "required": true,
                "tableColumns": [
                    [
                        "_id": "67ddc5c9cb21736a10919b22",
                        "type": "text",
                        "title": "Text Column",
                        "width": 0,
                        "deleted": false
                    ],
                    [
                        "_id": "67ddc609791020b851791f0d",
                        "type": "dropdown",
                        "title": "Dropdown Column",
                        "deleted": false,
                        "width": 0,
                        "options": [
                            [
                                "_id": "67ddc609599f3ba9fb2f7b2e",
                                "value": "Yes",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": NSNull()
                                ]
                            ],
                            [
                                "_id": "67ddc6091d62cd644f1ccdbb",
                                "value": "No",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": NSNull()
                                ]
                            ],
                            [
                                "_id": "67ddc609a9f8e1a573852153",
                                "value": "N/A",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": NSNull()
                                ]
                            ]
                        ],
                        "optionOrder": [
                            "67ddc609599f3ba9fb2f7b2e",
                            "67ddc6091d62cd644f1ccdbb",
                            "67ddc609a9f8e1a573852153"
                        ]
                    ],
                    [
                        "_id": "67ddc60c4f70b8ef5c7a5e3d",
                        "type": "multiSelect",
                        "title": "Multiselect Column",
                        "deleted": false,
                        "width": 0,
                        "options": [
                            [
                                "_id": "67ddc60c79c89a55825ffb0b",
                                "value": "Option 1",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": "#f0f0f0"
                                ]
                            ],
                            [
                                "_id": "67ddc60c27eb845be497ec8f",
                                "value": "Option 2",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": "#f0f0f0"
                                ]
                            ],
                            [
                                "_id": "67ddc60cbab030d3bf6f260e",
                                "value": "Option 3",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": "#f0f0f0"
                                ]
                            ]
                        ],
                        "optionOrder": [
                            "67ddc60c79c89a55825ffb0b",
                            "67ddc60c27eb845be497ec8f",
                            "67ddc60cbab030d3bf6f260e"
                        ]
                    ],
                    [
                        "_id": "67ddc60e1a015ed76fc404fc",
                        "type": "image",
                        "title": "Image Column",
                        "deleted": false,
                        "width": 0,
                        "maxImageWidth": 190,
                        "maxImageHeight": 120
                    ],
                    [
                        "_id": "67ddc6136fbc59b8d02d2723",
                        "type": "number",
                        "title": "Number Column",
                        "deleted": false,
                        "width": 0
                    ],
                    [
                        "_id": "67ddc618ef820f6b8cbc9879",
                        "type": "date",
                        "title": "Date Column",
                        "deleted": false,
                        "width": 0
                    ],
                    [
                        "_id": "67ddc61edce16f8b9f8dbf4b",
                        "type": "block",
                        "title": "Label Column",
                        "width": 0,
                        "deleted": false,
                        "value": "Grok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from XGrok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from X"
                    ],
                    [
                        "_id": "67ddc2ndblock9f9ff1480",
                        "type": "block",
                        "title": "Label Column2323",
                        "width": 0,
                        "deleted": false,
                        "value": "ourehwbfuvyberfhvbeurfbvouwofvyicjhgbvretlweuygficewnfr ru vheoriuhv eiuhv hv iurhtoeurhvduhgvh ev viuehdofuvgweorygh97645268673495234 52345 234 523453 4576 4568745678. 6786"
                    ],
                    [
                        "_id": "67ddc5b323b5b9fc08f3f824",
                        "type": "barcode",
                        "title": "Barcode Column",
                        "width": 0,
                        "deleted": false
                    ],
                    [
                        "_id": "67ddc5b5e2f8843d6d5f6771",
                        "type": "signature",
                        "title": "Signature Column",
                        "width": 0,
                        "deleted": false
                    ]
                ]
            ],
            "67ddc5f5c2477e8457956fb4": [
                "title": "Grand Child Table Title",
                "children": [],
                "tableColumns": [
                    [
                        "_id": "67ddc5f5107180be0f5befd6",
                        "type": "text",
                        "title": "Text Column",
                        "width": 0,
                        "deleted": false
                    ],
                    [
                        "_id": "67ddd16604dc88ca60898821",
                        "type": "dropdown",
                        "title": "Dropdown Column",
                        "deleted": false,
                        "width": 0,
                        "options": [
                            [
                                "_id": "67ddd1664a80f93bf1584051",
                                "value": "Yes",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": NSNull()
                                ]
                            ],
                            [
                                "_id": "67ddd1665198425a6554f362",
                                "value": "No",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": NSNull()
                                ]
                            ],
                            [
                                "_id": "67ddd1664e6d82d74191f5b9",
                                "value": "N/A",
                                "deleted": false,
                                "styles": [
                                    "backgroundColor": NSNull()
                                ]
                            ]
                        ],
                        "optionOrder": [
                            "67ddd1664a80f93bf1584051",
                            "67ddd1665198425a6554f362",
                            "67ddd1664e6d82d74191f5b9"
                        ]
                    ],
                    [
                        "_id": "67ddd16991439221b58a7148",
                        "type": "date",
                        "title": "Date 3rd Column",
                        "deleted": false,
                        "width": 0,
                        "maxImageWidth": 190,
                        "maxImageHeight": 120
                    ]
                ]
            ],
            "67ddcf4f622984fb4518cbc2": [
                "title": "2nd Child Table Title: Grok is xAI’s flagship large language model, envisioned as a witty, rebellious AI assistant with real-time knowledge from X.",
                "children": [],
                "tableColumns": [
                    [
                        "_id": "67ddcf4fa46f548aaade239d",
                        "type": "text",
                        "title": "Text Column",
                        "width": 0,
                        "deleted": false
                    ],
                    [
                        "_id": "67ddd17186d63f89705763d9",
                        "type": "barcode",
                        "title": "Barcode Column",
                        "width": 0,
                        "deleted": false
                    ],
                    [
                        "_id": "67ddd174efad8934d569ff8c",
                        "type": "signature",
                        "title": "Signature Column",
                        "width": 0,
                        "deleted": false
                    ]
                ]
            ]
        ]
        
        field.schema = collectionSchema.mapValues { Schema(dictionary: $0 as! [String: Any]) }
        
        field.required = true
        field.tipTitle = ""
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        
        var document = self
        document.fields.append(field)
        return document
    }
    
    func setCollectionFieldRequired(
        isFieldRequired: Bool = true,
        isSchemaRequired: Bool = true,
        includeNestedRows: Bool = true,
        omitRequiredValues: Bool = false
    ) -> JoyDoc {
        var field = JoyDocField()
        field.type = "collection"
        field.id = "67ddc52d35de157f6d7ebb63"
        field.identifier = "field_67ddc530213a11e84876b001"
        field.title = "Collection"
        field.required = isFieldRequired
        field.file = "6629fab3c0ba3fb775b4a55c"

        // Top-level row setup
        var topRow = ValueElement()
        topRow.id = "row_1"
        topRow.deleted = false
        topRow.cells = [
            "col_text_1": omitRequiredValues ? ValueUnion.string("") : ValueUnion.string("Top-level value")
        ]

        if includeNestedRows {
            let nestedChildRow = ValueElement(dictionary: [
                "_id": "nested_row_1",
                "cells": omitRequiredValues ? [:] : ["nested_col_1": "Nested value"],
                "children": [String: Any]()
            ])
            topRow.childrens = [
                "child_schema_1": Children(dictionary: ["value": [nestedChildRow]])
            ]
        }

        field.value = .valueElementArray([topRow])

        // Schema definition
        let schemaDict: [String: Any] = [
            "main_schema": [
                "title": "Root Schema",
                "root": true,
                "children": ["child_schema_1"],
                "tableColumns": [
                    [
                        "_id": "col_text_1",
                        "type": "text",
                        "title": "Text Column",
                        "required": true
                    ]
                ]
            ],
            "child_schema_1": [
                "title": "Child Schema",
                "required": true,
                "tableColumns": [
                    [
                        "_id": "nested_col_1",
                        "type": "text",
                        "title": "Nested Column",
                        "required": true
                    ]
                ]
            ]
        ]

        field.schema = schemaDict.mapValues { Schema(dictionary: $0 as! [String: Any]) }

        var document = self
        document.fields.append(field)
        return document
    }

    // set field position
    func setPageWithFieldPosition() -> JoyDoc {
        let position1 = FieldPosition(dictionary: [
            "field": "6629fad980958bff0608cd4a",
            "displayType": "original",
            "width": 4,
            "height": 8,
            "x": 1,
            "y": 0,
            "titleDisplay": "inline",
            "_id": "generatedID1",
            "type": "text"
        ])
        let position2 = FieldPosition(dictionary: [
            "field": "6629fb1d92a76d06750ca4a1",
            "displayType": "original",
            "width": 4,
            "height": 8,
            "x": 1,
            "y": 8,
            "_id": "generatedID2",
            "type": "text"
        ])
        
            var page = Page()
            page.name = "Page 1"
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
            page.fieldPositions = [position1, position2]
            var document = self
            if var pages = document.files[0].pages {
                pages.append(page)
                document.files[0].pages = pages
            } else {
                document.files[0].pages = [page]
            }
            return document
        }

}
