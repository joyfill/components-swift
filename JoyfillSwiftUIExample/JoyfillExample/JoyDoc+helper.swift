//
//  JoyDoc+helper.swift
//  JoyfillExample
//
//  Created by Vishnu Dutt on 22/04/25.
//
import JoyfillModel
import Foundation


extension JoyDoc {

    static func addDocument() -> JoyDoc {
        return JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
    }
    
    // MARK: - Generic Field Creation
    
    /// Adds a field of specified type to the document
    func addField(type: FieldTypes, 
                  identifier: String = "field_6629fb3fabb87e37c9578b8b", 
                  formula: String? = nil,
                  id: String = UUID().uuidString, 
                  value: ValueUnion) -> JoyDoc {
        return self
            .setFieldData(type: type, identifier: identifier, formula: formula, id: id, value: value)
            .setFieldPosition(type: type, id: id)
    }
    
    /// Sets field data for any field type
    func setFieldData(type: FieldTypes,
                     identifier: String = "field_6629fb3fabb87e37c9578b8b", 
                     formula: String? = nil,
                     id: String = UUID().uuidString,
                     value: ValueUnion) -> JoyDoc {
        var field = JoyDocField()
        field.type = type.rawValue
        field.id = id
        field.identifier = identifier
        field.title = identifier
        field.description = ""
        field.value = value
        field.required = false
        field.tipTitle = ""
        field.formula = formula
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        
        var document = self
        document.fields.append(field)
        return document
    }
    
    /// Sets field position for any field type
    func setFieldPosition(type: FieldTypes,
                        id: String,
                        x: Double = 0,
                        y: Double = 63,
                        width: Double = 12,
                        height: Double = 8) -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = id
        fieldPosition.displayType = "original"
        fieldPosition.width = width
        fieldPosition.height = height
        fieldPosition.x = x
        fieldPosition.y = y
        fieldPosition.id = UUID().uuidString
        fieldPosition.type = type
        
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    // MARK: - Convenience Methods
    
    /// Adds a number field to the document
    func addNumberField(identifier: String = "number1", 
                      formula: String? = nil, 
                      id: String = UUID().uuidString, 
                      value: Double = 98789) -> JoyDoc {
        return addField(type: .number, 
                       identifier: identifier, 
                       formula: formula, 
                       id: id, 
                       value: .double(value))
    }
    
    /// Adds a text field to the document
    func addTextField(identifier: String = "text1", 
                    formula: String? = nil, 
                    id: String = UUID().uuidString, 
                    value: String = "Sample Text") -> JoyDoc {
        return addField(type: .text, 
                       identifier: identifier, 
                       formula: formula, 
                       id: id, 
                       value: .string(value))
    }
    
    /// Adds a date field to the document
    func addDateField(identifier: String = "date1",
                    formula: String? = nil,
                    id: String = UUID().uuidString,
                    date: Date = Date()) -> JoyDoc {
        // Convert Date to timestamp (milliseconds since epoch)
        let timestamp = date.timeIntervalSince1970 * 1000
        
        return addField(type: .date,
                       identifier: identifier,
                       formula: formula,
                       id: id,
                       value: .double(timestamp))
    }
    
    /// Adds a textarea field to the document
    func addTextareaField(identifier: String = "textarea1",
                      formula: String? = nil,
                      id: String = UUID().uuidString,
                      value: String = "Sample multiline text") -> JoyDoc {
        return addField(type: .textarea,
                       identifier: identifier,
                       formula: formula,
                       id: id,
                       value: .string(value))
    }
    
    /// Adds a dropdown field to the document
    func addDropdownField(identifier: String = "dropdown1",
                       formula: String? = nil,
                       id: String = UUID().uuidString,
                       selectedValue: String = "",
                       options: [Option] = []) -> JoyDoc {
        var doc = addField(type: .dropdown,
                          identifier: identifier,
                          formula: formula,
                          id: id,
                          value: .string(selectedValue))
        
        // Add options to the field
        if !options.isEmpty {
            if let index = doc.fields.firstIndex(where: { $0.id == id }) {
                doc.fields[index].options = options
            }
        }
        
        return doc
    }
    
    /// Adds a multiSelect field to the document
    func addMultiSelectField(identifier: String = "multiselect1",
                           formula: String? = nil,
                           id: String = UUID().uuidString,
                           selectedValues: [String] = [],
                           options: [Option] = []) -> JoyDoc {
        var doc = addField(type: .multiSelect,
                          identifier: identifier,
                          formula: formula,
                          id: id,
                          value: .array(selectedValues))
        
        // Add options to the field and set multi flag
        if let index = doc.fields.firstIndex(where: { $0.id == id }) {
            doc.fields[index].options = options
            doc.fields[index].multi = true
        }
        
        return doc
    }
    
    /// Adds a signature field to the document
    func addSignatureField(identifier: String = "signature1",
                         formula: String? = nil,
                         id: String = UUID().uuidString,
                         signatureUrl: String = "") -> JoyDoc {
        return addField(type: .signature,
                       identifier: identifier,
                       formula: formula,
                       id: id,
                       value: .string(signatureUrl))
    }
    
    /// Adds a block field to the document
    func addBlockField(identifier: String = "block1",
                     formula: String? = nil,
                     id: String = UUID().uuidString) -> JoyDoc {
        return addField(type: .block,
                       identifier: identifier,
                       formula: formula,
                       id: id,
                       value: .null)
    }
    
    /// Adds a chart field to the document
    func addChartField(identifier: String = "chart1",
                     formula: String? = nil,
                     id: String = UUID().uuidString,
                     points: [Point] = []) -> JoyDoc {
        // Create value elements for the points
        let pointElements: [ValueElement] = points.map { point in
            var element = ValueElement(id: point.id ?? UUID().uuidString)
            if let x = point.x {
                element.dictionary["x"] = .double(Double(x))
            }
            if let y = point.y {
                element.dictionary["y"] = .double(Double(y))
            }
            if let label = point.label {
                element.dictionary["label"] = .string(label)
            }
            return element
        }
        
        return addField(type: .chart,
                       identifier: identifier,
                       formula: formula,
                       id: id,
                       value: .valueElementArray(pointElements))
    }
    
    /// Adds a rich text field to the document
    func addRichTextField(identifier: String = "richtext1",
                        formula: String? = nil,
                        id: String = UUID().uuidString,
                        htmlContent: String = "<p>Sample rich text</p>") -> JoyDoc {
        return addField(type: .richText,
                       identifier: identifier,
                       formula: formula,
                       id: id,
                       value: .string(htmlContent))
    }
    
    /// Adds a table field to the document
    func addTableField(identifier: String = "table1",
                     formula: String? = nil,
                     id: String = UUID().uuidString,
                     columns: [FieldTableColumn] = [],
                     rows: [ValueElement] = []) -> JoyDoc {
        var doc = addField(type: .table,
                          identifier: identifier,
                          formula: formula,
                          id: id,
                          value: .valueElementArray(rows))
        
        // Add columns and set up table field
        if let index = doc.fields.firstIndex(where: { $0.id == id }) {
            doc.fields[index].tableColumns = columns
            
            // Generate column order from column IDs
            let columnOrder = columns.compactMap { $0.id }
            doc.fields[index].tableColumnOrder = columnOrder
            
            // Generate row order from row IDs
            let rowOrder = rows.compactMap { $0.id }
            doc.fields[index].rowOrder = rowOrder
        }
        
        return doc
    }
    
    /// Adds a collection field to the document
    func addCollectionField(identifier: String = "collection1",
                          formula: String? = nil,
                          id: String = UUID().uuidString,
                          schema: [String: Schema] = [:]) -> JoyDoc {
        var doc = addField(type: .collection,
                          identifier: identifier,
                          formula: formula,
                          id: id,
                          value: .null)
        
        // Add schema to the field
        if let index = doc.fields.firstIndex(where: { $0.id == id }) {
            doc.fields[index].schema = schema
        }
        
        return doc
    }
    
    /// Adds an image field to the document
    func addImageField(identifier: String = "image1",
                     formula: String? = nil,
                     id: String = UUID().uuidString,
                     imageUrl: String = "",
                     allowMultiple: Bool = false) -> JoyDoc {
        var doc = addField(type: .image,
                          identifier: identifier,
                          formula: formula,
                          id: id,
                          value: .string(imageUrl))
        
        // Set multi flag for multiple images
        if let index = doc.fields.firstIndex(where: { $0.id == id }) {
            doc.fields[index].multi = allowMultiple
        }
        
        return doc
    }
}
