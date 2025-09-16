
public var joyfillSchema = """
  {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "_id": {
        "type": "string"
      },
      "type": {
        "type": "string"
      },
      "stage": {
        "type": "string"
      },
      "metadata": {
        "type": "object"
      },
      "identifier": {
        "type": "string"
      },
      "name": {
        "type": "string"
      },
      "createdOn": {
        "type": "number"
      },
      "files": {
        "type": "array",
        "items": {
          "$ref": "#/definitions/File"
        },
        "minItems": 1,
        "maxItems": 1
      },
      "fields": {
        "type": "array",
        "items": {
          "$ref": "#/definitions/Field"
        }
      },
      "deleted": {
        "type": "boolean"
      },
      "categories": {
        "type": "array",
        "items": {
          "type": "string"
        }
      },
      "formulas": {
        "type": "array",
        "items": {
          "$ref": "#/definitions/Formula"
        }
      }
    },
    "required": [
      "files",
      "fields"
    ],
    "definitions": {
      "File": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "metadata": {
            "type": "object"
          },
          "name": {
            "type": "string"
          },
          "styles": {
            "$ref": "#/definitions/CoreStyles"
          },
          "pages": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/Page"
            }
          },
          "pageOrder": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "views": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/View"
            }
          },
          "header": {
            "oneOf": [
              { "$ref": "#/definitions/HeaderFooter" },
              { "type": "null" }
            ]
          },
          "footer": {
            "oneOf": [
              { "$ref": "#/definitions/HeaderFooter" },
              { "type": "null" }
            ]
          }
        },
        "required": [
          "_id",
          "pages",
          "pageOrder"
        ]
      },
      "CoreStyles": {
        "type": "object",
        "properties": {
          "titleFontSize": {
            "type": "number"
          },
          "titleFontColor": {
            "type": "string"
          },
          "titleFontStyle": {
            "type": "string"
          },
          "titleFontWeight": {
            "type": "string"
          },
          "titleTextAlign": {
            "type": "string"
          },
          "titleTextTransform": {
            "type": "string"
          },
          "titleTextDecoration": {
            "type": "string"
          },
          "fontSize": {
            "type": "number"
          },
          "fontStyle": {
            "type": "string"
          },
          "fontWeight": {
            "type": "string"
          },
          "textAlign": {
            "type": "string"
          },
          "textTransform": {
            "type": "string"
          },
          "textDecoration": {
            "type": "string"
          },
          "textOverflow": {
            "type": "string"
          },
          "padding": {
            "type": "number"
          },
          "margin": {
            "type": "number"
          },
          "borderColor": {
            "type": "string"
          },
          "borderRadius": {
            "type": "number"
          },
          "borderWidth": {
            "type": "number"
          },
          "backgroundColor": {
            "type": "string"
          }
        }
      },
      "Page": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "name": {
            "type": "string"
          },
          "fieldPositions": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/FieldPosition"
            }
          },
          "metadata": {
            "type": "object"
          },
          "hidden": {
            "type": "boolean"
          },
          "width": {
            "type": "number"
          },
          "height": {
            "type": "number"
          },
          "cols": {
            "type": "number"
          },
          "rowHeight": {
            "type": "number"
          },
          "layout": {
            "type": "string"
          },
          "presentation": {
            "type": "string"
          },
          "margin": {
            "type": "number"
          },
          "padding": {
            "type": "number"
          },
          "borderWidth": {
            "type": "number"
          },
          "backgroundImage": {
            "type": "string"
          },
          "backgroundSize": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          }
        },
        "required": [
          "_id",
          "name",
          "fieldPositions",
          "width",
          "height",
          "cols",
          "rowHeight",
          "layout",
          "presentation"
        ]
      },
      "FieldPosition": {
        "type": "object",
        "properties": {
          "titleFontSize": {
            "type": "number"
          },
          "titleFontColor": {
            "type": "string"
          },
          "titleFontStyle": {
            "type": "string"
          },
          "titleFontWeight": {
            "type": "string"
          },
          "titleTextAlign": {
            "type": "string"
          },
          "titleTextTransform": {
            "type": "string"
          },
          "titleTextDecoration": {
            "type": "string"
          },
          "fontSize": {
            "type": "number"
          },
          "fontStyle": {
            "type": "string"
          },
          "fontWeight": {
            "type": "string"
          },
          "textAlign": {
            "type": "string"
          },
          "textTransform": {
            "type": "string"
          },
          "textDecoration": {
            "type": "string"
          },
          "textOverflow": {
            "type": "string"
          },
          "padding": {
            "type": "number"
          },
          "margin": {
            "type": "number"
          },
          "borderColor": {
            "type": "string"
          },
          "borderRadius": {
            "type": "number"
          },
          "borderWidth": {
            "type": "number"
          },
          "backgroundColor": {
            "type": "string"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "field": {
            "type": "string",
            "minLength": 1
          },
          "displayType": {
            "$ref": "#/definitions/FieldPositionDisplayType"
          },
          "width": {
            "type": "number"
          },
          "height": {
            "type": "number"
          },
          "x": {
            "type": "number"
          },
          "y": {
            "type": "number"
          },
          "type": {
            "$ref": "#/definitions/FieldType"
          },
          "schema": {
            "type": "object",
            "additionalProperties": {
              "type": "object",
              "properties": {
                "tableColumns": {
                  "type": "object",
                  "additionalProperties": {
                    "type": "object",
                    "properties": {
                      "format": {
                        "type": "string"
                      },
                      "hidden": {
                        "type": "boolean"
                      }
                    }
                  }
                }
              }
            }
          },
          "tableColumns": {
            "type": "object",
            "additionalProperties": {
              "type": "object",
              "properties": {
                "format": {
                  "type": "string"
                },
                "hidden": {
                  "type": "boolean"
                }
              }
            }
          },
          "primaryMaxWidth": {
            "type": "number"
          },
          "primaryMaxHeight": {
            "type": "number"
          },
          "format": {
            "type": "string"
          },
          "targetValue": {
            "type": "string"
          },
          "lineHeight": {
            "type": "number"
          },
          "zIndex": {
            "type": "number"
          },
          "columnTitleFontSize": {
            "type": "number"
          },
          "columnTitleFontColor": {
            "type": "string"
          },
          "columnTitleFontStyle": {
            "type": "string"
          },
          "columnTitleFontWeight": {
            "type": "string"
          },
          "columnTitleTextAlign": {
            "type": "string"
          },
          "columnTitleTextTransform": {
            "type": "string"
          },
          "columnTitleTextDecoration": {
            "type": "string"
          },
          "columnTitleBackgroundColor": {
            "type": "string"
          },
          "columnTitlePadding": {
            "type": "number"
          },
          "titleDisplay": {
            "type": "string"
          },
          "rowIndex": {
            "type": "number"
          },
          "column": {
            "type": "string"
          },
          "columnType": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "field",
          "displayType",
          "width",
          "height",
          "x",
          "y",
          "type"
        ]
      },
      "FieldPositionDisplayType": {
        "type": "string"
      },
      "FieldType": {
        "type": "string"
      },
      "Logic": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string"
          },
          "action": {
            "type": "string"
          },
          "eval": {
            "type": "string"
          },
          "conditions": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/Condition"
            }
          }
        },
        "required": [
          "action",
          "eval",
          "conditions"
        ]
      },
      "Condition": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string"
          },
          "file": {
            "type": "string"
          },
          "page": {
            "type": "string"
          },
          "field": {
            "type": "string"
          },
          "condition": {
            "type": "string"
          },
          "value": {}
        },
        "required": [
          "file",
          "page",
          "field",
          "condition"
        ]
      },
      "View": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "mobile"
          },
          "pageOrder": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "pages": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/Page"
            }
          }
        },
        "required": [
          "pageOrder",
          "pages"
        ]
      },
      "HeaderFooter": {
        "type": "object",
        "properties": {
          "fieldPositions": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/FieldPosition"
            }
          },
          "height": { "type": "number" },
          "cols": { "type": "number" },
          "rowHeight": { "type": "number" },
          "layout": { "type": "string" },
          "presentation": { "type": ["string", "null"] },
          "padding": { "type": ["number", "null"] }
        },
        "required": [
          "fieldPositions",
          "height",
          "cols",
          "rowHeight",
          "layout"
        ]
      },
      "Field": {
        "anyOf": [
          {
            "$ref": "#/definitions/ImageField"
          },
          {
            "$ref": "#/definitions/FileField"
          },
          {
            "$ref": "#/definitions/BlockField"
          },
          {
            "$ref": "#/definitions/LegacyRichTextField"
          },
          {
            "$ref": "#/definitions/TextField"
          },
          {
            "$ref": "#/definitions/NumberField"
          },
          {
            "$ref": "#/definitions/DateField"
          },
          {
            "$ref": "#/definitions/TextareaField"
          },
          {
            "$ref": "#/definitions/SignatureField"
          },
          {
            "$ref": "#/definitions/MultiSelectField"
          },
          {
            "$ref": "#/definitions/DropdownField"
          },
          {
            "$ref": "#/definitions/TableField"
          },
          {
            "$ref": "#/definitions/ChartField"
          },
          {
            "$ref": "#/definitions/CollectionField"
          },
          {
            "$ref": "#/definitions/CustomField"
          }
        ]
      },
      "ImageField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "image"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/ImageValue"
            }
          },
          "multi": {
            "type": "boolean"
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "ImageValue": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string"
          },
          "url": {
            "type": "string"
          },
          "fileName": {
            "type": "string"
          },
          "filePath": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "url"
        ],
        "additionalProperties": true
      },
      "FileField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "file"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/FileValue"
            }
          },
          "multi": {
            "type": "boolean"
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "FileValue": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string"
          },
          "url": {
            "type": "string"
          },
          "fileName": {
            "type": "string"
          },
          "filePath": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "url"
        ]
      },
      "BlockField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "block"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "LegacyRichTextField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "richText"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "TextField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "text"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "NumberField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "number"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "anyOf": [
              {
                "type": "number"
              },
              {
                "type": "string",
                "const": ""
              }
            ]
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "DateField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "date"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "anyOf": [
              {
                "type": "number"
              },
              {
                "type": "null"
              },
              {
                "type": "string",
                "const": ""
              }
            ]
          },
          "format": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "TextareaField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "textarea"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "SignatureField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "signature"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "string"
          },
          "signer": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "MultiSelectField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "multiSelect"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "options": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/Option"
            }
          },
          "multi": {
            "type": "boolean"
          }
        },
        "required": [
          "_id",
          "file",
          "options",
          "type"
        ]
      },
      "Option": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string"
          },
          "value": {
            "type": "string"
          },
          "deleted": {
            "type": "boolean"
          },
          "width": {
            "type": "number"
          },
          "styles": {
            "type": "object",
            "properties": {
              "backgroundColor": {
                "type": [
                  "string",
                  "null"
                ]
              }
            }
          },
          "metadata": {
            "type": "object"
          }
        },
        "required": [
          "_id",
          "value"
        ]
      },
      "DropdownField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "dropdown"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "options": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/Option"
            }
          },
          "value": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "file",
          "options",
          "type"
        ]
      },
      "TableField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "table"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/TableRow"
            }
          },
          "rowOrder": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "tableColumns": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/TableColumn"
            }
          },
          "tableColumnOrder": {
            "type": "array",
            "items": {
              "type": "string"
            }
          }
        },
        "required": [
          "_id",
          "file",
          "rowOrder",
          "tableColumnOrder",
          "tableColumns",
          "type",
          "value"
        ]
      },
      "TableRow": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "deleted": {
            "type": "boolean"
          },
          "cells": {
            "type": "object"
          }
        },
        "required": [
          "_id"
        ]
      },
      "TableColumn": {
        "anyOf": [
          {
            "$ref": "#/definitions/TextColumn"
          },
          {
            "$ref": "#/definitions/DropdownColumn"
          },
          {
            "$ref": "#/definitions/MultiSelectColumn"
          },
          {
            "$ref": "#/definitions/ImageColumn"
          },
          {
            "$ref": "#/definitions/NumberColumn"
          },
          {
            "$ref": "#/definitions/DateColumn"
          },
          {
            "$ref": "#/definitions/BlockColumn"
          },
          {
            "$ref": "#/definitions/BarcodeColumn"
          },
          {
            "$ref": "#/definitions/SignatureColumn"
          },
          {
            "$ref": "#/definitions/CustomColumn"
          }
        ]
      },
      "TextColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "text"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "DropdownColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "dropdown"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {
            "type": "string"
          },
          "options": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/Option"
            }
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "MultiSelectColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "multiSelect"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "options": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/Option"
            }
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "ImageColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "image"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {},
          "maxImageWidth": {
            "type": "number"
          },
          "maxImageHeight": {
            "type": "number"
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "NumberColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "number"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {
            "type": "number"
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "DateColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "date"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {
            "type": "number"
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "BlockColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "block"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "BarcodeColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "barcode"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "SignatureColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "const": "signature"
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {},
          "maxImageWidth": {
            "type": "number"
          },
          "maxImageHeight": {
            "type": "number"
          }
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "CustomColumn": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "type": {
            "type": "string",
            "not": {
              "enum": [
                "image",
                "text",
                "number",
                "dropdown",
                "multiSelect",
                "date",
                "signature",
                "barcode",
                "block"
              ]
            }
          },
          "title": {
            "type": "string"
          },
          "width": {
            "type": "number"
          },
          "deleted": {
            "type": "boolean"
          },
          "identifier": {
            "type": "string"
          },
          "value": {}
        },
        "required": [
          "_id",
          "type"
        ]
      },
      "ChartField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "chart"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "value": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/ChartSeries"
            }
          },
          "yTitle": {
            "type": "string"
          },
          "yMax": {
            "type": "number"
          },
          "yMin": {
            "type": "number"
          },
          "xTitle": {
            "type": "string"
          },
          "xMax": {
            "type": "number"
          },
          "xMin": {
            "type": "number"
          }
        },
        "required": [
          "_id",
          "file",
          "type",
          "xMax",
          "xMin",
          "xTitle",
          "yMax",
          "yMin",
          "yTitle"
        ]
      },
      "ChartSeries": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "deleted": {
            "type": "boolean"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "points": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/ChartPoint"
            }
          }
        },
        "required": [
          "_id",
          "points"
        ]
      },
      "ChartPoint": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "label": {
            "type": "string"
          },
          "y": {
            "type": "number"
          },
          "x": {
            "type": "number"
          }
        },
        "required": [
          "_id",
          "y",
          "x"
        ]
      },
      "CollectionField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "const": "collection"
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          },
          "schema": {
            "$ref": "#/definitions/Schema"
          },
          "value": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/CollectionItem"
            }
          }
        },
        "required": [
          "_id",
          "file",
          "schema",
          "type",
          "value"
        ]
      },
      "Schema": {
        "type": "object",
        "additionalProperties": {
          "$ref": "#/definitions/SchemaDefinition"
        }
      },
      "SchemaDefinition": {
        "type": "object",
        "properties": {
          "root": {
            "type": "boolean"
          },
          "title": {
            "type": "string"
          },
          "identifier": {
            "type": "string"
          },
          "tableColumns": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/TableColumn"
            }
          },
          "logic": {
            "$ref": "#/definitions/SchemaLogic"
          },
          "children": {
            "type": "array",
            "items": {
              "type": "string"
            }
          }
        },
        "required": [
          "tableColumns"
        ]
      },
      "SchemaLogic": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string"
          },
          "action": {
            "type": "string"
          },
          "eval": {
            "type": "string"
          },
          "conditions": {
            "type": "array",
            "items": {
              "$ref": "#/definitions/SchemaLogicCondition"
            }
          }
        },
        "required": [
          "action",
          "eval",
          "conditions"
        ]
      },
      "SchemaLogicCondition": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string"
          },
          "schema": {
            "type": "string"
          },
          "column": {
            "type": "string"
          },
          "condition": {
            "type": "string"
          },
          "value": {}
        },
        "required": [
          "schema",
          "column",
          "condition"
        ]
      },
      "CollectionItem": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "cells": {
            "type": "object"
          },
          "children": {
            "type": "object",
            "additionalProperties": {
              "type": "object",
              "properties": {
                "value": {
                  "type": "array",
                  "items": {
                    "$ref": "#/definitions/CollectionItem"
                  }
                }
              }
            }
          }
        },
        "required": [
          "_id"
        ]
      },
      "CustomField": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "not": {
              "enum": [
                "image",
                "richText",
                "file",
                "text",
                "textarea",
                "number",
                "dropdown",
                "multiSelect",
                "date",
                "signature",
                "table",
                "chart",
                "collection",
                "block"
              ]
            }
          },
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "identifier": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "required": {
            "type": "boolean"
          },
          "tipTitle": {
            "type": "string"
          },
          "tipDescription": {
            "type": "string"
          },
          "tipVisible": {
            "type": "boolean"
          },
          "metadata": {
            "type": "object"
          },
          "file": {
            "type": "string"
          },
          "logic": {
            "$ref": "#/definitions/Logic"
          },
          "hidden": {
            "type": "boolean"
          },
          "disabled": {
            "type": "boolean"
          },
          "formulas": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "_id": {
                  "type": "string"
                },
                "key": {
                  "type": "string"
                },
                "formula": {
                  "type": "string"
                }
              },
              "required": [
                "_id",
                "key",
                "formula"
              ]
            }
          }
        },
        "required": [
          "_id",
          "file",
          "type"
        ]
      },
      "Formula": {
        "type": "object",
        "properties": {
          "_id": {
            "type": "string",
            "minLength": 1
          },
          "desc": {
            "type": "string"
          },
          "type": {
            "type": "string"
          },
          "scope": {
            "type": "string"
          },
          "expression": {
            "type": "string"
          }
        },
        "required": [
          "_id",
          "desc",
          "type",
          "scope",
          "expression"
        ]
      }
    },
    "$joyfillSchemaVersion": "1.0.0"
  }

"""
private let defaultJoyfillSchema = joyfillSchema
public func getCurrentSchema() -> String {
    return joyfillSchema
}

public func setCustomSchema(_ customSchemaJson: String) {
    joyfillSchema = customSchemaJson
}

public func resetJoyfillSchemaToDefault() {
    joyfillSchema = defaultJoyfillSchema
}

