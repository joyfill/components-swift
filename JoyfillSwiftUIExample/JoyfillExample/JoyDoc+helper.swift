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

        let fieldOptions = options.map { option -> Option in
            var opt = Option()
            opt.id = UUID().uuidString
            opt.value = option
            return opt
        }

        if multiselect {
            doc = addField(type: .multiSelect,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
                           value: .array(fieldOptions.filter { value.contains($0.value ?? UUID().uuidString) }.map { $0.id ?? "" }),
                          label: label)
        } else {
            doc = addField(type: .dropdown,
                          identifier: identifier,
                          formulaRef: formulaRef,
                          formulaKey: formulaKey,
                          id: identifier,
                           value: .string(fieldOptions.first { $0.value == value.first }?.id ?? ""),
                          label: label)
        }
        
        // Add options to the field
        if !options.isEmpty, let index = doc.fields.firstIndex(where: { $0.id == identifier }) {
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
            .addFormula(id: "expensiveItems", formula: "FILTER(products.price, (p) -> p > 50)")
            .addFormula(id: "doubledPrices", formula: "MAP(products.price, (p) -> p * 2)")
            .addFormula(id: "firstExpensiveItem", formula: "FIND(products.price, (p) -> p > 100)")
            .addFormula(id: "hasExpensiveItems", formula: "SOME(products.price, (p) -> p > 100)")
            .addFormula(id: "allItemsCheap", formula: "EVERY(products.price, (p) -> p < 1000)")
            
            // 6. String Functions with Columns (3 formulas)
            .addFormula(id: "upperCaseNames", formula: "MAP(products.name, (n) -> UPPER(n))")
            .addFormula(id: "nameList", formula: "CONCAT(\"Products: \", JOIN(products.name, \", \"))")
            .addFormula(id: "categoryCount", formula: "COUNT(UNIQUE(products.category))")
            
            // 7. Logical Functions with Columns (3 formulas)
            .addFormula(id: "allInStock", formula: "EVERY(products.inStock, (stock) -> EQUALS(stock, \"Yes\"))")
            .addFormula(id: "anyInStock", formula: "SOME(products.inStock, (stock) -> EQUALS(stock, \"Yes\"))")
            .addFormula(id: "stockSummary", formula: "CONCAT(\"In Stock: \", COUNT(FILTER(products.inStock, (s) -> EQUALS(s, \"Yes\"))), \" / \", COUNT(products))")
            
            // 8. Complex Calculations (4 formulas)
            .addFormula(id: "taxRate", formula: "IF(SUM(products.price) > 500, 0.15, 0.10)")
            .addFormula(id: "pricesWithTax", formula: "MAP(products.price, (p) -> p + (p * 0.15))")
            .addFormula(id: "totalWithTax", formula: "SUM(MAP(products.price, (p) -> p + (p * 0.15)))")
            .addFormula(id: "discountedPrices", formula: "MAP(products.price, (p) -> IF(p > 100, p * 0.9, p))")
            
            // 9. Conditional Logic with Row Data (2 formulas)
            .addFormula(id: "priceCategory", formula: "IF(products.0.price < 50, \"Budget\", IF(products.0.price < 100, \"Mid-range\", \"Premium\"))")
            .addFormula(id: "stockWarning", formula: "IF(EQUALS(products.0.inStock, \"Yes\"), \"Available\", \"Out of Stock\")")
            
            // 10. Mixed References (3 formulas)
            .addFormula(id: "averageVsFirst", formula: "products.0.price - AVERAGE(products.price)")
            .addFormula(id: "priceSpread", formula: "MAX(products.price) - MIN(products.price)")
            .addFormula(id: "inventoryValue", formula: "products.0.price + products.1.price")
            
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

    /// Creates a comprehensive table cell resolution document that covers ALL specification use cases
    /// This method ensures consistency between tests and FormBuilderView templates
    static func createComprehensiveTableCellResolutionDocument() -> JoyDoc {
        return JoyDoc.addDocument()
            // BASIC ACCESS PATTERNS
            .addFormula(id: "basicTextAccess", formula: "products.0.name")
            .addFormula(id: "basicDropdownAccess", formula: "products.0.category")
            .addFormula(id: "basicNumberAccess", formula: "products.0.price")
            .addFormula(id: "basicMultiSelectAccess", formula: "products.0.tags")
            .addFormula(id: "basicMultiSelectFirstItem", formula: "products.0.tags.0")
            .addFormula(id: "basicImageAccess", formula: "products.0.images")
            .addFormula(id: "basicImageFirstItem", formula: "products.0.images.0")
            .addFormula(id: "basicDateAccess", formula: "products.0.createdDate")
            .addFormula(id: "basicBlockAccess", formula: "products.0.description")
            .addFormula(id: "basicBarcodeAccess", formula: "products.0.barcode")
            .addFormula(id: "basicSignatureAccess", formula: "products.0.signature")
            
            // COLUMN ACCESS (ALL CELLS)
            .addFormula(id: "allNames", formula: "products.name")
            .addFormula(id: "allPrices", formula: "products.price")
            .addFormula(id: "allCategories", formula: "products.category")
            .addFormula(id: "allTags", formula: "products.tags")
            .addFormula(id: "allImages", formula: "products.images")
            .addFormula(id: "allDates", formula: "products.createdDate")
            .addFormula(id: "allDescriptions", formula: "products.description")
            .addFormula(id: "allBarcodes", formula: "products.barcode")
            .addFormula(id: "allSignatures", formula: "products.signature")
            
            // AGGREGATE FUNCTIONS
            .addFormula(id: "totalRows", formula: "LENGTH(products)")
            .addFormula(id: "totalPrice", formula: "SUM(products.price)")
            .addFormula(id: "avgPrice", formula: "AVERAGE(products.price)")
            .addFormula(id: "maxPrice", formula: "MAX(products.price)")
            .addFormula(id: "minPrice", formula: "MIN(products.price)")
            .addFormula(id: "priceCount", formula: "COUNT(products.price)")
            
            // STRING FUNCTIONS
            .addFormula(id: "emptyTextCount", formula: "LENGTH(FILTER(products, (row) -> EMPTY(row.name)))")
            .addFormula(id: "exactNameMatch", formula: "LENGTH(FILTER(products, (row) -> row.name == \"Laptop\"))")
            .addFormula(id: "nameContainsJack", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(LOWER(row.name), \"jack\")))")
            .addFormula(id: "nameLabels", formula: "MAP(products, (row, i) -> CONCAT(row.name, \" (\", TOSTRING(i), \")\"))")
            .addFormula(id: "upperNames", formula: "MAP(products.name, (name) -> UPPER(name))")
            .addFormula(id: "lowerCategories", formula: "MAP(products.category, (cat) -> LOWER(cat))")
            
            // DROPDOWN FUNCTIONS
            .addFormula(id: "yesDropdownCount", formula: "LENGTH(FILTER(products, (row) -> row.category == \"Electronics\"))")
            .addFormula(id: "notNADropdownCount", formula: "LENGTH(FILTER(products, (row) -> row.category != \"N/A\"))")
            .addFormula(id: "allDropdownsFilled", formula: "EVERY(products, (row) -> NOT(EMPTY(row.category)))")
            .addFormula(id: "dropdownConcat", formula: "REDUCE(products, (acc, row) -> CONCAT(acc, \", \", row.category), \"\")")
            
            // MULTISELECT FUNCTIONS
            .addFormula(id: "hasOption1Count", formula: "LENGTH(FILTER(products, (row) -> SOME(row.tags, (option) -> option == \"Popular\")))")
            .addFormula(id: "hasAllOptionsCount", formula: "LENGTH(FILTER(products, (row) -> AND(SOME(row.tags, (option) -> option == \"Popular\"), SOME(row.tags, (option) -> option == \"Sale\"), SOME(row.tags, (option) -> option == \"New\"))))")
            .addFormula(id: "emptyMultiSelectCount", formula: "LENGTH(FILTER(products, (row) -> EMPTY(row.tags)))")
            .addFormula(id: "flattenedTags", formula: "FLATMAP(products, (row) -> row.tags)")
            .addFormula(id: "reducedTags", formula: "REDUCE(FLATMAP(products, (row) -> row.tags), (acc, item) -> CONCAT(acc, \", \", item), \"\")")
            
            // IMAGE FUNCTIONS
            .addFormula(id: "hasImageCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.images))))")
            .addFormula(id: "allHaveImages", formula: "EVERY(products, (row) -> NOT(EMPTY(row.images)))")
            .addFormula(id: "maxImageCount", formula: "MAX(MAP(products, (row) -> LENGTH(row.images)))")
            
            // NUMBER FUNCTIONS
            .addFormula(id: "expensiveCount", formula: "LENGTH(FILTER(products, (row) -> row.price > 100))")
            .addFormula(id: "zeroCount", formula: "LENGTH(FILTER(products, (row) -> row.price == 0))")
            .addFormula(id: "squaredPrices", formula: "MAP(products, (row) -> POW(row.price, 2))")
            .addFormula(id: "evenPrices", formula: "MAP(products, (row) -> MOD(row.price, 2) == 0)")
            
            // DATE FUNCTIONS
            .addFormula(id: "hasDateCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.createdDate))))")
            .addFormula(id: "dayGte2Count", formula: "LENGTH(FILTER(products, (row) -> DAY(row.createdDate) >= 2))")
            .addFormula(id: "latestDate", formula: "MAX(MAP(products, (row) -> row.createdDate))")
            .addFormula(id: "extractedDays", formula: "MAP(products, (row) -> DAY(row.createdDate))")
            
            // BLOCK FUNCTIONS
            .addFormula(id: "questionCount", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(UPPER(row.description), \"QUESTION\")))")
            
            // BARCODE FUNCTIONS
            .addFormula(id: "codeStartsCount", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(row.barcode, \"code\")))")
            .addFormula(id: "nonEmptyBarcodeCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.barcode))))")
            .addFormula(id: "scannedLabels", formula: "MAP(products, (row) -> CONCAT(\"SCANNED \", row.barcode))")
            .addFormula(id: "replaceMissingBarcodes", formula: "MAP(products, (row) -> IF(EMPTY(row.barcode), \"MISSING\", row.barcode))")
            
            // SIGNATURE FUNCTIONS
            .addFormula(id: "hasSignatureCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.signature))))")
            .addFormula(id: "missingSignatureCount", formula: "LENGTH(FILTER(products, (row) -> EMPTY(row.signature)))")
            .addFormula(id: "totalSignedRows", formula: "REDUCE(products, (acc, row) -> acc + (NOT(EMPTY(row.signature)) ? 1 : 0), 0)")
            .addFormula(id: "allHaveSignatures", formula: "EVERY(products, (row) -> NOT(EMPTY(row.signature)))")
            .addFormula(id: "auditTags", formula: "MAP(products, (row, i) -> IF(NOT(EMPTY(row.signature)), CONCAT(\"Row \", TOSTRING(i), \" Signed\"), CONCAT(\"Row \", TOSTRING(i), \" Not Signed\")))")
            
            // OPERATORS
            .addFormula(id: "addTen", formula: "MAP(products, (row) -> row.price + 10)")
            .addFormula(id: "multiplyBySelf", formula: "MAP(products, (row) -> row.price * row.price)")
            .addFormula(id: "divideByTwo", formula: "MAP(products, (row) -> row.price / 2)")
            .addFormula(id: "subtractOne", formula: "MAP(products, (row) -> row.price - 1)")
            .addFormula(id: "equalToThree", formula: "MAP(products, (row) -> row.price == 3)")
            .addFormula(id: "notEqualYes", formula: "MAP(products, (row) -> row.category != \"Electronics\")")
            .addFormula(id: "greaterThanTen", formula: "MAP(products, (row) -> row.price > 10)")
            .addFormula(id: "greaterEqualEleven", formula: "MAP(products, (row) -> row.price >= 11)")
            .addFormula(id: "lessThanThree", formula: "MAP(products, (row) -> row.price < 3)")
            .addFormula(id: "lessEqualTwo", formula: "MAP(products, (row) -> row.price <= 2)")
            
            // COMPLEX CONDITIONALS
            .addFormula(id: "complexFilter", formula: "LENGTH(FILTER(products, (row) -> AND(IF(CONTAINS(LOWER(row.name), \"laptop\"), true, false), AND(SOME(row.tags, (option) -> option == \"Popular\"), SOME(row.tags, (option) -> option == \"Sale\"), SOME(row.tags, (option) -> option == \"New\")), OR(row.price == 3, row.price == 4))))")
            
            // Create comprehensive table with ALL column types
            .addTableField(
                identifier: "products",
                columns: [
                    // Text Column
                    {
                        var col = FieldTableColumn()
                        col.id = "name"
                        col.title = "Product Name"
                        col.type = .text
                        col.required = true
                        col.width = 200
                        return col
                    }(),
                    
                    // Number Column
                    {
                        var col = FieldTableColumn()
                        col.id = "price"
                        col.title = "Price"
                        col.type = .number
                        col.required = true
                        col.width = 100
                        return col
                    }(),
                    
                    // Dropdown Column
                    {
                        var col = FieldTableColumn()
                        col.id = "category"
                        col.title = "Category"
                        col.type = .dropdown
                        col.required = false
                        col.width = 150
                        
                        var opt1 = Option()
                        opt1.id = "electronics"
                        opt1.value = "Electronics"
                        
                        var opt2 = Option()
                        opt2.id = "clothing"
                        opt2.value = "Clothing"
                        
                        var opt3 = Option()
                        opt3.id = "na"
                        opt3.value = "N/A"
                        
                        col.options = [opt1, opt2, opt3]
                        return col
                    }(),
                    
                    // MultiSelect Column
                    {
                        var col = FieldTableColumn()
                        col.id = "tags"
                        col.title = "Tags"
                        col.type = .multiSelect
                        col.required = false
                        col.width = 200
                        
                        var opt1 = Option()
                        opt1.id = "popular"
                        opt1.value = "Popular"
                        
                        var opt2 = Option()
                        opt2.id = "sale"
                        opt2.value = "Sale"
                        
                        var opt3 = Option()
                        opt3.id = "new"
                        opt3.value = "New"
                        
                        col.options = [opt1, opt2, opt3]
                        return col
                    }(),
                    
                    // Image Column
                    {
                        var col = FieldTableColumn()
                        col.id = "images"
                        col.title = "Images"
                        col.type = .image
                        col.required = false
                        col.width = 150
                        return col
                    }(),
                    
                    // Date Column
                    {
                        var col = FieldTableColumn()
                        col.id = "createdDate"
                        col.title = "Created Date"
                        col.type = .date
                        col.required = false
                        col.width = 120
                        return col
                    }(),
                    
                    // Block Column
                    {
                        var col = FieldTableColumn()
                        col.id = "description"
                        col.title = "Description"
                        col.type = .block
                        col.required = false
                        col.width = 250
                        return col
                    }(),
                    
                    // Barcode Column
                    {
                        var col = FieldTableColumn()
                        col.id = "barcode"
                        col.title = "Barcode"
                        col.type = .barcode
                        col.required = false
                        col.width = 150
                        return col
                    }(),
                    
                    // Signature Column
                    {
                        var col = FieldTableColumn()
                        col.id = "signature"
                        col.title = "Signature"
                        col.type = .signature
                        col.required = false
                        col.width = 150
                        return col
                    }()
                ],
                rows: [
                    // Row 1: Comprehensive data
                    {
                        var row = ValueElement(id: "row1")
                        row.cells = [
                            "name": .string("Laptop"),
                            "price": .double(999.99),
                            "category": .string("Electronics"),
                            "tags": .array(["Popular", "Sale"]),
                            "images": .array(["https://example.com/laptop1.jpg", "https://example.com/laptop2.jpg"]),
                            "createdDate": .double(1748750400000), // Jan 1, 2025
                            "description": .string("Question 1: High-performance laptop"),
                            "barcode": .string("code 1"),
                            "signature": .string("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==")
                        ]
                        return row
                    }(),
                    
                    // Row 2: Mixed data
                    {
                        var row = ValueElement(id: "row2")
                        row.cells = [
                            "name": .string("T-Shirt"),
                            "price": .double(29.99),
                            "category": .string("Clothing"),
                            "tags": .array(["Popular", "New"]),
                            "images": .array(["https://example.com/tshirt.jpg"]),
                            "createdDate": .double(1748836800000), // Jan 2, 2025
                            "description": .string("Cotton t-shirt"),
                            "barcode": .string("code with space"),
                            "signature": .string("") // Empty signature
                        ]
                        return row
                    }(),
                    
                    // Row 3: Edge cases
                    {
                        var row = ValueElement(id: "row3")
                        row.cells = [
                            "name": .string(""),
                            "price": .double(0),
                            "category": .string("N/A"),
                            "tags": .array([]), // Empty array
                            "images": .array(["https://example.com/img1.jpg", "https://example.com/img2.jpg", "https://example.com/img3.jpg"]), // 3 images
                            "createdDate": .double(1748923200000), // Jan 3, 2025
                            "description": .string("Question 2: Empty name test"),
                            "barcode": .string(""),
                            "signature": .string("")
                        ]
                        return row
                    }(),
                    
                    // Row 4: More test data
                    {
                        var row = ValueElement(id: "row4")
                        row.cells = [
                            "name": .string("Jack's Item"),
                            "price": .double(11),
                            "category": .string("Electronics"),
                            "tags": .array(["Popular", "Sale", "New"]), // All three options
                            "images": .array([]), // No images
                            "createdDate": .double(1748750400000), // Jan 1, 2025 (same as row 1)
                            "description": .string("Question 3: Jack's special item"),
                            "barcode": .string("code 2"),
                            "signature": .string("")
                        ]
                        return row
                    }(),
                    
                    // Row 5: Final test data
                    {
                        var row = ValueElement(id: "row5")
                        row.cells = [
                            "name": .string("Jackie's Product"),
                            "price": .double(200),
                            "category": .string(""),
                            "tags": .array([]), // Empty
                            "images": .array([]), // Empty
                            "createdDate": .double(0), // Empty/null date
                            "description": .string("Regular description"),
                            "barcode": .string(""),
                            "signature": .string("")
                        ]
                        return row
                    }()
                ]
            )
            
            // Add output fields for ALL test cases
            .addTextField(identifier: "basicTextResult", formulaRef: "basicTextAccess", label: "Basic Text Access")
            .addTextField(identifier: "basicDropdownResult", formulaRef: "basicDropdownAccess", label: "Basic Dropdown Access")
            .addNumberField(identifier: "basicNumberResult", formulaRef: "basicNumberAccess", label: "Basic Number Access")
            .addTextField(identifier: "basicMultiSelectResult", formulaRef: "basicMultiSelectAccess", label: "Basic MultiSelect Access")
            .addTextField(identifier: "basicMultiSelectFirstResult", formulaRef: "basicMultiSelectFirstItem", label: "Basic MultiSelect First Item")
            .addTextField(identifier: "basicImageResult", formulaRef: "basicImageAccess", label: "Basic Image Access")
            .addTextField(identifier: "basicImageFirstResult", formulaRef: "basicImageFirstItem", label: "Basic Image First Item")
            .addNumberField(identifier: "basicDateResult", formulaRef: "basicDateAccess", label: "Basic Date Access")
            .addTextField(identifier: "basicBlockResult", formulaRef: "basicBlockAccess", label: "Basic Block Access")
            .addTextField(identifier: "basicBarcodeResult", formulaRef: "basicBarcodeAccess", label: "Basic Barcode Access")
            .addTextField(identifier: "basicSignatureResult", formulaRef: "basicSignatureAccess", label: "Basic Signature Access")
            
            // Column access results
            .addTextField(identifier: "allNamesResult", formulaRef: "allNames", label: "All Names")
            .addTextField(identifier: "allPricesResult", formulaRef: "allPrices", label: "All Prices")
            .addTextField(identifier: "allCategoriesResult", formulaRef: "allCategories", label: "All Categories")
            .addTextField(identifier: "allTagsResult", formulaRef: "allTags", label: "All Tags")
            .addTextField(identifier: "allImagesResult", formulaRef: "allImages", label: "All Images")
            .addTextField(identifier: "allDatesResult", formulaRef: "allDates", label: "All Dates")
            .addTextField(identifier: "allDescriptionsResult", formulaRef: "allDescriptions", label: "All Descriptions")
            .addTextField(identifier: "allBarcodesResult", formulaRef: "allBarcodes", label: "All Barcodes")
            .addTextField(identifier: "allSignaturesResult", formulaRef: "allSignatures", label: "All Signatures")
            
            // Add more output fields for all the other formulas...
            .addNumberField(identifier: "totalRowsResult", formulaRef: "totalRows", label: "Total Rows")
            .addNumberField(identifier: "totalPriceResult", formulaRef: "totalPrice", label: "Total Price")
            .addNumberField(identifier: "avgPriceResult", formulaRef: "avgPrice", label: "Average Price")
            .addNumberField(identifier: "maxPriceResult", formulaRef: "maxPrice", label: "Max Price")
            .addNumberField(identifier: "minPriceResult", formulaRef: "minPrice", label: "Min Price")
            .addNumberField(identifier: "priceCountResult", formulaRef: "priceCount", label: "Price Count")
    }

    static func createComprehensiveTableCellResolutionDocument1() -> JoyDoc {
        return JoyDoc.addDocument()
                   .addFormula(id: "basicTextAccess", formula: "products.0.name")
                   .addFormula(id: "basicNumberAccess", formula: "products.0.price")
                   .addFormula(id: "basicDropdownAccess", formula: "products.0.category")
                   .addFormula(id: "basicMultiSelectAccess", formula: "products.0.tags")
                   .addFormula(id: "basicMultiSelectFirstItem", formula: "products.0.tags.0")
                   .addFormula(id: "basicImageAccess", formula: "products.0.images")
                   .addFormula(id: "basicImageFirstItem", formula: "products.0.images.0")
                   .addFormula(id: "basicDateAccess", formula: "products.0.createdDate")
                   .addFormula(id: "basicBlockAccess", formula: "products.0.description")
                   .addFormula(id: "basicBarcodeAccess", formula: "products.0.barcode")
                   .addFormula(id: "basicSignatureAccess", formula: "products.0.signature")
       
                   // STRING FUNCTIONS (as per spec)
                   .addFormula(id: "emptyTextCount", formula: "LENGTH(FILTER(products, (row) -> EMPTY(row.name)))")
                   .addFormula(id: "exactNameMatch", formula: "LENGTH(FILTER(products, (row) -> row.name == \"Laptop\"))")
                   .addFormula(id: "nameContainsJack", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(LOWER(row.name), \"jack\")))")
                   .addFormula(id: "nameLabels", formula: "MAP(products, (row, i) -> CONCAT(row.name, \" (\", TOSTRING(i), \")\"))")
       
                   // MULTISELECT FUNCTIONS (as per spec)
                   .addFormula(id: "hasPopularCount", formula: "LENGTH(FILTER(products, (row) -> SOME(row.tags, (option) -> option == \"Popular\")))")
                   .addFormula(id: "hasAllOptionsCount", formula: "LENGTH(FILTER(products, (row) -> AND(SOME(row.tags, (option) -> option == \"Popular\"), SOME(row.tags, (option) -> option == \"Sale\"), SOME(row.tags, (option) -> option == \"New\"))))")
                   .addFormula(id: "emptyMultiSelectCount", formula: "LENGTH(FILTER(products, (row) -> EMPTY(row.tags)))")
                   .addFormula(id: "flattenedTags", formula: "FLATMAP(products, (row) -> row.tags)")
       
                   // IMAGE FUNCTIONS (as per spec)
                   .addFormula(id: "hasImageCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.images))))")
                   .addFormula(id: "allHaveImages", formula: "EVERY(products, (row) -> NOT(EMPTY(row.images)))")
                   .addFormula(id: "maxImageCount", formula: "MAX(MAP(products, (row) -> LENGTH(row.images)))")
       
                   // NUMBER FUNCTIONS (as per spec)
                   .addFormula(id: "expensiveCount", formula: "LENGTH(FILTER(products, (row) -> row.price > 100))")
                   .addFormula(id: "squaredPrices", formula: "MAP(products, (row) -> POW(row.price, 2))")
                   .addFormula(id: "evenPrices", formula: "MAP(products, (row) -> MOD(row.price, 2) == 0)")
       
                   // DATE FUNCTIONS (as per spec)
                   .addFormula(id: "hasDateCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.createdDate))))")
                   .addFormula(id: "dayGte2Count", formula: "LENGTH(FILTER(products, (row) -> DAY(row.createdDate) >= 2))")
                   .addFormula(id: "extractedDays", formula: "MAP(products, (row) -> DAY(row.createdDate))")
       
                   // BLOCK FUNCTIONS (as per spec)
                   .addFormula(id: "questionCount", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(UPPER(row.description), \"QUESTION\")))")
       
                   // BARCODE FUNCTIONS (as per spec)
                   .addFormula(id: "codeStartsCount", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(row.barcode, \"code\")))")
                   .addFormula(id: "nonEmptyBarcodeCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.barcode))))")
                   .addFormula(id: "scannedLabels", formula: "MAP(products, (row) -> CONCAT(\"SCANNED \", row.barcode))")
                   .addFormula(id: "replaceMissingBarcodes", formula: "MAP(products, (row) -> IF(EMPTY(row.barcode), \"MISSING\", row.barcode))")
       
                   // SIGNATURE FUNCTIONS (as per spec)
                   .addFormula(id: "hasSignatureCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.signature))))")
                   .addFormula(id: "missingSignatureCount", formula: "LENGTH(FILTER(products, (row) -> EMPTY(row.signature)))")
                   .addFormula(id: "allHaveSignatures", formula: "EVERY(products, (row) -> NOT(EMPTY(row.signature)))")
       
                   // Create comprehensive table with ALL column types (as per PDF spec)
                   .addTableField(
                       identifier: "products",
                       columns: [
                           // Text Column
                           {
                               var col = FieldTableColumn()
                               col.id = "name"
                               col.title = "Product Name"
                               col.type = .text
                               col.required = true
                               col.width = 200
                               return col
                           }(),
       
                           // Number Column
                           {
                               var col = FieldTableColumn()
                               col.id = "price"
                               col.title = "Price"
                               col.type = .number
                               col.required = true
                               col.width = 100
                               return col
                           }(),
       
                           // Dropdown Column
                           {
                               var col = FieldTableColumn()
                               col.id = "category"
                               col.title = "Category"
                               col.type = .dropdown
                               col.required = false
                               col.width = 150
       
                               var opt1 = Option()
                               opt1.id = "electronics"
                               opt1.value = "Electronics"
       
                               var opt2 = Option()
                               opt2.id = "clothing"
                               opt2.value = "Clothing"
       
                               var opt3 = Option()
                               opt3.id = "na"
                               opt3.value = "N/A"
       
                               col.options = [opt1, opt2, opt3]
                               return col
                           }(),
       
                           // MultiSelect Column
                           {
                               var col = FieldTableColumn()
                               col.id = "tags"
                               col.title = "Tags"
                               col.type = .multiSelect
                               col.required = false
                               col.width = 200
       
                               var opt1 = Option()
                               opt1.id = "popular"
                               opt1.value = "Popular"
       
                               var opt2 = Option()
                               opt2.id = "sale"
                               opt2.value = "Sale"
       
                               var opt3 = Option()
                               opt3.id = "new"
                               opt3.value = "New"
       
                               col.options = [opt1, opt2, opt3]
                               return col
                           }(),
       
                           // Image Column
                           {
                               var col = FieldTableColumn()
                               col.id = "images"
                               col.title = "Images"
                               col.type = .image
                               col.required = false
                               col.width = 150
                               return col
                           }(),
       
                           // Date Column
                           {
                               var col = FieldTableColumn()
                               col.id = "createdDate"
                               col.title = "Created Date"
                               col.type = .date
                               col.required = false
                               col.width = 120
                               return col
                           }(),
       
                           // Block Column
                           {
                               var col = FieldTableColumn()
                               col.id = "description"
                               col.title = "Description"
                               col.type = .block
                               col.required = false
                               col.width = 250
                               return col
                           }(),
       
                           // Barcode Column
                           {
                               var col = FieldTableColumn()
                               col.id = "barcode"
                               col.title = "Barcode"
                               col.type = .barcode
                               col.required = false
                               col.width = 150
                               return col
                           }(),
       
                           // Signature Column
                           {
                               var col = FieldTableColumn()
                               col.id = "signature"
                               col.title = "Signature"
                               col.type = .signature
                               col.required = false
                               col.width = 150
                               return col
                           }()
                       ],
                       rows: [
                           // Row 1: Comprehensive data (matches PDF spec examples)
                           {
                               var row = ValueElement(id: "row1")
                               row.cells = [
                                   "name": .string("Laptop"),
                                   "price": .double(999.99),
                                   "category": .string("Electronics"),
                                   "tags": .array(["Popular", "Sale"]),
                                   "images": .array(["https://example.com/laptop1.jpg", "https://example.com/laptop2.jpg"]),
                                   "createdDate": .double(1748750400000), // Jan 1, 2025
                                   "description": .string("Question 1: High-performance laptop"),
                                   "barcode": .string("code 1"),
                                   "signature": .string("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==")
                               ]
                               return row
                           }(),
       
                           // Row 2: Mixed data
                           {
                               var row = ValueElement(id: "row2")
                               row.cells = [
                                   "name": .string(""),
                                   "price": .double(29.99),
                                   "category": .string("Clothing"),
                                   "tags": .array(["Popular", "New"]),
                                   "images": .array(["https://example.com/tshirt.jpg"]),
                                   "createdDate": .double(1748836800000), // Jan 2, 2025
                                   "description": .string("Cotton t-shirt"),
                                   "barcode": .string("code with space"),
                                   "signature": .string("") // Empty signature
                               ]
                               return row
                           }(),
       
                           // Row 3: Edge cases (empty values, etc.)
                           {
                               var row = ValueElement(id: "row3")
                               row.cells = [
                                   "name": .string("Jack's Item"),
                                   "price": .double(11),
                                   "category": .string("Electronics"),
                                   "tags": .array(["Popular", "Sale", "New"]), // All three options
                                   "images": .array([]), // No images
                                   "createdDate": .double(1748923200000), // Jan 3, 2025
                                   "description": .string("Question 2: Jack's special item"),
                                   "barcode": .string("code 2"),
                                   "signature": .string("")
                               ]
                               return row
                           }(),
       
                           // Row 4: More edge cases
                           {
                               var row = ValueElement(id: "row4")
                               row.cells = [
                                   "name": .string("Jackie's Product"),
                                   "price": .double(200),
                                   "category": .string(""),
                                   "tags": .array([]), // Empty
                                   "images": .array(["https://example.com/img1.jpg", "https://example.com/img2.jpg", "https://example.com/img3.jpg"]), // 3 images (max)
                                   "createdDate": .double(0), // Empty/null date
                                   "description": .string("Regular description"),
                                   "barcode": .string(""),
                                   "signature": .string("")
                               ]
                               return row
                           }(),
       
                           // Row 5: Final test data
                           {
                               var row = ValueElement(id: "row5")
                               row.cells = [
                                   "name": .string("Test Product"),
                                   "price": .double(3), // For testing equality
                                   "category": .string("N/A"),
                                   "tags": .array([]), // Empty
                                   "images": .array([]), // Empty
                                   "createdDate": .double(1748750400000), // Jan 1, 2025 (same as row 1)
                                   "description": .string("Question 3: Test item"),
                                   "barcode": .string(""),
                                   "signature": .string("data:image/png;base64,signatureData")
                               ]
                               return row
                           }()
                       ]
                   )
       
                   // Add output fields for ALL test cases
                   .addTextField(identifier: "basicTextResult", formulaRef: "basicTextAccess", label: "Basic Text Access")
                   .addNumberField(identifier: "basicNumberResult", formulaRef: "basicNumberAccess", label: "Basic Number Access")
                   .addTextField(identifier: "basicDropdownResult", formulaRef: "basicDropdownAccess", label: "Basic Dropdown Access")
                   .addTextField(identifier: "basicMultiSelectResult", formulaRef: "basicMultiSelectAccess", label: "Basic MultiSelect Access")
                   .addTextField(identifier: "basicMultiSelectFirstResult", formulaRef: "basicMultiSelectFirstItem", label: "Basic MultiSelect First Item")
                   .addTextField(identifier: "basicImageResult", formulaRef: "basicImageAccess", label: "Basic Image Access")
                   .addTextField(identifier: "basicImageFirstResult", formulaRef: "basicImageFirstItem", label: "Basic Image First Item")
                   .addNumberField(identifier: "basicDateResult", formulaRef: "basicDateAccess", label: "Basic Date Access")
                   .addTextField(identifier: "basicBlockResult", formulaRef: "basicBlockAccess", label: "Basic Block Access")
                   .addTextField(identifier: "basicBarcodeResult", formulaRef: "basicBarcodeAccess", label: "Basic Barcode Access")
                   .addTextField(identifier: "basicSignatureResult", formulaRef: "basicSignatureAccess", label: "Basic Signature Access")
       
                   // String function results
                   .addNumberField(identifier: "emptyTextCountResult", formulaRef: "emptyTextCount", label: "Empty Text Count")
                   .addNumberField(identifier: "exactNameMatchResult", formulaRef: "exactNameMatch", label: "Exact Name Match")
                   .addNumberField(identifier: "nameContainsJackResult", formulaRef: "nameContainsJack", label: "Name Contains Jack")
                   .addTextField(identifier: "nameLabelsResult", formulaRef: "nameLabels", label: "Name Labels")
       
                   // MultiSelect function results
                   .addNumberField(identifier: "hasPopularCountResult", formulaRef: "hasPopularCount", label: "Has Popular Count")
                   .addNumberField(identifier: "hasAllOptionsCountResult", formulaRef: "hasAllOptionsCount", label: "Has All Options Count")
                   .addNumberField(identifier: "emptyMultiSelectCountResult", formulaRef: "emptyMultiSelectCount", label: "Empty MultiSelect Count")
                   .addTextField(identifier: "flattenedTagsResult", formulaRef: "flattenedTags", label: "Flattened Tags")
       
                   // Image function results
                   .addNumberField(identifier: "hasImageCountResult", formulaRef: "hasImageCount", label: "Has Image Count")
                   .addTextField(identifier: "allHaveImagesResult", formulaRef: "allHaveImages", label: "All Have Images")
                   .addNumberField(identifier: "maxImageCountResult", formulaRef: "maxImageCount", label: "Max Image Count")
       
                   // Number function results
                   .addNumberField(identifier: "expensiveCountResult", formulaRef: "expensiveCount", label: "Expensive Count")
                   .addTextField(identifier: "squaredPricesResult", formulaRef: "squaredPrices", label: "Squared Prices")
                   .addTextField(identifier: "evenPricesResult", formulaRef: "evenPrices", label: "Even Prices")
       
                   // Date function results
                   .addNumberField(identifier: "hasDateCountResult", formulaRef: "hasDateCount", label: "Has Date Count")
                   .addNumberField(identifier: "dayGte2CountResult", formulaRef: "dayGte2Count", label: "Day >= 2 Count")
                   .addTextField(identifier: "extractedDaysResult", formulaRef: "extractedDays", label: "Extracted Days")
       
                   // Block function results
                   .addNumberField(identifier: "questionCountResult", formulaRef: "questionCount", label: "Question Count")
       
                   // Barcode function results
                   .addNumberField(identifier: "codeStartsCountResult", formulaRef: "codeStartsCount", label: "Code Starts Count")
                   .addNumberField(identifier: "nonEmptyBarcodeCountResult", formulaRef: "nonEmptyBarcodeCount", label: "Non-Empty Barcode Count")
                   .addTextField(identifier: "scannedLabelsResult", formulaRef: "scannedLabels", label: "Scanned Labels")
                   .addTextField(identifier: "replaceMissingBarcodesResult", formulaRef: "replaceMissingBarcodes", label: "Replace Missing Barcodes")
       
                   // Signature function results
                   .addNumberField(identifier: "hasSignatureCountResult", formulaRef: "hasSignatureCount", label: "Has Signature Count")
                   .addNumberField(identifier: "missingSignatureCountResult", formulaRef: "missingSignatureCount", label: "Missing Signature Count")
                   .addTextField(identifier: "allHaveSignaturesResult", formulaRef: "allHaveSignatures", label: "All Have Signatures")

    }

    static func cellResolution() -> JoyDoc {
        return JoyDoc.addDocument()
        // BASIC ACCESS PATTERNS - All column types from spec
            .addFormula(id: "basicTextAccess", formula: "products.0.name")
            .addFormula(id: "basicNumberAccess", formula: "products.0.price")
            .addFormula(id: "basicDropdownAccess", formula: "products.0.category")
            .addFormula(id: "basicMultiSelectAccess", formula: "products.0.tags")
            .addFormula(id: "basicMultiSelectFirstItem", formula: "products.0.tags.0")
            .addFormula(id: "basicImageAccess", formula: "products.0.images")
            .addFormula(id: "basicImageFirstItem", formula: "products.0.images.0")
            .addFormula(id: "basicDateAccess", formula: "products.0.createdDate")
            .addFormula(id: "basicBlockAccess", formula: "products.0.description")
            .addFormula(id: "basicBarcodeAccess", formula: "products.0.barcode")
            .addFormula(id: "basicSignatureAccess", formula: "products.0.signature")
        
        // AGGREGATE FUNCTIONS
            .addFormula(id: "tableRowCount", formula: "COUNT(products)")
            .addFormula(id: "totalPrice", formula: "SUM(products.price)")
            .addFormula(id: "avgPrice", formula: "AVERAGE(products.price)")
            .addFormula(id: "maxPrice", formula: "MAX(products.price)")
            .addFormula(id: "minPrice", formula: "MIN(products.price)")
        
        // STRING FUNCTIONS (from spec)
            .addFormula(id: "emptyTextCount", formula: "LENGTH(FILTER(products, (row) -> EMPTY(row.name)))")
            .addFormula(id: "exactNameMatch", formula: "LENGTH(FILTER(products, (row) -> row.name == \"Laptop\"))")
            .addFormula(id: "nameContainsJack", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(LOWER(row.name), \"jack\")))")
            .addFormula(id: "nameLabels", formula: "MAP(products, (row, i) -> CONCAT(row.name, \" (\", TOSTRING(i), \")\"))")
        
        // MULTISELECT FUNCTIONS (from spec)
            .addFormula(id: "hasPopularCount", formula: "LENGTH(FILTER(products, (row) -> SOME(row.tags, (option) -> option == \"Popular\")))")
            .addFormula(id: "hasAllOptionsCount", formula: "LENGTH(FILTER(products, (row) -> AND(SOME(row.tags, (option) -> option == \"Popular\"), SOME(row.tags, (option) -> option == \"Sale\"), SOME(row.tags, (option) -> option == \"New\"))))")
            .addFormula(id: "flattenedTags", formula: "FLATMAP(products, (row) -> row.tags)")
        
        // IMAGE FUNCTIONS (from spec)
            .addFormula(id: "hasImageCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.images))))")
            .addFormula(id: "maxImageCount", formula: "MAX(MAP(products, (row) -> LENGTH(row.images)))")
        
        // NUMBER FUNCTIONS (from spec)
            .addFormula(id: "expensiveCount", formula: "LENGTH(FILTER(products, (row) -> row.price > 100))")
            .addFormula(id: "squaredPrices", formula: "MAP(products, (row) -> POW(row.price, 2))")
            .addFormula(id: "evenPrices", formula: "MAP(products, (row) -> MOD(row.price, 2) == 0)")
        
        // DATE FUNCTIONS (from spec)
            .addFormula(id: "hasDateCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.createdDate))))")
            .addFormula(id: "dayGte2Count", formula: "LENGTH(FILTER(products, (row) -> DAY(row.createdDate) >= 2))")
            .addFormula(id: "extractedDays", formula: "MAP(products, (row) -> DAY(row.createdDate))")
        
        // BLOCK FUNCTIONS (from spec)
            .addFormula(id: "questionCount", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(UPPER(row.description), \"QUESTION\")))")
        
        // BARCODE FUNCTIONS (from spec)
            .addFormula(id: "codeStartsCount", formula: "LENGTH(FILTER(products, (row) -> CONTAINS(row.barcode, \"code\")))")
            .addFormula(id: "scannedLabels", formula: "MAP(products, (row) -> CONCAT(\"SCANNED \", row.barcode))")
            .addFormula(id: "replaceMissingBarcodes", formula: "MAP(products, (row) -> IF(EMPTY(row.barcode), \"MISSING\", row.barcode))")
        
        // SIGNATURE FUNCTIONS (from spec)
            .addFormula(id: "hasSignatureCount", formula: "LENGTH(FILTER(products, (row) -> NOT(EMPTY(row.signature))))")
            .addFormula(id: "allHaveSignatures", formula: "EVERY(products, (row) -> NOT(EMPTY(row.signature)))")
        
        // OPERATORS (from spec)
            .addFormula(id: "addTen", formula: "MAP(products, (row) -> row.price + 10)")
            .addFormula(id: "multiplyBySelf", formula: "MAP(products, (row) -> row.price * row.price)")
            .addFormula(id: "equalToThree", formula: "MAP(products, (row) -> row.price == 3)")
            .addFormula(id: "greaterThanTen", formula: "MAP(products, (row) -> row.price > 10)")
        
        // Create comprehensive table with ALL column types
            .addTableField(
                identifier: "products",
                columns: [
                    // Text Column
                    {
                        var col = FieldTableColumn()
                        col.id = "name"
                        col.title = "Product Name"
                        col.type = .text
                        col.required = true
                        col.width = 200
                        return col
                    }(),
                    
                    // Number Column
                    {
                        var col = FieldTableColumn()
                        col.id = "price"
                        col.title = "Price"
                        col.type = .number
                        col.required = true
                        col.width = 100
                        return col
                    }(),
                    
                    // Dropdown Column
                    {
                        var col = FieldTableColumn()
                        col.id = "category"
                        col.title = "Category"
                        col.type = .dropdown
                        col.required = false
                        col.width = 150
                        
                        var opt1 = Option()
                        opt1.id = "electronics"
                        opt1.value = "Electronics"
                        
                        var opt2 = Option()
                        opt2.id = "clothing"
                        opt2.value = "Clothing"
                        
                        var opt3 = Option()
                        opt3.id = "na"
                        opt3.value = "N/A"
                        
                        col.options = [opt1, opt2, opt3]
                        return col
                    }(),
                    
                    // MultiSelect Column
                    {
                        var col = FieldTableColumn()
                        col.id = "tags"
                        col.title = "Tags"
                        col.type = .multiSelect
                        col.required = false
                        col.width = 200
                        
                        var opt1 = Option()
                        opt1.id = "popular"
                        opt1.value = "Popular"
                        
                        var opt2 = Option()
                        opt2.id = "sale"
                        opt2.value = "Sale"
                        
                        var opt3 = Option()
                        opt3.id = "new"
                        opt3.value = "New"
                        
                        col.options = [opt1, opt2, opt3]
                        return col
                    }(),
                    
                    // Image Column
                    {
                        var col = FieldTableColumn()
                        col.id = "images"
                        col.title = "Images"
                        col.type = .image
                        col.required = false
                        col.width = 150
                        return col
                    }(),
                    
                    // Date Column
                    {
                        var col = FieldTableColumn()
                        col.id = "createdDate"
                        col.title = "Created Date"
                        col.type = .date
                        col.required = false
                        col.width = 120
                        return col
                    }(),
                    
                    // Block Column
                    {
                        var col = FieldTableColumn()
                        col.id = "description"
                        col.title = "Description"
                        col.type = .block
                        col.required = false
                        col.width = 250
                        return col
                    }(),
                    
                    // Barcode Column
                    {
                        var col = FieldTableColumn()
                        col.id = "barcode"
                        col.title = "Barcode"
                        col.type = .barcode
                        col.required = false
                        col.width = 150
                        return col
                    }(),
                    
                    // Signature Column
                    {
                        var col = FieldTableColumn()
                        col.id = "signature"
                        col.title = "Signature"
                        col.type = .signature
                        col.required = false
                        col.width = 150
                        return col
                    }()
                ],
                rows: [
                    // Row 1: Comprehensive data (matches PDF spec examples)
                    {
                        var row = ValueElement(id: "row1")
                        row.cells = [
                            "name": .string("Laptop"),
                            "price": .double(999.99),
                            "category": .string("Electronics"),
                            "tags": .array(["Popular", "Sale"]),
                            "images": .array(["https://example.com/laptop1.jpg", "https://example.com/laptop2.jpg"]),
                            "createdDate": .double(1748750400000), // Jan 1, 2025
                            "description": .string("Question 1: High-performance laptop"),
                            "barcode": .string("code 1"),
                            "signature": .string("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==")
                        ]
                        return row
                    }(),
                    
                    // Row 2: Mixed data
                    {
                        var row = ValueElement(id: "row2")
                        row.cells = [
                            "name": .string(""),
                            "price": .double(29.99),
                            "category": .string("Clothing"),
                            "tags": .array(["Popular", "New"]),
                            "images": .array(["https://example.com/tshirt.jpg"]),
                            "createdDate": .double(1748836800000), // Jan 2, 2025
                            "description": .string("Cotton t-shirt"),
                            "barcode": .string("code with space"),
                            "signature": .string("") // Empty signature
                        ]
                        return row
                    }(),
                    
                    // Row 3: Edge cases
                    {
                        var row = ValueElement(id: "row3")
                        row.cells = [
                            "name": .string("Jack's Item"),
                            "price": .double(11),
                            "category": .string("Electronics"),
                            "tags": .array(["Popular", "Sale", "New"]), // All three options
                            "images": .array([]), // No images
                            "createdDate": .double(1748923200000), // Jan 3, 2025
                            "description": .string("Question 2: Jack's special item"),
                            "barcode": .string("code 2"),
                            "signature": .string("")
                        ]
                        return row
                    }(),
                    
                    // Row 4: More edge cases
                    {
                        var row = ValueElement(id: "row4")
                        row.cells = [
                            "name": .string("Jackie's Product"),
                            "price": .double(200),
                            "category": .string(""),
                            "tags": .array([]), // Empty
                            "images": .array(["https://example.com/img1.jpg", "https://example.com/img2.jpg", "https://example.com/img3.jpg"]), // 3 images (max)
                            "createdDate": .double(0), // Empty/null date
                            "description": .string("Regular description"),
                            "barcode": .string(""),
                            "signature": .string("")
                        ]
                        return row
                    }(),
                    
                    // Row 5: Final test data
                    {
                        var row = ValueElement(id: "row5")
                        row.cells = [
                            "name": .string("Test Product"),
                            "price": .double(3), // For testing equality
                            "category": .string("N/A"),
                            "tags": .array([]), // Empty
                            "images": .array([]), // Empty
                            "createdDate": .double(1748750400000), // Jan 1, 2025 (same as row 1)
                            "description": .string("Question 3: Test item"),
                            "barcode": .string(""),
                            "signature": .string("data:image/png;base64,signatureData")
                        ]
                        return row
                    }()
                ]
            )
        
        // Add output fields for ALL test cases
            .addTextField(identifier: "basicTextResult", formulaRef: "basicTextAccess", label: "Basic Text Access")
            .addNumberField(identifier: "basicNumberResult", formulaRef: "basicNumberAccess", label: "Basic Number Access")
            .addTextField(identifier: "basicDropdownResult", formulaRef: "basicDropdownAccess", label: "Basic Dropdown Access")
            .addTextField(identifier: "basicMultiSelectResult", formulaRef: "basicMultiSelectAccess", label: "Basic MultiSelect Access")
            .addTextField(identifier: "basicMultiSelectFirstResult", formulaRef: "basicMultiSelectFirstItem", label: "Basic MultiSelect First Item")
            .addTextField(identifier: "basicImageResult", formulaRef: "basicImageAccess", label: "Basic Image Access")
            .addTextField(identifier: "basicImageFirstResult", formulaRef: "basicImageFirstItem", label: "Basic Image First Item")
            .addNumberField(identifier: "basicDateResult", formulaRef: "basicDateAccess", label: "Basic Date Access")
            .addTextField(identifier: "basicBlockResult", formulaRef: "basicBlockAccess", label: "Basic Block Access")
            .addTextField(identifier: "basicBarcodeResult", formulaRef: "basicBarcodeAccess", label: "Basic Barcode Access")
            .addTextField(identifier: "basicSignatureResult", formulaRef: "basicSignatureAccess", label: "Basic Signature Access")
        
        // Aggregate results
            .addNumberField(identifier: "rowCount", formulaRef: "tableRowCount", label: "Total Rows")
            .addNumberField(identifier: "totalPriceResult", formulaRef: "totalPrice", label: "Total Price")
            .addNumberField(identifier: "avgPriceResult", formulaRef: "avgPrice", label: "Average Price")
            .addNumberField(identifier: "maxPriceResult", formulaRef: "maxPrice", label: "Max Price")
            .addNumberField(identifier: "minPriceResult", formulaRef: "minPrice", label: "Min Price")
        
        // String function results
            .addNumberField(identifier: "emptyTextCountResult", formulaRef: "emptyTextCount", label: "Empty Text Count")
            .addNumberField(identifier: "exactNameMatchResult", formulaRef: "exactNameMatch", label: "Exact Name Match")
            .addNumberField(identifier: "nameContainsJackResult", formulaRef: "nameContainsJack", label: "Name Contains Jack")
            .addTextField(identifier: "nameLabelsResult", formulaRef: "nameLabels", label: "Name Labels")
        
        // MultiSelect function results
            .addNumberField(identifier: "hasPopularCountResult", formulaRef: "hasPopularCount", label: "Has Popular Count")
            .addNumberField(identifier: "hasAllOptionsCountResult", formulaRef: "hasAllOptionsCount", label: "Has All Options Count")
            .addTextField(identifier: "flattenedTagsResult", formulaRef: "flattenedTags", label: "Flattened Tags")
        
        // Image function results
            .addNumberField(identifier: "hasImageCountResult", formulaRef: "hasImageCount", label: "Has Image Count")
            .addNumberField(identifier: "maxImageCountResult", formulaRef: "maxImageCount", label: "Max Image Count")
        
        // Number function results
            .addNumberField(identifier: "expensiveCountResult", formulaRef: "expensiveCount", label: "Expensive Count")
            .addTextField(identifier: "squaredPricesResult", formulaRef: "squaredPrices", label: "Squared Prices")
            .addTextField(identifier: "evenPricesResult", formulaRef: "evenPrices", label: "Even Prices")
        
        // Date function results
            .addNumberField(identifier: "hasDateCountResult", formulaRef: "hasDateCount", label: "Has Date Count")
            .addNumberField(identifier: "dayGte2CountResult", formulaRef: "dayGte2Count", label: "Day >= 2 Count")
            .addTextField(identifier: "extractedDaysResult", formulaRef: "extractedDays", label: "Extracted Days")
        
        // Block function results
            .addNumberField(identifier: "questionCountResult", formulaRef: "questionCount", label: "Question Count")
        
        // Barcode function results
            .addNumberField(identifier: "codeStartsCountResult", formulaRef: "codeStartsCount", label: "Code Starts Count")
            .addTextField(identifier: "scannedLabelsResult", formulaRef: "scannedLabels", label: "Scanned Labels")
            .addTextField(identifier: "replaceMissingBarcodesResult", formulaRef: "replaceMissingBarcodes", label: "Replace Missing Barcodes")
        
        // Signature function results
            .addNumberField(identifier: "hasSignatureCountResult", formulaRef: "hasSignatureCount", label: "Has Signature Count")
            .addTextField(identifier: "allHaveSignaturesResult", formulaRef: "allHaveSignatures", label: "All Have Signatures")
        
        // Operator results
            .addTextField(identifier: "addTenResult", formulaRef: "addTen", label: "Add Ten")
            .addTextField(identifier: "multiplyBySelfResult", formulaRef: "multiplyBySelf", label: "Multiply By Self")
            .addTextField(identifier: "equalToThreeResult", formulaRef: "equalToThree", label: "Equal To Three")
            .addTextField(identifier: "greaterThanTenResult", formulaRef: "greaterThanTen", label: "Greater Than Ten")
        
    }
}
