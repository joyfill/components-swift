import Foundation
/// Represents a Joy document.
///
/// Use the `JoyDoc` struct to create and manipulate Joy documents.
public struct JoyDoc {
    /// A structure representing a Joy document.
    /// The dictionary representation of the Joy document.
    public var dictionary: [String: Any]
    
    /// Initializes a new Joy document with the given dictionary.
    /// - Parameter dictionary: The dictionary representation of the Joy document. Default value is an empty dictionary.
    public init(dictionary: [String: Any] = [:]) {
        self.dictionary = dictionary
    }
    
    /// The unique identifier of the Joy document.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }
    
    /// The type of the Joy document.
    public var type: String? {
        get { dictionary["type"] as? String }
        set { dictionary["type"] = newValue }
    }
    
    /// The stage of the Joy document.
    public var stage: String? {
        get { dictionary["stage"] as? String }
        set { dictionary["stage"] = newValue }
    }
    
    /// The source of the Joy document.
    public var source: String? {
        get { dictionary["source"] as? String }
        set { dictionary["source"] = newValue }
    }
    
    /// The identifier of the Joy document.
    public var identifier: String? {
        get { dictionary["identifier"] as? String }
        set { dictionary["identifier"] = newValue }
    }
    
    /// The name of the Joy document.
    public var name: String? {
        get { dictionary["name"] as? String }
        set { dictionary["name"] = newValue }
    }
    
    /// The creation timestamp of the Joy document.
    public var createdOn: Int? {
        get { dictionary["createdOn"] as? Int }
        set { dictionary["createdOn"] = newValue }
    }

    /// The metadata of the Joy document.
    public var metadata: Metadata? {
        get { Metadata.init(dictionary: dictionary["metadata"] as? [String: Any])}
        set { dictionary["metadata"] = newValue?.dictionary }
    }
    
    /// The files associated with the Joy document.
    public var files: [File] {
        get { (dictionary["files"] as? [[String: Any]])?.compactMap(File.init) ?? [] }
        set { dictionary["files"] = newValue.compactMap { $0.dictionary } }
    }
    
    /// The fields of the Joy document.
    public var fields: [JoyDocField] {
        get { (dictionary["fields"] as? [[String: Any]])?.compactMap(JoyDocField.init) ?? [] }
        set { dictionary["fields"] = newValue.compactMap { $0.dictionary } }
    }
    
    /// The categories associated with the Joy document.
    ///
    /// Use this property to get or set the categories of the Joy document.
    public var categories: [JSONAny]? {
        mutating get { getValue(key: "categories") }
        mutating set { setValue(newValue, key: "categories") }
    }
    
    /// A flag indicating whether the Joy document is deleted or not.
    public var deleted: Bool? {
        get { dictionary["deleted"] as? Bool }
        set { dictionary["deleted"] = newValue }
    }
    
    public var pages: [Page] {
        get {
            if let views = self.files[0].views, !views.isEmpty, let view = views.first {
                if let pages = view.pages {
                    return pages
                }
            } else {
                if let pages = self.files[0].pages {
                    return pages
                }
            }
            return []
        }
        set {
            if var views = self.files[0].views, !views.isEmpty {
                views[0].pages = newValue
                self.files[0].views = views
            } else {
                self.files[0].pages = newValue
            }
        }
    }
    
    public var firstPage: Page? {
        guard let pages = self.files[0].pages, pages.count > 1 else {
            return self.files[0].pages?.first
        }
        return (self.files[0].pages?.first(where: { currentPage in
            DocumentEngine.shouldShowItem(fields: self.fields, logic: currentPage.logic, isItemHidden: currentPage.hidden)
        }))
    }
    
    public var firstPageId: String? {
        return self.firstPage?.id
    }

    public func firstValidPageFor(currentPageID: String) -> Page? {
        return pages.first { currentPage in
            currentPage.id == currentPageID &&
            DocumentEngine.shouldShowItem(fields: self.fields, logic: currentPage.logic, isItemHidden: currentPage.hidden)
        } ?? firstPage
    }

    public func firstPageFor(currentPageID: String) -> Page? {
        return pages.first { currentPage in
            currentPage.id == currentPageID &&
            DocumentEngine.shouldShowItem(fields: self.fields, logic: currentPage.logic, isItemHidden: currentPage.hidden)
        }
    }
}

extension JoyDoc {
    /// Sets the value for a given key in the Joy document dictionary.
    ///
    /// - Parameters:
    ///   - value: The value to be set. This value should be an array of `JSONAny` objects.
    ///   - key: The key for which the value should be set.
    mutating private func setValue(_ value: [JSONAny]?, key: String) {
        guard let value = value else {
            return
        }
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        self.dictionary[key] = try? JSONDecoder().decode(JSONAny.self, from: data)
    }
    
    /// Retrieves the value for a given key from the Joy document dictionary.
    ///
    /// - Parameter key: The key for which the value should be retrieved.
    /// - Returns: The value associated with the given key, or `nil` if the key does not exist or the value cannot be decoded.
    mutating private func getValue(key: String) -> [JSONAny]? {
        guard let value = dictionary[key] as? [String: Any] else {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            return nil
        }
        return try? JSONDecoder().decode([JSONAny].self, from: data)
    }
}

// MARK: - File
/// Represents a file.
///
/// Use the `File` struct to work with file objects. It provides a dictionary representation of the file.
public struct File {
    /// The dictionary representation of the file.
    public var dictionary: [String: Any]

    /// Initializes a new instance of the `File` struct.
    /// - Parameter dictionary: The dictionary representation of the file. Default value is an empty dictionary.
    public init(dictionary: [String: Any] = [:]) {
        self.dictionary = dictionary
    }

    /// The ID of the file.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }

    /// The metadata of the file.
    public var metadata: Metadata? {
        get { Metadata.init(dictionary: dictionary["metadata"] as? [String: Any])}
        set { dictionary["metadata"] = newValue?.dictionary }
    }

    /// The name of the file.
    public var name: String? {
        get { dictionary["name"] as? String }
        set { dictionary["name"] = newValue }
    }

    /// The version of the file.
    public var version: Int? {
        get { dictionary["version"] as? Int }
        set { dictionary["version"] = newValue }
    }

    /// The styles metadata of the file.
    public var styles: Metadata? {
        get { Metadata.init(dictionary: dictionary["styles"] as? [String: Any])}
        set { dictionary["styles"] = newValue?.dictionary }
    }

    /// The pages of the file.
    public var pages: [Page]? {
        get { (dictionary["pages"] as? [[String: Any]])?.compactMap(Page.init) }
        set { dictionary["pages"] = newValue?.compactMap{ $0.dictionary } }
    }

    /// The order of the pages in the file.
    public var pageOrder: [String]? {
        get { dictionary["pageOrder"] as? [String] }
        set { dictionary["pageOrder"] = newValue }
    }

    /// The views of the file.
    public var views: [ModelView]? {
        get { (dictionary["views"] as? [[String: Any]])?.compactMap(ModelView.init) ?? [] }
        set { dictionary["views"] = newValue?.compactMap{ $0.dictionary } }
    }
}

// MARK: - JoyDocField
/// Represents a field in a Joy document.
public struct JoyDocField: Equatable {
    public static func == (lhs: JoyDocField, rhs: JoyDocField) -> Bool {
        lhs.id == rhs.id
    }
    public var dictionary: [String: Any]
    
    public init(field: [String: Any] = [:]) {
        self.dictionary = field
    }
    /// The type of the field.
    public var type: String? {
        get { dictionary["type"] as? String }
        set { dictionary["type"] = newValue }
    }

    /// The type of the field.
    public var fieldType: FieldTypes {
        get { FieldTypes(rawValue: dictionary["type"] as! String)! }
        set { dictionary["type"] = newValue.rawValue }
    }

    /// The ID of the field.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }
    
    /// The identifier of the field.
    public var identifier: String? {
        get { dictionary["identifier"] as? String }
        set { dictionary["identifier"] = newValue }
    }
    
    /// The title of the field.
    public var title: String? {
        get { dictionary["title"] as? String }
        set { dictionary["title"] = newValue }
    }
    
    /// The description of the field.
    public var description: String? {
        get { dictionary["description"] as? String }
        set { dictionary["description"] = newValue }
    }
    
    /// The value of the field.
    public var value: ValueUnion? {
        get { ValueUnion.init(valueFromDcitonary: dictionary)}
        set { dictionary["value"] = newValue?.dictionary }
    }
    
    /// Indicates if the field is required.
    public var required: Bool? {
        get { dictionary["required"] as? Bool }
        set { dictionary["required"] = newValue }
    }
    
    /// Indicates if the field is disabled.
    public var disabled: Bool? {
        get { dictionary["disabled"] as? Bool }
        set { dictionary["disabled"] = newValue }
    }
    
    /// The metadata of the field.
    public var metadata: Metadata? {
        get { Metadata.init(dictionary: dictionary["metadata"] as? [String: Any])}
        set { dictionary["metadata"] = newValue?.dictionary }
    }
    
    /// The file associated with the field.
    public var file: String? {
        get { dictionary["file"] as? String }
        set { dictionary["file"] = newValue }
    }
    
    /// The options array available for the field.
    public var options: [Option]? {
        get { (dictionary["options"] as? [[String: Any]])?.compactMap(Option.init) ?? [] }
        set { dictionary["options"] = newValue?.compactMap{ $0.dictionary } }
    }
    
    /// The title of the tip for the field.
    public var tipTitle: String? {
        get { dictionary["tipTitle"] as? String }
        set { dictionary["tipTitle"] = newValue }
    }
    
    /// The description of the tip for the field.
    public var tipDescription: String? {
        get { dictionary["tipDescription"] as? String }
        set { dictionary["tipDescription"] = newValue }
    }
    
    /// Indicates if the tip for the field is visible.
    public var tipVisible: Bool? {
        get { dictionary["tipVisible"] as? Bool }
        set { dictionary["tipVisible"] = newValue }
    }
    
    public var logic: Logic? {
        get { Logic.init(field: dictionary["logic"] as? [String: Any]) }
        set {
            dictionary["logic"] = newValue?.dictionary
        }
    }
    
    public var hidden: Bool? {
        get { dictionary["hidden"] as? Bool }
        set { dictionary["hidden"] = newValue }
    }
    
    
    /// A Boolean property that indicates whether the field supports multiple values.
    ///
    /// If `multi` is set to `true`, the field allows multiple functionalities such as:
    /// - Uploading multiple images at once.
    /// - Selecting multiple options in a multi-select field.
    ///
    /// The default value is `false`.
    ///
    /// Usage:
    /// ```
    /// var field = Field()
    /// field.multi = true
    /// ```
    ///
    /// - Note: The actual behavior and usage of this property may vary depending on the context in which it's used.
    public var multi: Bool? {
        get { dictionary["multi"] as? Bool }
        set { dictionary["multi"] = newValue }
    }
    
    /// The title of the y-axis for the chart field.
    public var yTitle: String? {
        get { dictionary["yTitle"] as? String }
        set { dictionary["yTitle"] = newValue }
    }
    
    /// The maximum value of the y-axis for the chart field.
    public var yMax: Int? {
        get { dictionary["yMax"] as? Int }
        set { dictionary["yMax"] = newValue }
    }
    
    /// The minimum value of the y-axis for the chart field.
    public var yMin: Int? {
        get { dictionary["yMin"] as? Int }
        set { dictionary["yMin"] = newValue }
    }
    
    /// The title of the x-axis for the chart field.
    public var xTitle: String? {
        get { dictionary["xTitle"] as? String }
        set { dictionary["xTitle"] = newValue }
    }
    
    /// The maximum value of the x-axis for the chart field.
    public var xMax: Int? {
        get { dictionary["xMax"] as? Int }
        set { dictionary["xMax"] = newValue }
    }
    
    /// The minimum value of the x-axis for the chart field.
    public var xMin: Int? {
        get { dictionary["xMin"] as? Int }
        set { dictionary["xMin"] = newValue }
    }
    
    /// The order of the rows in the table field.
    public var rowOrder: [String]? {
        get { dictionary["rowOrder"] as? [String] }
        set { dictionary["rowOrder"] = newValue }
    }
    
    /// The columns of the field in a table.
    public var tableColumns: [FieldTableColumn]? {
        get { (dictionary["tableColumns"] as? [[String: Any]])?.compactMap(FieldTableColumn.init) ?? [] }
        set { dictionary["tableColumns"] = newValue?.compactMap{ $0.dictionary } }
    }
    
    /// The order of the columns in the field table.
    public var tableColumnOrder: [String]? {
        get { dictionary["tableColumnOrder"] as? [String] }
        set { dictionary["tableColumnOrder"] = newValue }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case id = "_id"
        case identifier, title, value
        case fieldRequired = "required"
        case disabled, metadata, file, options, multi, yTitle, yMax, yMin, xTitle, xMax, xMin, rowOrder, tableColumns, tableColumnOrder
        case tipTitle, tipDescription, tipVisible
    }
    
    /// Returns the value of the field as an array of `ValueElement` objects.
    public var valueToValueElements: [ValueElement]? {
        switch value {
        case .valueElementArray(let array):
            return array
        default:
            return nil
        }
    }
    
    /// Deletes a row with the specified ID from the table field.
    public mutating func deleteRow(id: String) {
        guard var elements = valueToValueElements, let index = elements.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var element = elements[index]
        element.setDeleted()
        elements[index] = element
        
        self.value = ValueUnion.valueElementArray(elements)
    }

    /// Deletes a row with the specified ID from the table field.
    public mutating func duplicateRow(selectedRows: [String]) -> [TargerRowModel] {
        guard var elements = valueToValueElements else {
            return []
        }
        var targetRows = [TargerRowModel]()
        var lastRowOrder = self.rowOrder ?? []

        selectedRows.forEach { rowID in
            var element = elements.first(where: { $0.id == rowID })!
            let newRowID = generateObjectId()
            element.id = newRowID
            elements.append(element)
            let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!
            lastRowOrder.insert(newRowID, at: lastRowIndex+1)
            targetRows.append(TargerRowModel(id: newRowID, index: lastRowIndex+1))
        }

        self.value = ValueUnion.valueElementArray(elements)
        self.rowOrder = lastRowOrder
        return targetRows
    }

    /// Adds a new row with the specified ID to the table field.
    public mutating func addRow(id: String) {
        var elements = valueToValueElements ?? []
        
        elements.append(ValueElement(id: id))
        self.value = ValueUnion.valueElementArray(elements)
        rowOrder?.append(id)
    }

    /// Adds a new row with the specified ID to the table field.
    public mutating func addRowWithFilter(id: String, filterModels: [FilterModel]) {
        var elements = valueToValueElements ?? []
        var newRow = ValueElement(id: id)
        elements.append(newRow)
        self.value = ValueUnion.valueElementArray(elements)
        rowOrder?.append(id)
        for filterModel in filterModels {
            cellDidChange(rowId: id, colIndex: filterModel.colIndex, editedCellId: filterModel.colID, value: filterModel.filterText)
        }
    }

    /// A function that updates the cell value when a change is detected.
    ///
    /// This function is called when a cell's value is edited. It updates the corresponding cell in the `elements` array based on the `rowId` and `colIndex` provided. The type of the `editedCell` determines how the cell is updated.
    ///
    /// - Parameters:
    ///   - rowId: The ID of the row containing the cell to be updated.
    ///   - colIndex: The index of the column containing the cell to be updated.
    ///   - editedCell: The cell that has been edited.
    ///
    /// - Note: The `editedCell` parameter is of type `FieldTableColumn`, which includes properties such as `type`, `id`, `title`, `defaultDropdownSelectedId`, and `images`.
    public mutating func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumn) {
        guard var elements = valueToValueElements, let index = elements.firstIndex(where: { $0.id == rowId }) else {
            return
        }
        
        switch editedCell.type {
        case "text":
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.string(editedCell.title ?? ""))
        case "dropdown":
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.string(editedCell.defaultDropdownSelectedId ?? ""))
        case "image":
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.valueElementArray(editedCell.images ?? []))
        default:
            return
        }
    }

    public mutating func cellDidChange(rowId: String, colIndex: Int, editedCellId: String, value: String) {
        guard var elements = valueToValueElements, let index = elements.firstIndex(where: { $0.id == rowId }) else {
            return
        }

        changeCell(elements: elements, index: index, editedCellId: editedCellId, newCell: ValueUnion.string(value))
    }

    /// A private function that updates the cell value in the elements array.
    ///
    /// This function is called when a cell's value is edited. It updates the corresponding cell in the `elements` array based on the `index` and `editedCellId` provided. The new cell value is determined by the `newCell` parameter.
    ///
    /// - Parameters:
    ///   - elements: The array of `ValueElement` objects containing the cells to be updated.
    ///   - index: The index of the element in the array to be updated.
    ///   - editedCellId: The ID of the cell to be updated.
    ///   - newCell: The new value for the cell.
    ///
    /// - Note: After updating the cell, the function updates the `value` property of the instance with the new `elements` array.
    private mutating func changeCell(elements: [ValueElement], index: Int, editedCellId: String?, newCell: ValueUnion) {
        var elements = elements
        if var cells = elements[index].cells {
            cells[editedCellId ?? ""] = newCell
            elements[index].cells = cells
        } else {
            elements[index].cells = [editedCellId ?? "" : newCell]
        }
        
        self.value = ValueUnion.valueElementArray(elements)
    }
    
}

public struct Logic: Equatable{
    public static func == (lhs: Logic, rhs: Logic) -> Bool {
        lhs.id == rhs.id
    }
    
    public var dictionary: [String: Any]
    
    public init?(field: [String: Any]?) {
        guard let field = field else {
            return nil
        }
        self.dictionary = field
    }
    
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }

    public var action: String? {
        get { dictionary["action"] as? String }
        set { dictionary["action"] = newValue }
    }
    
    public var eval: String? {
        get { dictionary["eval"] as? String }
        set { dictionary["eval"] = newValue }
    }

    public var conditions: [Condition]? {
        get { (dictionary["conditions"] as? [[String: Any]])?.compactMap(Condition.init) ?? [] }
        set { dictionary["conditions"] = newValue?.compactMap { $0.dictionary } }
    }

    public func isValid(conditionsResults: [Bool]) -> Bool {
        if eval == "and" {
            if conditionsResults.andConditionIsTrue {
                return true
            }
        }  else {
            if conditionsResults.orConditionIsTrue {
                return true
            } 
        }
        return false
    }
}

public struct Condition: Equatable{
    public static func == (lhs: Condition, rhs: Condition) -> Bool {
        lhs.id == rhs.id
    }
    
    public var dictionary: [String: Any]
    

    public init?(field: [String: Any]?) {
        guard let field = field else {
            return nil
        }
        self.dictionary = field
    }
    
    public var id: String?{
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }
    
    public var file: String? {
        get { dictionary["file"] as? String }
        set { dictionary["file"] = newValue }
    }
    
    public var page: String? {
        get { dictionary["page"] as? String }
        set { dictionary["page"] = newValue }
    }
    
    public var field: String? {
        get { dictionary["field"] as? String }
        set { dictionary["field"] = newValue }
    }
    
    public var condition: String? {
        get { dictionary["condition"] as? String }
        set { dictionary["condition"] = newValue }
    }

    public var value: ValueUnion? {
        get { ValueUnion.init(valueFromDcitonary: dictionary)}
        set { dictionary["value"] = newValue?.dictionary }
    }
}

/// Represents the configuration for a chart axis.
public struct ChartAxisConfiguration: Equatable{
    /// The title of the y-axis.
    public var yTitle: String?
    /// The maximum value of the y-axis.
    public var yMax, yMin: Int?
    /// The title of the x-axis.
    public var xTitle: String?
    /// The maximum value of the x-axis.
    public var xMax, xMin: Int?

    enum CodingKeys: String, CodingKey {
        case yTitle, yMax, yMin, xTitle, xMax, xMin
    }

    /// Initializes a new `ChartAxisConfiguration` object.
    public init(yTitle: String? = nil, yMax: Int? = nil, yMin: Int? = nil, xTitle: String? = nil, xMax: Int? = nil, xMin: Int? = nil) {
        self.yTitle = yTitle
        self.yMax = yMax
        self.yMin = yMin
        self.xTitle = xTitle
        self.xMax = xMax
        self.xMin = xMin
    }
}

// MARK: - Metadata
public struct Metadata {
    public var dictionary: [String: Any]

    public init?(dictionary: [String: Any]?) {
        guard let metadata = dictionary else { return nil}
        self.dictionary = metadata
    }

    /// A Boolean property that indicates whether there are deficiencies in the metadata.
    ///
    /// If `deficiencies` is set to `true`, it means there are deficiencies present.
    public var deficiencies: Bool? {
        get { dictionary["deficiencies"] as? Bool }
        set { dictionary["deficiencies"] = newValue }
    }

    /// A Boolean property that indicates whether importing is blocked for the metadata.
    ///
    /// If `blockImport` is set to `true`, importing is blocked.
    public var blockImport: Bool? {
        get { dictionary["blockImport"] as? Bool }
        set { dictionary["blockImport"] = newValue }
    }

    /// A Boolean property that indicates whether auto-population is blocked for the metadata.
    ///
    /// If `blockAutoPopulate` is set to `true`, auto-population is blocked.
    public var blockAutoPopulate: Bool? {
        get { dictionary["blockAutoPopulate"] as? Bool }
        set { dictionary["blockAutoPopulate"] = newValue }
    }

    /// A Boolean property that indicates whether a deficiency title is required for the metadata.
    ///
    /// If `requireDeficiencyTitle` is set to `true`, a deficiency title is required.
    public var requireDeficiencyTitle: Bool? {
        get { dictionary["requireDeficiencyTitle"] as? Bool }
        set { dictionary["requireDeficiencyTitle"] = newValue }
    }

    /// A Boolean property that indicates whether a deficiency description is required for the metadata.
    ///
    /// If `requireDeficiencyDescription` is set to `true`, a deficiency description is required.
    public var requireDeficiencyDescription: Bool? {
        get { dictionary["requireDeficiencyDescription"] as? Bool }
        set { dictionary["requireDeficiencyDescription"] = newValue }
    }

    /// A Boolean property that indicates whether a deficiency photo is required for the metadata.
    ///
    /// If `requireDeficiencyPhoto` is set to `true`, a deficiency photo is required.
    public var requireDeficiencyPhoto: Bool? {
        get { dictionary["requireDeficiencyPhoto"] as? Bool }
        set { dictionary["requireDeficiencyPhoto"] = newValue }
    }

    /// The list associated with the metadata.
    ///
    /// The `list` property represents the list associated with the metadata.
    public var list: String? {
        get { dictionary["list"] as? String }
        set { dictionary["list"] = newValue }
    }

    /// The list column associated with the metadata.
    ///
    /// The `listColumn` property represents the list column associated with the metadata.
    public var listColumn: String? {
        get { dictionary["listColumn"] as? String }
        set { dictionary["listColumn"] = newValue }
    }
}

// MARK: - Option
/// A struct representing an option information.
///
/// This structure uses a dictionary to store option properties. Each property is accessed and modified through its own computed property.
public struct Option: Identifiable {
    var dictionary: [String: Any]

    /// Initializes an `Option` with the given dictionary.
    /// - Parameter dictionary: The dictionary representing the option. Default value is an empty dictionary.
    public init(dictionary: [String: Any] = [:]) {
        self.dictionary = dictionary
    }

    /// The value of the option.
    public var value: String? {
        get { dictionary["value"] as? String }
        set { dictionary["value"] = newValue }
    }

    /// Indicates whether the option is deleted.
    public var deleted: Bool? {
        get { dictionary["deleted"] as? Bool }
        set { dictionary["deleted"] = newValue }
    }

    /// The ID of the option.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }

    /// The width of the option.
    public var width: Int? {
        get { dictionary["width"] as? Int }
        set { dictionary["width"] = newValue }
    }
}

// MARK: - FieldTableColumn
/// `FieldTableColumn` is a structure that represents a table column in a field.
///
///  It uses a dictionary to store various properties of the column. Each property is accessed and modified using computed properties.
public struct FieldTableColumn {
    var dictionary: [String: Any]

    /// Initializes a new `FieldTableColumn` with the given dictionary.
    /// - Parameter dictionary: The dictionary representing the column. Default value is an empty dictionary.
    public init(dictionary: [String: Any] = [:]) {
        self.dictionary = dictionary
    }

    /// The ID of the column.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }

    /// The type of the column.
    public var type: String? {
        get { dictionary["type"] as? String }
        set { dictionary["type"] = newValue }
    }

    /// The title of the column.
    public var title: String? {
        get { dictionary["title"] as? String }
        set { dictionary["title"] = newValue }
    }

    /// The width of the column.
    public var width: Int? {
        get { dictionary["width"] as? Int }
        set { dictionary["width"] = newValue }
    }

    /// The identifier of the column.
    public var identifier: String? {
        get { dictionary["identifier"] as? String }
        set { dictionary["identifier"] = newValue }
    }

    /// The options associated with the column.
    public var options: [Option]? {
        get { (dictionary["options"] as? [[String: Any]])?.compactMap(Option.init) ?? [] }
        set { dictionary["options"] = newValue?.compactMap{ $0.dictionary } }
    }

    /// The value of the column.
    public var value: String? {
        get { dictionary["value"] as? String }
        set { dictionary["value"] = newValue }
    }

    /// The default selected ID for dropdown options.
    public var defaultDropdownSelectedId: String? {
        get { dictionary["defaultDropdownSelectedId"] as? String }
        set { dictionary["defaultDropdownSelectedId"] = newValue }
    }

    public var selectedOptionText: String {
        options?.filter { $0.id == defaultDropdownSelectedId }.first?.value ?? ""
    }


    /// The images associated with the column.
    public var images: [ValueElement]? {
        get { (dictionary["images"] as? [[String: Any]])?.compactMap(ValueElement.init) ?? [] }
        set { dictionary["images"] = newValue?.compactMap{ $0.dictionary } }
    }
}

/// `ValueUnion` is an enumeration that represents different types of values.
///
/// It can represent a `Double`, `String`, `Array<String>`, `Array<ValueElement>`, `Dictionary<String, ValueUnion>`, `Bool`, or `null`.
public enum ValueUnion: Codable, Hashable {
    /// Represents a `Double` value.
    case double(Double)
    /// Represents a `String` value.
    case string(String)
    /// Represents a `Array<String>` value.
    case array([String])
    /// Represents a `Array<ValueElement>` value.
    case valueElementArray([ValueElement])
    /// Represents a `Dictionary<String, ValueUnion>` value.
    case dictionary([String: ValueUnion])
    /// Represents a `Bool` value.
    case bool(Bool)
    /// Represents a `null` value.
    case null

    /// Creates a new `ValueUnion` with the given dictionary.
    ///
    /// - Parameter dcitonary: The dictionary that contains the initial properties of the column.
    public init(dcitonary: [String: ValueUnion]) {
        self = .dictionary(dcitonary)
    }

    /// Creates a new `ValueUnion` with the given dictionary.
    ///
    /// - Parameter dcitonary: The dictionary that contains the initial properties of the column.
    public init(dcitonary: [String: Any]) {
        var dictionary = [String : ValueUnion]()
        dcitonary.forEach { dict in
            dictionary[dict.key] = ValueUnion(value: dict.value)
        }
        self = .dictionary(dictionary)
    }

    /// Creates a new `ValueUnion` with the given dictionary.
    ///
    /// - Parameter valueFromDcitonary: The dictionary that contains the initial properties of the column.
    public init?(valueFromDcitonary: [String: Any]) {
        guard let value = valueFromDcitonary["value"] else { return nil }
        self.init(value: value)
    }

    /// Creates a new `ValueUnion` with the given value.
    ///
    /// - Parameter value: The value that the `ValueUnion` should represent.
    public init?(value: Any) {
        if let doubleValue = value as? Double {
            self = .double(doubleValue)
            return
        }

        if let boolValue = value as? Bool {
            self = .bool(boolValue)
            return
        }

        if let valueUnion = value as? ValueUnion {
            self = valueUnion
            return
        }

        if let strValue = value as? String {
            self = .string(strValue)
            return
        }

        if let arrayValue = value as? [String] {
            self = .array(arrayValue)
            return
        }

        if let valueElementArray = value as? [[String: Any]] {
            self = .valueElementArray(valueElementArray.map(ValueElement.init))
            return
        }

        if let valueElementArray = value as? [ValueElement] {
            self = .valueElementArray(valueElementArray)
            return
        }

        if let valueDictonary = value as? [String: Any] {
            self = ValueUnion.init(dcitonary: valueDictonary)
            return
        }

        if let valueDictonary = value as? NSNull {
            self = .null
            return
        }
#if DEBUG
        fatalError()
#else
        self = .null
#endif
    }

    /// The dictionary representation of the `ValueUnion`.
    public var dictionary: Any? {
        switch self {
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .array(let stringArray):
            return stringArray
        case .valueElementArray(let valueElementArray):
            return valueElementArray.map { $0.anyDictionary }
        case .bool(let bool):
            return bool
        case .null:
            return nil
        case .dictionary(let dictionary):
            var anyDict = [String: Any]()
            dictionary.forEach { (key: String, value: ValueUnion) in
                anyDict[key] = value.dictionary
            }
            return anyDict
        }
    }

    /// The dictionary representation of the `ValueUnion` with `ValueUnion` types.
    var dictionaryWithValueUnionTypes: Any? {
        switch self {
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .array(let stringArray):
            return stringArray
        case .valueElementArray(let valueElementArray):
            return valueElementArray
        case .bool(let bool):
            return bool
        case .null:
            return nil
        case .dictionary(let dictionary):
            return dictionary
        }
    }

    /// Creates a new `ValueUnion` by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to decode data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode([ValueElement].self) {
            self = .valueElementArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode([String].self) {
            self = .array(x)
            return
        }
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if container.decodeNil() {
            self = .null
            return
        }
        throw DecodingError.typeMismatch(ValueUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueUnion"))
    }
    
    /// Encodes this `ValueUnion` into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            if x.truncatingRemainder(dividingBy: 1) == 0 {
                try container.encode(Double(x))
            } else {
                try container.encode(x)
            }
        case .string(let x):
            try container.encode(x)
        case .valueElementArray(let x):
            try container.encode(x)
        case .array(let x):
            try container.encode(x)
        case .bool(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        }
    }

    public var isEmpty: Bool {
        switch self {
        case .double(let double):
            return false
        case .string(let string):
            return string.isEmpty
        case .array(let stringArray):
            return stringArray.isEmpty
        case .valueElementArray(let valueElementArray):
            return valueElementArray.isEmpty
        case .bool(let bool):
            return bool
        case .null:
            return true
        case .dictionary(let dictionary):
            return dictionary.isEmpty
        }
    }
}

// MARK: - ValueElement
/// A struct representing a value element.
///
/// It uses a dictionary to store various properties of the value element. Each property is accessed and modified using computed properties.
public struct ValueElement: Codable, Equatable, Hashable, Identifiable {
    
    /// The dictionary that stores the properties of the value element.
    var dictionary = [String: ValueUnion]()

    /// The dictionary representation of the `ValueElement` with `Any` types.
    public var anyDictionary: [String: Any] {
        var dict = [String: Any]()
        dictionary.forEach { (key: String, value: ValueUnion) in
            dict[key] = value.dictionary
        }
        return dict
    }

    /// Checks if two value elements are equal.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side value element.
    ///   - rhs: The right-hand side value element.
    /// - Returns: `true` if the value elements are equal, `false` otherwise.
    public static func == (lhs: ValueElement, rhs: ValueElement) -> Bool {
        lhs.id == rhs.id
    }

    /// Initializes a value element with a dictionary.
    ///
    /// - Parameter dictionary: The dictionary to initialize the value element with. Default value is an empty dictionary.
    public init(dictionary: [String: Any] = [:]) {
        dictionary.forEach { (key: String, value: Any) in
            self.dictionary[key] = ValueUnion(value: value)
        }
    }

    /// Initializes a value element from a decoder.
    ///
    /// - Parameter decoder: The decoder to decode the value element from.
    /// - Throws: An error if the decoding process fails.
    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            // Handle the error or return an appropriate value
            return
        }
        let allKeys = container.allKeys
        for key in allKeys {
            dictionary[key.stringValue] = try container.decodeIfPresent(ValueUnion.self, forKey: key)
        }
    }

    /// Encodes the value element into an encoder.
    ///
    /// - Parameter encoder: The encoder to encode the value element into.
    /// - Throws: An error if the encoding process fails.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        for (key, value) in dictionary {
            if let value = value as? ValueUnion {
                guard let codingKey = CodingKeys(stringValue: key) else { return }
                try container.encode(value, forKey: codingKey)
            }
        }
    }

    /// The coding keys used for encoding and decoding the value element.
    enum CodingKeys: String, CodingKey {
        case _id, url, fileName, filePath, deleted, title, description, points, cells
    }

    /// Initializes a value element with an ID, deleted flag, description, title, and points.
    ///
    /// - Parameters:
    ///   - id: The ID of the value element.
    ///   - deleted: A flag indicating if the value element is deleted. Default value is `false`.
    ///   - description: The description of the value element. Default value is an empty string.
    ///   - title: The title of the value element. Default value is an empty string.
    ///   - points: The points associated with the value element. Default value is `nil`.
    public init(id: String, deleted: Bool = false, description: String = "", title: String = "", points: [Point]?) {
        self.id = id
        self.points = points
        self.deleted = false
        self.description = ""
        self.title = ""
    }

    /// Initializes a value element with an ID and URL.
    ///
    /// - Parameters:
    ///   - id: The ID of the value element.
    ///   - url: The URL of the value element. Default value is `nil`.
    public init(id: String, url: String? = nil) {
        self.id = id
        self.url = url
    }

    /// Sets a string value for a given key in the value element's dictionary.
    ///
    /// - Parameters:
    ///   - value: The string value to set.
    ///   - key: The key to set the value for.
    mutating func setValue(_ value: String?, key: String) {
        guard let value = value else {
            return
        }
        self.dictionary[key] = .string(value)
    }

    /// Sets a boolean value for a given key in the value element's dictionary.
    ///
    /// - Parameters:
    ///   - value: The boolean value to set.
    ///   - key: The key to set the value for.
    mutating func setValue(_ value: Bool?, key: String) {
        guard let value = value else {
            return
        }
        self.dictionary[key] = .bool(value)
    }

    /// The ID of the value element.
    public var id: String? {
        get { (dictionary["_id"] as? ValueUnion)?.text}
        set { setValue(newValue, key: "_id") }
    }

    /// The URL of the value element.
    public var url: String? {
        get { (dictionary["url"] as? ValueUnion)?.text}
        set { setValue(newValue, key: "url") }
    }

    /// The file name of the value element.
    public var fileName: String? {
        get { (dictionary["fileName"] as? ValueUnion)?.text}
        set { setValue(newValue, key: "fileName") }
    }

    /// The file path of the value element.
    public var filePath: String? {
        get { (dictionary["filePath"] as? ValueUnion)?.text}
        set { setValue(newValue, key: "filePath") }
    }

    /// A flag indicating if the value element is deleted.
    public var deleted: Bool? {
        get { (dictionary["deleted"] as? ValueUnion)?.bool}
        set { setValue(newValue, key: "deleted") }

    }

    /// The title of the value element.
    public var title: String? {
        get { (dictionary["title"] as? ValueUnion)?.text}

        set { setValue(newValue, key: "title") }
    }

    /// The description of the value element.
    public var description: String? {
        get { (dictionary["description"] as? ValueUnion)?.text}

        set { setValue(newValue, key: "description") }
    }

    /// The points associated with the value element.
    public var points: [Point]? {
        get {
            let value = ((dictionary["points"] as? ValueUnion)?.dictionaryWithValueUnionTypes as? [ValueElement])
            return value?.compactMap(Point.init)
        }

        set {
            guard let value = newValue else {
                return
            }
            let dictValueUnion = value.flatMap { point in
                var dictAny = [String: ValueUnion]()
                let dict = point.dictionary.forEach { (key, value) in
                    dictAny[key] = ValueUnion(value: value)
                }
                return ValueElement(dictionary: dictAny)
            } as? [ValueElement]

            guard let dictValueUnion else {
                fatalError()
                return
            }
            self.dictionary["points"] = .valueElementArray(dictValueUnion)
        }
    }

    /// The cells associated with the value element.
    public var cells: [String: ValueUnion]? {
        get {
            let value = dictionary["cells"] as? ValueUnion
            return value?.dictionaryWithValueUnionTypes as? [String: ValueUnion]
        }
        set {
            guard let value = newValue else { return }
            self.dictionary["cells"] = ValueUnion.dictionary(value)
        }
    }

    /// Sets the deleted flag to `true`.
    public mutating func setDeleted() {
        deleted = true
    }
}

// MARK: - Point
/// A struct representing a point with x and y coordinates.
public struct Point: Codable {
    var dictionary = [String: ValueUnion]()

    /// Initializes a new instance of `Point` from a decoder.
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if the decoding process fails.
    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            // Handle the error or return an appropriate value
            return
        }
        let allKeys = container.allKeys
        for key in allKeys {
            dictionary[key.stringValue] = try container.decodeIfPresent(ValueUnion.self, forKey: key)
        }
    }

    /// Encodes the `Point` instance into the given encoder.
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if the encoding process fails.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        for (key, value) in dictionary {
            if let value = value as? ValueUnion {
                try container.encode(value, forKey: CodingKeys(stringValue: key)!)
            }
        }
    }

    /// The coding keys used for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case _id, label, y, x
    }

    /// Initializes a new instance of `Point` with a dictionary of values.
    /// - Parameter dictionary: The dictionary of values to initialize the `Point` instance.
    public init(dictionary: [String: Any] = [:]) {
        dictionary.forEach { (key: String, value: Any) in
            self.dictionary[key] = ValueUnion(value: value)
        }
    }

    /// Initializes a new instance of `Point` from a `ValueElement`.
    /// - Parameter valueElement: The `ValueElement` to initialize the `Point` instance.
    init(valueElement: ValueElement) {
        self.dictionary = valueElement.dictionary
    }

    /// Initializes a new instance of `Point` with the given id.
    /// - Parameter id: The id of the `Point`.
    public init(id: String) {
        self.id = id
        self.x = 0
        self.y = 0
        self.label = ""
    }

    /// Sets the value for a given key in the `Point` dictionary.
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: The key to set the value for.
    mutating func setValue(_ value: String?, key: String) {
        guard let value = value else {
            return
        }

        self.dictionary[key] = .string(value)
    }

    /// Sets the value for a given key in the `Point` dictionary.
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: The key to set the value for.
    mutating func setValue(_ value: CGFloat?, key: String) {
        guard let value = value else {
            return
        }
        self.dictionary[key] = .double(value)
    }

    /// The id of the `Point`.
    public var id: String? {
        get { (dictionary["_id"] as? ValueUnion)?.text }
        set { setValue(newValue, key: "_id") }
    }

    /// The label of the `Point`.
    public var label: String? {
        get { (dictionary["label"] as? ValueUnion)?.text }
        set { setValue(newValue, key: "label") }
    }

    /// The y-coordinate of the `Point`.
    public var y: CGFloat? {
        get {
            guard let valueUnion = (dictionary["y"] as? ValueUnion)?.number else { return nil }
            return CGFloat(valueUnion)
        }
        set { setValue(newValue, key: "y") }
    }

    /// The x-coordinate of the `Point`.
    public var x: CGFloat? {
        get {
            guard let valueUnion = (dictionary["x"] as? ValueUnion)?.number else { return nil }
            return CGFloat(valueUnion)
        }
        set { setValue(newValue, key: "x") }
    }
}

// MARK: - Page
/// Represents a page in a document.
public struct Page {
    var dictionary: [String: Any]

    /// Initializes a new `Page` instance with the given dictionary.
    /// - Parameter dictionary: The dictionary representing the page.
    public init(dictionary: [String: Any] = [:]) {
        self.dictionary = dictionary
    }

    /// The name of the page.
    public var name: String? {
        get { dictionary["name"] as? String }
        set { dictionary["name"] = newValue }
    }

    /// The positions of the fields on the page.
    public var fieldPositions: [FieldPosition]? {
        get { (dictionary["fieldPositions"] as? [[String: Any]])?.compactMap(FieldPosition.init) ?? [] }
        set { dictionary["fieldPositions"] = newValue?.compactMap{ $0.dictionary } }
    }

    /// The metadata associated with the page.
    public var metadata: Metadata? {
        get { Metadata.init(dictionary: dictionary["metadata"] as? [String: Any])}
        set { dictionary["metadata"] = newValue?.dictionary }
    }

    /// The width of the page.
    public var width: Double? {
        get { dictionary["width"] as? Double }
        set { dictionary["width"] = newValue }
    }

    /// The height of the page.
    public var height: Double? {
        get { dictionary["height"] as? Double }
        set { dictionary["height"] = newValue }
    }

    /// The number of columns in the page.
    public var cols: Double? {
        get { dictionary["cols"] as? Double }
        set { dictionary["cols"] = newValue }
    }

    /// The height of each row in the page.
    public var rowHeight: Double? {
        get { dictionary["rowHeight"] as? Double }
        set { dictionary["rowHeight"] = newValue }
    }

    /// The layout of the page.
    public var layout: String? {
        get { dictionary["layout"] as? String }
        set { dictionary["layout"] = newValue }
    }

    /// The presentation style of the page.
    public var presentation: String? {
        get { dictionary["presentation"] as? String }
        set { dictionary["presentation"] = newValue }
    }

    /// The margin of the page.
    public var margin: Double? {
        get { dictionary["margin"] as? Double }
        set { dictionary["margin"] = newValue }
    }

    /// The padding of the page.
    public var padding: Double? {
        get { dictionary["padding"] as? Double }
        set { dictionary["padding"] = newValue }
    }

    /// The border width of the page.
    public var borderWidth: Double? {
        get { dictionary["borderWidth"] as? Double }
        set { dictionary["borderWidth"] = newValue }
    }

    /// The ID of the page.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }

    /// The background image of the page.
    public var backgroundImage: String? {
        get { dictionary["backgroundImage"] as? String }
        set { dictionary["backgroundImage"] = newValue }
    }
    
    public var logic: Logic? {
        get { Logic.init(field: dictionary["logic"] as? [String: Any]) }
        set { dictionary["logic"] = newValue }
    }
    /// Indicates whether the page is hidden.
    public var hidden: Bool? {
        get { dictionary["hidden"] as? Bool }
        set { dictionary["hidden"] = newValue }
    }
}

// MARK: - FieldPosition
/// Represents the position and properties of a field in a document.
public struct FieldPosition {
    public var dictionary: [String: Any]

    /// Initializes a `FieldPosition` instance with an optional dictionary.
    /// - Parameter dictionary: An optional dictionary containing the field position properties.
    public init(dictionary: [String: Any] = [:]) {
        self.dictionary = dictionary
    }

    /// The name of the field.
    public var field: String? {
        get { dictionary["field"] as? String }
        set { dictionary["field"] = newValue }
    }

    /// The display type of the field.
    public var displayType: String? {
        get { dictionary["displayType"] as? String }
        set { dictionary["displayType"] = newValue }
    }

    /// The width of the field.
    public var width: Double? {
        get { dictionary["width"] as? Double }
        set { dictionary["width"] = newValue }
    }

    /// The height of the field.
    public var height: Double? {
        get { dictionary["height"] as? Double }
        set { dictionary["height"] = newValue }
    }

    /// The x-coordinate of the field.
    public var x: Double? {
        get { dictionary["x"] as? Double }
        set { dictionary["x"] = newValue }
    }

    /// The y-coordinate of the field.
    public var y: Double? {
        get { dictionary["y"] as? Double }
        set { dictionary["y"] = newValue }
    }

    /// The line height of the field.
    public var lineHeight: Double? {
        get { dictionary["lineHeight"] as? Double }
        set { dictionary["lineHeight"] = newValue }
    }

    /// The unique identifier of the field.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }

    /// The target value of the field.
    public var targetValue: String? {
        get { dictionary["targetValue"] as? String }
        set { dictionary["targetValue"] = newValue }
    }

    /// The condition associated with the field.
    public var condition: String? {
        get { dictionary["condition"] as? String }
        set { dictionary["condition"] = newValue }
    }

    /// The display type of the target value.
    public var targetValueDisplayType: String? {
        get { dictionary["targetValueDisplayType"] as? String }
        set { dictionary["targetValueDisplayType"] = newValue }
    }

    /// The display title of the field.
    public var titleDisplay: String? {
        get { dictionary["titleDisplay"] as? String }
        set { dictionary["titleDisplay"] = newValue }
    }

    /// The type of the field.
    public var type: FieldTypes? {
        get { FieldTypes(rawValue: dictionary["type"] as! String) }
        set { dictionary["type"] = newValue?.rawValue }
    }

    /// The font size of the field.
    public var fontSize: Double? {
        get { dictionary["fontSize"] as? Double }
        set { dictionary["fontSize"] = newValue }
    }

    /// The font color of the field.
    public var fontColor: String? {
        get { dictionary["fontColor"] as? String }
        set { dictionary["fontColor"] = newValue }
    }

    /// The font style of the field.
    public var fontStyle: String? {
        get { dictionary["fontStyle"] as? String }
        set { dictionary["fontStyle"] = newValue }
    }

    /// The font weight of the field.
    public var fontWeight: String? {
        get { dictionary["fontWeight"] as? String }
        set { dictionary["fontWeight"] = newValue }
    }

    /// The text alignment of the field.
    public var textAlign: String? {
        get { dictionary["textAlign"] as? String }
        set { dictionary["textAlign"] = newValue }
    }

    /// Indicates whether the field is for primary display only.
    public var primaryDisplayOnly: Bool? {
        get { dictionary["primaryDisplayOnly"] as? Bool }
        set { dictionary["primaryDisplayOnly"] = newValue }
    }

    /// The format of the field.
    public var format: String? {
        get { dictionary["format"] as? String }
        set { dictionary["format"] = newValue }
    }

    /// The column associated with the field.
    public var column: String? {
        get { dictionary["column"] as? String }
        set { dictionary["column"] = newValue }
    }

    /// The background color of the field.
    public var backgroundColor: String? {
        get { dictionary["backgroundColor"] as? String }
        set { dictionary["backgroundColor"] = newValue }
    }

    /// The border color of the field.
    public var borderColor: String? {
        get { dictionary["borderColor"] as? String }
        set { dictionary["borderColor"] = newValue }
    }

    /// The text decoration of the field.
    public var textDecoration: String? {
        get { dictionary["textDecoration"] as? String }
        set { dictionary["textDecoration"] = newValue }
    }

    /// The border width of the field.
    public var borderWidth: Double? {
        get { dictionary["borderWidth"] as? Double }
        set { dictionary["borderWidth"] = newValue }
    }

    /// The border radius of the field.
    public var borderRadius: Double? {
        get { dictionary["borderRadius"] as? Double }
        set { dictionary["borderRadius"] = newValue }
    }
}

/// MARK: - ModelView
/// A struct representing a model view.
public struct ModelView {
    var dictionary: [String: Any]

    /// Initializes a `ModelView` with an optional dictionary.
    /// - Parameter dictionary: An optional dictionary to initialize the `ModelView` with. Default value is an empty dictionary.
    public init(dictionary: [String: Any] = [:]) {
        self.dictionary = dictionary
    }

    /// The type of the model view.
    public var type: String? {
        get { dictionary["type"] as? String }
        set { dictionary["type"] = newValue }
    }

    /// The page order of the model view.
    public var pageOrder: [String]? {
        get { dictionary["pageOrder"] as? [String] }
        set { dictionary["pageOrder"] = newValue }
    }

    /// The pages of the model view.
    public var pages: [Page]? {
        get { (dictionary["pages"] as? [[String: Any]])?.compactMap(Page.init) ?? [] }
        set { dictionary["pages"] = newValue?.compactMap({ $0.dictionary}) }
    }

    /// The ID of the model view.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }
}

/// Generates a unique object ID by combining the current timestamp and a random hexadecimal string.
///
/// - Returns: A unique object ID string.
public func generateObjectId() -> String {
    // Get the current timestamp in seconds and convert to a hexadecimal string
    let timestamp = Int(Date().timeIntervalSince1970)
    let timestampHex = String(format: "%08x", timestamp)

    // Generate a random string of 16 hexadecimal characters
    var randomHex = ""
    for _ in 0..<8 {
        let randomValue = UInt32.random(in: 0..<UInt32.max)
        randomHex += String(format: "%08x", randomValue)
    }

    // Concatenate the timestamp hex and a portion of the random hex string to match the desired length
    return timestampHex + randomHex.prefix(16)
}

extension Array where Element == Bool {
    var andConditionIsTrue: Bool {
        return self.allSatisfy { $0 }
    }

    var orConditionIsTrue: Bool {
        return self.contains { $0 }
    }
}

public enum SortOder {
    case ascending
    case descending
    case none

    public mutating func next() {
        switch self {
        case .ascending:
            self = .descending
        case .descending:
            self = .none
        case .none:
            self = .ascending
        }
    }
}

public struct SortModel {
    public var order: SortOder = .none

    public init() {
    }
}

public struct FilterModel:Equatable {
    public var filterText: String = ""
    public var colIndex: Int
    public var colID: String

    public init(filterText: String = "", colIndex: Int, colID: String) {
        self.filterText = filterText
        self.colIndex = colIndex
        self.colID = colID
    }
}

public extension Array where Element == FilterModel {
    var noFilterApplied: Bool {
        self.allSatisfy { $0.filterText.isEmpty }
    }
}
