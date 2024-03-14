//
//  File.swift
//  
//
//  Created by Nand Kishore on 06/03/24.
//

import Foundation
import JoyfillModel

//TODO: Remove this
func fakeTableData() -> JoyDocField? {
    let data = response.data(using: .utf8)!
    do {
        return try? JSONDecoder().decode(JoyDocField.self, from: data)
    } catch {
        return nil
    }
}

let response = """
{
                    "type": "table",
                    "_id": "65c77d9a72b975711c99bd50",
                    "identifier": "field_65c77d9e631e9e53679fdda4",
                    "title": "Table",
                    "description": "",
                    "value": [
                        {
                            "_id": "65c7643b72de876e31fc30f7",
                            "deleted": false,
                            "cells": {
                                "65c7643b970dfa70f906eacf": "Hi, First Row",
                                "65c7643b7afdd89dda43bf28": "65c7643b8157b971f6c65174",
                                "65c7643bce0aff8c2346400d": "last column, first row In some situations, I would prefer if the text field could extend over several lines."
                            }
                        },
                        {
                            "_id": "65c7643b7bc07d67096dfeb3",
                            "deleted": false,
                            "cells": {
                                "65c7643b970dfa70f906eacf": "In some situations, I would prefer if the text field could extend over several lines.",
                                "65c7643b7afdd89dda43bf28": "65c7643b9c4d5149e7fe997a"
                            }
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacde",
                            "deleted": false,
                            "cells": {
                                "65c7643b970dfa70f906eacf": "Last Row, In some situations, I would prefer if the text field could extend over several lines. First column",
                                "65c7643bce0aff8c2346400d": "last, last, In some situations, I would prefer if the text field could extend over several lines."
                            }
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdf",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdg",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdh",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdi",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdj",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdk",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdl",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdm",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdn",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdo",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdp",
                            "deleted": false
                        },

                    ],
                    "required": false,
                    "tipTitle": "",
                    "tipDescription": "",
                    "tipVisible": false,
                    "metadata": {},
                    "rowOrder": [
                        "65c7643b72de876e31fc30f7",
                        "65c7643b7bc07d67096dfeb3",
                        "65c7643b0100c4d3899dacde",
                        "65c7643b0100c4d3899dacdf",
                        "65c7643b0100c4d3899dacdg",
                        "65c7643b0100c4d3899dacdh",
                        "65c7643b0100c4d3899dacdi",
                        "65c7643b0100c4d3899dacdj",
                        "65c7643b0100c4d3899dacdk",
                        "65c7643b0100c4d3899dacdl",
                        "65c7643b0100c4d3899dacdm",
                        "65c7643b0100c4d3899dacdn",
                        "65c7643b0100c4d3899dacdo",
                        "65c7643b0100c4d3899dacdp"
                    ],
                    "tableColumns": [
                        {
                            "_id": "65c7643b970dfa70f906eacf",
                            "type": "text",
                            "title": "Text Column",
                            "width": 0,
                            "identifier": "field_column_65c77d9ed79e7e7cc5ef0f3e"
                        },
                        {
                            "_id": "65c7643b7afdd89dda43bf28",
                            "type": "dropdown",
                            "title": "Dropdown Column",
                            "width": 0,
                            "identifier": "field_column_65c77d9e726506a0ed24eab8",
                            "options": [
                                {
                                    "_id": "65c7643b9c4d5149e7fe997a",
                                    "value": "Yes",
                                    "deleted": false
                                },
                                {
                                    "_id": "65c7643b83ed521e925907f8",
                                    "value": "No",
                                    "deleted": false
                                },
                                {
                                    "_id": "65c7643b8157b971f6c65174",
                                    "value": "N/A",
                                    "deleted": false
                                }
                            ]
                        },
                        {
                            "_id": "65c7643bce0aff8c2346400d",
                            "type": "text",
                            "title": "Text Column",
                            "width": 0,
                            "identifier": "field_column_65c77d9ec51d700b47d4f9f2"
                        },
                        {
                            "_id": "65c7643bce0aff8c2346400e",
                            "type": "image",
                            "title": "Text Column",
                            "width": 0,
                            "identifier": "field_column_65c77d9ec51d700b47d4f9f2"
                        }
                    ],
                    "tableColumnOrder": [
                        "65c7643b970dfa70f906eacf",
                        "65c7643b7afdd89dda43bf28",
                        "65c7643bce0aff8c2346400d",
                        "65c7643bce0aff8c2346400e"
                    ],
                    "file": "65c7637bcca019774a4ca5e2"
                }
"""




/////more rows:
//let response = """
//{
//                    "type": "table",
//                    "_id": "65c77d9a72b975711c99bd50",
//                    "identifier": "field_65c77d9e631e9e53679fdda4",
//                    "title": "Table",
//                    "description": "",
//                    "value": [
//                        {
//                            "_id": "65c7643b72de876e31fc30f7",
//                            "deleted": false,
//                            "cells": {
//                                "65c7643b970dfa70f906eacf": "Hi, First Row",
//                                "65c7643b7afdd89dda43bf28": "65c7643b8157b971f6c65174",
//                                "65c7643bce0aff8c2346400d": "last column, first row"
//                            }
//                        },
//                        {
//                            "_id": "65c7643b7bc07d67096dfeb3",
//                            "deleted": false,
//                            "cells": {
//                                "65c7643b970dfa70f906eacf": "",
//                                "65c7643b7afdd89dda43bf28": "65c7643b9c4d5149e7fe997a"
//                            }
//                        },
//                        {
//                            "_id": "65c7643b0100c4d3899dacde",
//                            "deleted": false,
//                            "cells": {
//                                "65c7643b970dfa70f906eacf": "Last Row, First column",
//                                "65c7643bce0aff8c2346400d": "last, last"
//                            }
//                        }
//                    ],
//                    "required": false,
//                    "tipTitle": "",
//                    "tipDescription": "",
//                    "tipVisible": false,
//                    "metadata": {},
//                    "rowOrder": [
//                        "65c7643b72de876e31fc30f7",
//                        "65c7643b7bc07d67096dfeb3",
//                        "65c7643b0100c4d3899dacde"
//                    ],
//                    "tableColumns": [
//                        {
//                            "_id": "65c7643b970dfa70f906eacf",
//                            "type": "text",
//                            "title": "Text Column",
//                            "width": 0,
//                            "identifier": "field_column_65c77d9ed79e7e7cc5ef0f3e"
//                        },
//                        {
//                            "_id": "65c7643b7afdd89dda43bf28",
//                            "type": "dropdown",
//                            "title": "Dropdown Column",
//                            "width": 0,
//                            "identifier": "field_column_65c77d9e726506a0ed24eab8",
//                            "options": [
//                                {
//                                    "_id": "65c7643b9c4d5149e7fe997a",
//                                    "value": "Yes",
//                                    "deleted": false
//                                },
//                                {
//                                    "_id": "65c7643b83ed521e925907f8",
//                                    "value": "No",
//                                    "deleted": false
//                                },
//                                {
//                                    "_id": "65c7643b8157b971f6c65174",
//                                    "value": "N/A",
//                                    "deleted": false
//                                }
//                            ]
//                        },
//                        {
//                            "_id": "65c7643bce0aff8c2346400d",
//                            "type": "text",
//                            "title": "Text Column",
//                            "width": 0,
//                            "identifier": "field_column_65c77d9ec51d700b47d4f9f2"
//                        },
//                        {
//                            "_id": "65c7643bce0aff8c2346400e",
//                            "type": "image",
//                            "title": "Text Column",
//                            "width": 0,
//                            "identifier": "field_column_65c77d9ec51d700b47d4f9f2"
//                        }
//                    ],
//                    "tableColumnOrder": [
//                        "65c7643b970dfa70f906eacf",
//                        "65c7643b7afdd89dda43bf28",
//                        "65c7643bce0aff8c2346400d",
//                        "65c7643bce0aff8c2346400e"
//                    ],
//                    "file": "65c7637bcca019774a4ca5e2"
//                }
//"""
//
