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
    
    // MARK: - Formula Management
    
    /// Adds a formula to the JoyDoc
    func addFormula(id: String = UUID().uuidString,
                   desc: String = "",
                   type: String = "calc",
                   scope: String = "global",
                   formula: String) -> JoyDoc {
        var formulaObj = Formula()
        formulaObj.id = id
        formulaObj.desc = desc
        formulaObj.type = type
        formulaObj.scope = scope
        formulaObj.expression = formula
        
        var doc = self
        doc.formulas.append(formulaObj)
        return doc
    }
    
    /// Adds an applied formula to a field
    func applyFormulaToField(fieldId: String, 
                           formulaId: String,
                           key: String = "value") -> JoyDoc {
        var doc = self
        guard let fieldIndex = doc.fields.firstIndex(where: { $0.id == fieldId }) else {
            return self
        }
        
        var appliedFormula = AppliedFormula()
        appliedFormula.id = UUID().uuidString
        appliedFormula.formula = formulaId
        appliedFormula.key = key
        
        var field = doc.fields[fieldIndex]
        var formulas = field.formulas ?? []
        formulas.append(appliedFormula)
        field.formulas = formulas
        
        doc.fields[fieldIndex] = field
        return doc
    }
    
    /// Adds an applied formula to a page
    func applyFormulaToPage(pageId: String, 
                          formulaId: String,
                          key: String = "value") -> JoyDoc {
        var doc = self
        guard let fileIndex = doc.files.indices.first,
              let pageIndex = doc.files[fileIndex].pages?.firstIndex(where: { $0.id == pageId }) else {
            return self
        }
        
        var appliedFormula = AppliedFormula()
        appliedFormula.id = UUID().uuidString
        appliedFormula.formula = formulaId
        appliedFormula.key = key
        
        var page = doc.files[fileIndex].pages![pageIndex]
        var formulas = page.formulas ?? []
        formulas.append(appliedFormula)
        page.formulas = formulas
        
        doc.files[fileIndex].pages![pageIndex] = page
        return doc
    }
    
    // MARK: - Generic Field Creation
    
    /// Adds a field of specified type to the document
    func addField(type: FieldTypes, 
                  identifier: String = "field_6629fb3fabb87e37c9578b8b", 
                  formulaRef: String? = nil,
                  formulaKey: String = "value",
                  id: String = UUID().uuidString, 
                  value: ValueUnion,
                  label: String? = nil) -> JoyDoc {
        var doc = self
            .setFieldData(type: type, identifier: identifier, id: identifier, value: value, label: label)
            .setFieldPosition(type: type, id: id)
        
        // Apply formula if provided
        if let formulaRef = formulaRef {
            doc = doc.applyFormulaToField(fieldId: id, formulaId: formulaRef, key: formulaKey)
        }
        
        return doc
    }
    
    /// Sets field data for any field type
    func setFieldData(type: FieldTypes,
                     identifier: String = "field_6629fb3fabb87e37c9578b8b", 
                     id: String = UUID().uuidString,
                     value: ValueUnion,
                     label: String? = nil) -> JoyDoc {
        var field = JoyDocField()
        field.type = type.rawValue
        field.id = id
        field.identifier = identifier
        field.title = label ?? identifier
        field.description = ""
        field.value = value
        field.required = false
        field.tipTitle = ""
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
                      formulaRef: String? = nil, 
                      formulaKey: String = "value",
                      id: String = UUID().uuidString, 
                      value: Double = 98789,
                      label: String? = nil) -> JoyDoc {
        return addField(type: .number, 
                       identifier: identifier, 
                       formulaRef: formulaRef, 
                       formulaKey: formulaKey,
                       id: identifier, 
                       value: .double(value),
                       label: label)
    }
    
    /// Adds a text field to the document
    func addTextField(identifier: String = "text1", 
                    formulaRef: String? = nil, 
                    formulaKey: String = "value",
                    id: String = UUID().uuidString, 
                    value: String = "Sample Text",
                    label: String? = nil) -> JoyDoc {
        return addField(type: .text, 
                       identifier: identifier, 
                       formulaRef: formulaRef, 
                       formulaKey: formulaKey,
                       id: identifier, 
                       value: .string(value),
                       label: label)
    }
    
    /// Adds a date field to the document
    func addDateField(identifier: String = "date1",
                    formulaRef: String? = nil,
                    formulaKey: String = "value",
                    id: String = UUID().uuidString,
                    value: Date? = nil,
                    label: String? = nil) -> JoyDoc {
        // Convert Date to timestamp (milliseconds since epoch)
        let timestamp = value?.timeIntervalSince1970 ?? 0
        
        return addField(type: .date,
                       identifier: identifier,
                       formulaRef: formulaRef,
                       formulaKey: formulaKey,
                       id: identifier,
                       value: value != nil ? .double(timestamp * 1000) : .null,
                       label: label)
    }
    
    /// Adds a textarea field to the document
    func addTextareaField(identifier: String = "textarea1",
                      formulaRef: String? = nil,
                      formulaKey: String = "value",
                      id: String = UUID().uuidString,
                      value: String = "Sample multiline text") -> JoyDoc {
        return addField(type: .textarea,
                       identifier: identifier,
                       formulaRef: formulaRef,
                       formulaKey: formulaKey,
                       id: identifier,
                       value: .string(value))
    }
    
    /// Adds a dropdown field to the document
    func addDropdownField(identifier: String = "dropdown1",
                       formulaRef: String? = nil,
                       formulaKey: String = "value",
                       id: String = UUID().uuidString,
                       selectedValue: String = "",
                       options: [Option] = []) -> JoyDoc {
        var doc = addField(type: .dropdown,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
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
                           formulaRef: String? = nil,
                           formulaKey: String = "value",
                           id: String = UUID().uuidString,
                           selectedValues: [String] = [],
                           options: [Option] = []) -> JoyDoc {
        var doc = addField(type: .multiSelect,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
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
                         formulaRef: String? = nil,
                         formulaKey: String = "value",
                         id: String = UUID().uuidString,
                         signatureUrl: String = "") -> JoyDoc {
        return addField(type: .signature,
                       identifier: identifier,
                       formulaRef: formulaRef,
                       formulaKey: formulaKey,
                       id: identifier,
                       value: .string(signatureUrl))
    }
    
    /// Adds a block field to the document
    func addBlockField(identifier: String = "block1",
                     formulaRef: String? = nil,
                     formulaKey: String = "value",
                     id: String = UUID().uuidString) -> JoyDoc {
        return addField(type: .block,
                       identifier: identifier,
                       formulaRef: formulaRef,
                       formulaKey: formulaKey,
                       id: identifier,
                       value: .null)
    }
    
    /// Adds a chart field to the document
    func addChartField(identifier: String = "chart1",
                     formulaRef: String? = nil,
                     formulaKey: String = "value",
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
                       formulaRef: formulaRef,
                       formulaKey: formulaKey,
                       id: identifier,
                       value: .valueElementArray(pointElements))
    }
    
    /// Adds a rich text field to the document
    func addRichTextField(identifier: String = "richtext1",
                        formulaRef: String? = nil,
                        formulaKey: String = "value",
                        id: String = UUID().uuidString,

                        label: String? = nil,
                        htmlContent: String = "<p>Sample rich text</p>") -> JoyDoc {
        return addField(type: .richText,
                       identifier: identifier,
                       formulaRef: formulaRef,
                       formulaKey: formulaKey,
                       id: identifier,
                       value: .string(htmlContent))
    }
    
    /// Adds a table field to the document
    func addTableField(identifier: String = "table1",
                     formulaRef: String? = nil,
                     formulaKey: String = "value",
                     columns: [FieldTableColumn] = [],
                     rows: [ValueElement] = []) -> JoyDoc {
        var doc = addField(type: .table,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
                          value: .valueElementArray(rows))
        
        // Add columns and set up table field
        if let index = doc.fields.firstIndex(where: { $0.id == identifier }) {
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
                          formulaRef: String? = nil,
                          formulaKey: String = "value",
                          id: String = UUID().uuidString,
                          schema: [String: Schema] = [:]) -> JoyDoc {
        var doc = addField(type: .collection,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
                          value: .null)
        
        // Add schema to the field
        if let index = doc.fields.firstIndex(where: { $0.id == id }) {
            doc.fields[index].schema = schema
        }
        
        return doc
    }

    //    /// Adds a collection field to the document
//    func addCollectionField(identifier: String = "collection1",
//                          formulaRef: String? = nil,
//                          formulaKey: String = "value",
//                          id: String = UUID().uuidString,
//                          schema: [String: Schema] = [:]) -> JoyDoc {
//        var doc = addField(type: .collection,
//                          identifier: identifier,
//                          formulaRef: formulaRef,
//                          formulaKey: formulaKey,
//                          id: identifier,
//                          value: .null)
//        
//        // Add schema to the field
//        if let index = doc.fields.firstIndex(where: { $0.id == id }) {
//            doc.fields[index].schema = schema
//        }
//        
//        return doc
//    }


    /// Adds an image field to the document
    func addImageField(identifier: String = "image1",
                     formulaRef: String? = nil,
                     formulaKey: String = "value",
                     id: String = UUID().uuidString,
                     imageUrl: String = "",
                     allowMultiple: Bool = false) -> JoyDoc {
        var doc = addField(type: .image,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
                          value: .string(imageUrl))
        
        // Set multi flag for multiple images
        if let index = doc.fields.firstIndex(where: { $0.id == id }) {
            doc.fields[index].multi = allowMultiple
        }
        
        return doc
    }
    
    /// Adds a checkbox field to the document
    func addCheckboxField(identifier: String = "checkbox1",
                        formulaRef: String? = nil,
                        formulaKey: String = "value",
                        id: String = UUID().uuidString,
                        value: Bool = false,
                        label: String? = nil) -> JoyDoc {
        return addField(type: .multiSelect,
                       identifier: identifier,
                       formulaRef: formulaRef,
                       formulaKey: formulaKey,
                       id: identifier,
                       value: .bool(value),
                       label: label)
    }
    
    /// Adds an option field to the document
    func addOptionField(identifier: String = "option1",
                      formulaRef: String? = nil,
                      formulaKey: String = "value",
                      id: String = UUID().uuidString,
                      value: [String] = [""],
                      options: [String] = [],
                      multiselect: Bool = false,
                      label: String? = nil) -> JoyDoc {
        var doc: JoyDoc
        
        if multiselect {
            let selectedValues = value.isEmpty ? [] : [value]
            doc = addField(type: .multiSelect,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
                          value: .array(value),
                          label: label)
        } else {
            doc = addField(type: .dropdown,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
                           value: .string(value.first!),
                          label: label)
        }
        
        // Add options to the field
        if !options.isEmpty, let index = doc.fields.firstIndex(where: { $0.id == id }) {
            let fieldOptions = options.map { option -> Option in
                var opt = Option()
                opt.id = UUID().uuidString
                opt.value = option
                return opt
            }
            
            doc.fields[index].options = fieldOptions
            
            if multiselect {
                doc.fields[index].multi = true
            }
        }
        
        return doc
    }
    
    // MARK: - Table Cell Resolution Test Document
    
    /// Creates a comprehensive table cell resolution test document with standardized formulas and data
    /// This method ensures consistency between tests and FormBuilderView templates
    static func createTableCellResolutionDocument() -> JoyDoc {
        return JoyDoc.addDocument()
            // 1. Entire Table Access (2 formulas)
            .addFormula(id: "tableRowCount", formula: "COUNT(products)")
            .addFormula(id: "tableAsText", formula: "CONCAT(\"Table has \", COUNT(products), \" rows\")")
            
            // 2. Specific Row Access (5 formulas)
            .addFormula(id: "firstRowName", formula: "products.0.name")
            .addFormula(id: "firstRowPrice", formula: "products.0.price")
            .addFormula(id: "firstRowInStock", formula: "products.0.inStock")
            .addFormula(id: "secondRowCategory", formula: "products.1.category")
            .addFormula(id: "firstRowAsText", formula: "CONCAT(products.0.name, \" costs $\", products.0.price)")
            
            // 3. Entire Column Access (4 formulas)
            .addFormula(id: "allPrices", formula: "products.price")
            .addFormula(id: "allNames", formula: "products.name")
            .addFormula(id: "allCategories", formula: "products.category")
            .addFormula(id: "allStockStatus", formula: "products.inStock")
            
            // 4. Aggregate Functions on Columns (5 formulas)
            .addFormula(id: "totalPrice", formula: "SUM(products.price)")
            .addFormula(id: "avgPrice", formula: "AVERAGE(products.price)")
            .addFormula(id: "maxPrice", formula: "MAX(products.price)")
            .addFormula(id: "minPrice", formula: "MIN(products.price)")
            .addFormula(id: "priceCount", formula: "COUNT(products.price)")
            
            // 5. Array Functions with Columns (5 formulas)
            .addFormula(id: "expensiveItems", formula: "FILTER(products.price, (p) → p > 50)")
            .addFormula(id: "doubledPrices", formula: "MAP(products.price, (p) → p * 2)")
            .addFormula(id: "firstExpensiveItem", formula: "FIND(products.price, (p) → p > 100)")
            .addFormula(id: "hasExpensiveItems", formula: "SOME(products.price, (p) → p > 100)")
            .addFormula(id: "allItemsCheap", formula: "EVERY(products.price, (p) → p < 1000)")
            
            // 6. String Functions with Columns (3 formulas)
            .addFormula(id: "upperCaseNames", formula: "MAP(products.name, (n) → UPPER(n))")
            .addFormula(id: "nameList", formula: "CONCAT(\"Products: \", JOIN(products.name, \", \"))")
            .addFormula(id: "categoryCount", formula: "COUNT(UNIQUE(products.category))")
            
            // 7. Logical Functions with Columns (3 formulas)
            .addFormula(id: "allInStock", formula: "EVERY(products.inStock, (stock) → stock)")
            .addFormula(id: "anyInStock", formula: "SOME(products.inStock, (stock) → stock)")
            .addFormula(id: "stockSummary", formula: "CONCAT(\"In Stock: \", COUNT(FILTER(products.inStock, (s) → s)), \" / \", COUNT(products))")
            
            // 8. Complex Calculations (4 formulas)
            .addFormula(id: "taxRate", formula: "IF(totalPrice > 500, 0.15, 0.10)")
            .addFormula(id: "pricesWithTax", formula: "MAP(products.price, (p) → p + (p * taxRate))")
            .addFormula(id: "totalWithTax", formula: "SUM(pricesWithTax)")
            .addFormula(id: "discountedPrices", formula: "MAP(products.price, (p) → IF(p > 100, p * 0.9, p))")
            
            // 9. Conditional Logic with Row Data (2 formulas)
            .addFormula(id: "priceCategory", formula: "IF(products.0.price < 50, \"Budget\", IF(products.0.price < 100, \"Mid-range\", \"Premium\"))")
            .addFormula(id: "stockWarning", formula: "IF(products.0.inStock, \"Available\", \"Out of Stock\")")
            
            // 10. Mixed References (3 formulas)
            .addFormula(id: "averageVsFirst", formula: "products.0.price - avgPrice")
            .addFormula(id: "priceSpread", formula: "maxPrice - minPrice")
            .addFormula(id: "inventoryValue", formula: "SUM(MAP(products, (row) → IF(row.inStock, row.price, 0)))")
            
            // Create comprehensive table with sample data
            .addTableField(
                identifier: "products",
                columns: [
                    // Product Name Column (Text)
                    {
                        var nameColumn = FieldTableColumn()
                        nameColumn.id = "name"
                        nameColumn.title = "Product Name"
                        nameColumn.type = .text
                        nameColumn.required = true
                        nameColumn.width = 200
                        return nameColumn
                    }(),
                    
                    // Price Column (Number)
                    {
                        var priceColumn = FieldTableColumn()
                        priceColumn.id = "price"
                        priceColumn.title = "Price"
                        priceColumn.type = .number
                        priceColumn.required = true
                        priceColumn.width = 100
                        return priceColumn
                    }(),
                    
                    // Category Column (Dropdown)
                    {
                        var categoryColumn = FieldTableColumn()
                        categoryColumn.id = "category"
                        categoryColumn.title = "Category"
                        categoryColumn.type = .dropdown
                        categoryColumn.required = false
                        categoryColumn.width = 150
                        
                        // Add dropdown options for category
                        var electronicsOption = Option()
                        electronicsOption.id = "electronics"
                        electronicsOption.value = "Electronics"
                        
                        var clothingOption = Option()
                        clothingOption.id = "clothing"
                        clothingOption.value = "Clothing"
                        
                        var homeOption = Option()
                        homeOption.id = "home"
                        homeOption.value = "Home & Garden"
                        
                        var sportsOption = Option()
                        sportsOption.id = "sports"
                        sportsOption.value = "Sports"
                        
                        categoryColumn.options = [electronicsOption, clothingOption, homeOption, sportsOption]
                        
                        return categoryColumn
                    }(),
                    
                    // In Stock Column (Dropdown)
                    {
                        var stockColumn = FieldTableColumn()
                        stockColumn.id = "inStock"
                        stockColumn.title = "In Stock"
                        stockColumn.type = .dropdown
                        stockColumn.required = false
                        stockColumn.width = 120
                        
                        // Add dropdown options for stock status
                        var yesOption = Option()
                        yesOption.id = "yes"
                        yesOption.value = "Yes"
                        
                        var noOption = Option()
                        noOption.id = "no"
                        noOption.value = "No"
                        
                        stockColumn.options = [yesOption, noOption]
                        
                        return stockColumn
                    }(),
                    
                    // Description Column (Text)
                    {
                        var descColumn = FieldTableColumn()
                        descColumn.id = "description"
                        descColumn.title = "Description"
                        descColumn.type = .text
                        descColumn.required = false
                        descColumn.width = 250
                        return descColumn
                    }()
                ],
                rows: [
                    // Row 1: Laptop
                    {
                        var row1 = ValueElement(id: "row1")
                        row1.cells = [
                            "name": .string("Laptop"),
                            "price": .double(999.99),
                            "category": .string("Electronics"),
                            "inStock": .string("Yes"),
                            "description": .string("High-performance laptop")
                        ]
                        return row1
                    }(),
                    
                    // Row 2: T-Shirt
                    {
                        var row2 = ValueElement(id: "row2")
                        row2.cells = [
                            "name": .string("T-Shirt"),
                            "price": .double(29.99),
                            "category": .string("Clothing"),
                            "inStock": .string("Yes"),
                            "description": .string("Cotton t-shirt")
                        ]
                        return row2
                    }(),
                    
                    // Row 3: Garden Tools
                    {
                        var row3 = ValueElement(id: "row3")
                        row3.cells = [
                            "name": .string("Garden Tools"),
                            "price": .double(75.50),
                            "category": .string("Home & Garden"),
                            "inStock": .string("No"),
                            "description": .string("Complete garden tool set")
                        ]
                        return row3
                    }()
                ]
            )
            
            // Output fields for testing results - Basic table info
            .addNumberField(identifier: "rowCount", formulaRef: "tableRowCount", label: "Total Rows")
            .addTextField(identifier: "tableInfo", formulaRef: "tableAsText", label: "Table Summary")
            
            // Specific row access results
            .addTextField(identifier: "firstProductName", formulaRef: "firstRowName", label: "First Product Name")
            .addNumberField(identifier: "firstProductPrice", formulaRef: "firstRowPrice", label: "First Product Price")
            .addTextField(identifier: "firstProductInStock", formulaRef: "firstRowInStock", label: "First Product In Stock")
            .addTextField(identifier: "secondProductCategory", formulaRef: "secondRowCategory", label: "Second Product Category")
            .addTextField(identifier: "firstProductDesc", formulaRef: "firstRowAsText", label: "First Product Description")
            
            // Column array access results
            .addTextField(identifier: "priceArray", formulaRef: "allPrices", label: "All Prices Array")
            .addTextField(identifier: "nameArray", formulaRef: "allNames", label: "All Names Array")
            .addTextField(identifier: "categoryArray", formulaRef: "allCategories", label: "All Categories Array")
            .addTextField(identifier: "stockArray", formulaRef: "allStockStatus", label: "All Stock Status Array")
            
            // Aggregate function results
            .addNumberField(identifier: "totalPriceResult", formulaRef: "totalPrice", label: "Total Price")
            .addNumberField(identifier: "avgPriceResult", formulaRef: "avgPrice", label: "Average Price")
            .addNumberField(identifier: "maxPriceResult", formulaRef: "maxPrice", label: "Maximum Price")
            .addNumberField(identifier: "minPriceResult", formulaRef: "minPrice", label: "Minimum Price")
            .addNumberField(identifier: "priceCountResult", formulaRef: "priceCount", label: "Price Count")
            
            // Array function results
            .addTextField(identifier: "expensiveResult", formulaRef: "expensiveItems", label: "Expensive Items")
            .addTextField(identifier: "doubledResult", formulaRef: "doubledPrices", label: "Doubled Prices")
            .addNumberField(identifier: "firstExpensiveResult", formulaRef: "firstExpensiveItem", label: "First Expensive Item")
            .addTextField(identifier: "hasExpensiveResult", formulaRef: "hasExpensiveItems", label: "Has Expensive Items")
            .addTextField(identifier: "allCheapResult", formulaRef: "allItemsCheap", label: "All Items Cheap")
            
            // String function results
            .addTextField(identifier: "upperNamesResult", formulaRef: "upperCaseNames", label: "Uppercase Names")
            .addTextField(identifier: "nameListResult", formulaRef: "nameList", label: "Name List")
            .addNumberField(identifier: "categoryCountResult", formulaRef: "categoryCount", label: "Unique Categories")
            
            // Logic function results
            .addTextField(identifier: "allInStockResult", formulaRef: "allInStock", label: "All In Stock")
            .addTextField(identifier: "anyInStockResult", formulaRef: "anyInStock", label: "Any In Stock")
            .addTextField(identifier: "stockSummaryResult", formulaRef: "stockSummary", label: "Stock Summary")
            
            // Complex calculation results
            .addNumberField(identifier: "taxRateResult", formulaRef: "taxRate", label: "Tax Rate")
            .addTextField(identifier: "pricesWithTaxResult", formulaRef: "pricesWithTax", label: "Prices With Tax")
            .addNumberField(identifier: "totalWithTaxResult", formulaRef: "totalWithTax", label: "Total With Tax")
            .addTextField(identifier: "discountedPricesResult", formulaRef: "discountedPrices", label: "Discounted Prices")
            
            // Conditional results
            .addTextField(identifier: "priceCategoryResult", formulaRef: "priceCategory", label: "Price Category")
            .addTextField(identifier: "stockWarningResult", formulaRef: "stockWarning", label: "Stock Warning")
            
            // Mixed reference results
            .addNumberField(identifier: "avgVsFirstResult", formulaRef: "averageVsFirst", label: "Avg vs First Price")
            .addNumberField(identifier: "priceSpreadResult", formulaRef: "priceSpread", label: "Price Spread")
            .addNumberField(identifier: "inventoryValueResult", formulaRef: "inventoryValue", label: "Inventory Value")
    }
}
