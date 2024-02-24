import Foundation
import SwiftyJSON

// Global variables
var joyDocStruct: JoyDoc?
public var pageIndex: Int = 0
public var componentType = [String]()
public var componentsYValueForMobileView = [Int]()

public var columnId = [String]()
public var componentId = [String]()
public var richTextValue = [String]()
public var tableRowOrder = [[String]]()
public var tableColumnType = [[String]]()
public var tableColumnTitle = [[String]]()
public var tableCellsData = [[[String]]]()
public var tableColumnOrderId = [[String]]()
public var multiSelectOptionId: [[String]] = []

var joyDocId = String()
var joyDocFileId = String()
var joyDocPageData: [Page]?
var joyDocPageId = [String]()
var joyDocIdentifier = String()
var valueUnion: [ValueUnion] = []
var joyDocPageOrderId = [String]()
var joyDocFieldData: [JoyDocField] = []
var tableFieldValue: [[ValueElement]] = []
var chartValueElement = [[ValueElement]]()
var optionsData: [[FieldTableColumn]] = []
var joyDocFieldPositionData: [FieldPosition] = []

var chartLineTitle = [[String]]()
var chartLineDescription = [[String]]()

// Variable to save counts
var fieldCount = Int()
var optionCount = Int()
public var pageCount = Int()
var tableColumnsCount = Int()
public var mobileViewId = String()

// MARK: - JoyDoc
public struct JoyDoc: Codable {
    public let id, type, stage: String?
    public let metadata: Metadata?
    public let identifier, name: String?
    public let createdOn: Int?
    public var files: [File]?
    public var fields: [JoyDocField]?
    let categories: [JSONAny]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, stage, metadata, identifier, name, createdOn, files, fields, categories
    }
    
    public var fieldPosition: FieldPosition? {
        guard let files = self.files else {
            return nil
        }
        let fileIndex = 0
        let pageIndex = 0
        let fieldPositionIndex = 0
        let file = files[fileIndex]
        let page = file.pages?[pageIndex]
        let fieldPosition = page?.fieldPositions?[fieldPositionIndex]
        return fieldPosition
    }
}

// MARK: - JoyDocField
public struct JoyDocField: Codable, Identifiable {
    public var type, id, identifier, title: String?
    public var value: ValueUnion?
    public let fieldRequired: Bool?
    public let metadata: Metadata?
    public let file: String?
    public let options: [Option]?
    public let tipTitle, tipDescription: String?
    public let tipVisible: Bool?
    public let multi: Bool?
    public let yTitle: String?
    public var yMax, yMin: Int?
    public let xTitle: String?
    public var xMax, xMin: Int?
    public var rowOrder: [String]?
    public var tableColumns: [FieldTableColumn]?
    public var tableColumnOrder: [String]?
    
    enum CodingKeys: String, CodingKey {
        case type
        case id = "_id"
        case identifier, title, value
        case fieldRequired = "required"
        case metadata, file, options, multi, yTitle, yMax, yMin, xTitle, xMax, xMin, rowOrder, tableColumns, tableColumnOrder
        case tipTitle, tipDescription, tipVisible
    }
}

// MARK: - Metadata
public struct Metadata: Codable {
    public let deficiencies, blockImport, blockAutoPopulate, requireDeficiencyTitle: Bool?
    public let requireDeficiencyDescription, requireDeficiencyPhoto: Bool?
    public let list, listColumn: String?
}

// MARK: - Option
public struct Option: Codable {
    public let value: String?
    public let deleted: Bool?
    public let id: String?
    public let width: Int?
    
    enum CodingKeys: String, CodingKey {
        case value, deleted
        case id = "_id"
        case width
    }
}

// MARK: - FieldTableColumn
public struct FieldTableColumn: Codable {
    public let id, type, title: String?
    public let width: Int?
    public let identifier: String?
    public let options: [Option]?
    public let value: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, title, width, identifier, options, value
    }
}

public enum ValueUnion: Codable {
    case integer(Int)
    case string(String)
    case array([String])
    case valueElementArray([ValueElement])
    case null
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
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
        if container.decodeNil() {
            self = .null
            return
        }
        throw DecodingError.typeMismatch(ValueUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueUnion"))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .valueElementArray(let x):
            try container.encode(x)
        case .array(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        }
    }
}

// MARK: - ValueElement
public struct ValueElement: Codable {
    public let id: String?
    public var url: String?
    public let fileName, filePath: String?
    public let deleted: Bool?
    public let title, description: String?
    public var points: [Point]?
    public var cells: [String: ValueUnion]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case url, fileName, filePath, deleted, title, description, points, cells
    }
}

// MARK: - Point
public struct Point: Codable {
    public var id, label: String?
    public var y, x: CGFloat?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case label, y, x
    }
}

// MARK: - File
public struct File: Codable {
    public let id: String?
    public let metadata: Metadata?
    public let name: String?
    public let version: Int?
    public let styles: Metadata?
    public var pages: [Page]?
    public var pageOrder: [String]?
    public var views: [ModelView]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case metadata, name, version, styles, pages, views, pageOrder
    }
}

// MARK: - Page
public struct Page: Codable {
    public let name: String?
    public var fieldPositions: [FieldPosition]?
    public let metadata: Metadata?
    public let width, height, cols, rowHeight: Int?
    public let layout, presentation: String?
    public let margin, padding, borderWidth: Int?
    public var id: String?
    
    enum CodingKeys: String, CodingKey {
        case name, fieldPositions, metadata, width, height, cols, rowHeight, layout, presentation, margin, padding, borderWidth
        case id = "_id"
    }
}

// MARK: - FieldPosition
public struct FieldPosition: Codable {
    public var field: String?
    public let displayType: String?
    public let width: Double?
    public let height: Double?
    public let x: Double?
    public var y: Double?
    public var id, type, targetValue: String?
    public let fontSize: Int?
    public let fontColor, fontStyle, fontWeight, textAlign: String?
    public let primaryDisplayOnly: Bool?
    public let format: String?
    public let column: String?
    public let backgroundColor: String?
    public let borderColor: String?
    public let textDecoration: String?
    public let borderWidth: Int?
    public let borderRadius: Int?
    
    enum CodingKeys: String, CodingKey {
        case field, displayType, width, height, x, y
        case id = "_id"
        case type, targetValue, fontSize, fontColor, fontStyle, fontWeight, textAlign, primaryDisplayOnly, format, column
        case backgroundColor, borderColor, textDecoration, borderWidth, borderRadius
    }
}

// MARK: - View
public struct ModelView: Codable {
    public let type: String?
    public var pageOrder: [String]?
    public var pages: [Page]?
    public let id: String?
    
    enum CodingKeys: String, CodingKey {
        case type, pageOrder, pages
        case id = "_id"
    }
}

// MARK: - Extension to fetch data from model
public var jsonData = Data()
extension JoyDoc {
    public static func loadFromJSON() -> [JoyDoc]? {
        do {
            joyDocStruct = try JSONDecoder().decode(JoyDoc.self, from: jsonData)
            
            // It will prevent tasks to perform on main thread
            DispatchQueue.main.async {
                pageIndex = 0
                fetchDataFromJoyDoc()
//                
//                joyDoc.delegate = viewForDataSource as? UITableViewDelegate
//                joyDoc.dataSource = viewForDataSource as? UITableViewDataSource
//                joyDoc.reloadData()
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
        return nil
    }
}

// MARK: - Function to get data from API
public func fetchDataFromJoyDoc() {
//    DeinitializeVariables()
    joyDocId = joyDocStruct?.id ?? ""
    joyDocFileId = joyDocStruct?.files?[0].id ?? ""
    joyDocIdentifier = joyDocStruct?.identifier ?? ""
    if joyDocStruct?.files?[0].views?.count == 0 {
        // Fetch data for primary view
        joyDocPageData = joyDocStruct?.files?[0].pages
        
        pageCount = joyDocStruct?.files?[0].pages?.count ?? 0
        for i in 0..<pageCount {
            joyDocPageId.append(joyDocStruct?.files?[0].pages?[i].id ?? "")
        }
        
        for i in 0..<(joyDocStruct?.files?[0].pageOrder?.count ?? 0) {
            joyDocPageOrderId.append(joyDocStruct?.files?[0].pageOrder?[i] ?? "")
        }
        
        if let indx = joyDocStruct?.files?[0].pages?.firstIndex(where: {$0.id == (joyDocStruct?.files?[0].pageOrder?[pageIndex])}) {
            fieldCount = joyDocStruct?.files?[0].pages?[indx].fieldPositions?.count ?? 0
            for j in 0..<fieldCount {
                // Get y value of all components
                let displayType = joyDocStruct?.files?[0].pages?[indx].fieldPositions?[j].displayType
                if displayType == "original" || displayType == "inputGroup" || displayType == "horizontal" {
                    let yFieldValue = joyDocStruct?.files?[0].pages?[indx].fieldPositions?[j].y ?? 0.0
                    componentsYValueForMobileView.append(Int(yFieldValue))
                    componentType.append(joyDocStruct?.files?[0].pages?[indx].fieldPositions?[j].type ?? "")
                    componentId.append(joyDocStruct?.files?[0].pages?[indx].fieldPositions?[j].field ?? "")
                    joyDocFieldPositionData.append((joyDocStruct?.files?[0].pages?[indx].fieldPositions?[j])!)
                    zipAndSortComponents()
                }
            }
        }
        
    } else {
        // Fetch data for mobile view
        mobileViewId = joyDocStruct?.files?[0].views?[0].id ?? ""
        joyDocPageData = joyDocStruct?.files?[0].views?[0].pages
        
        pageCount = joyDocStruct?.files?[0].views?[0].pages?.count ?? 0
        for i in 0..<pageCount {
            joyDocPageId.append(joyDocStruct?.files?[0].views?[0].pages?[i].id ?? "")
        }
        
        for i in 0..<(joyDocStruct?.files?[0].views?[0].pageOrder?.count ?? 0) {
            joyDocPageOrderId.append(joyDocStruct?.files?[0].views?[0].pageOrder?[i] ?? "")
        }
        
        if let indx = joyDocStruct?.files?[0].views?[0].pages?.firstIndex(where: {$0.id == (joyDocStruct?.files?[0].views?[0].pageOrder?[pageIndex])}) {
            fieldCount = joyDocStruct?.files?[0].views?[0].pages?[indx].fieldPositions?.count ?? 0
            for j in 0..<fieldCount {
                // Get y value of all components
                let displayType = joyDocStruct?.files?[0].views?[0].pages?[indx].fieldPositions?[j].displayType
                if displayType == "original" || displayType == "inputGroup" {
                    let yFieldValue = joyDocStruct?.files?[0].views?[0].pages?[indx].fieldPositions?[j].y ?? 0.0
                    componentsYValueForMobileView.append(Int(yFieldValue))
                    componentType.append(joyDocStruct?.files?[0].views?[0].pages?[indx].fieldPositions?[j].type ?? "")
                    componentId.append(joyDocStruct?.files?[0].views?[0].pages?[indx].fieldPositions?[j].field ?? "")
                    joyDocFieldPositionData.append((joyDocStruct?.files?[0].views?[0].pages?[indx].fieldPositions?[j])!)
                    zipAndSortComponents()
                }
            }
        }
    }
    
    // Get the title of the components
    for i in 0..<componentType.count {
        if let field = joyDocStruct?.fields?.first(where: { $0.id == componentId[i] }) {
            joyDocFieldData.append(field)
//            initializeVariablesWithEmptyValues()
        }
    }
}

// Zip and sort componentType and ComponentHeaderText with componentsYValueForMobileView
func zipAndSortComponents() {
    var componentIdPairedArray = Array(zip(componentsYValueForMobileView, componentId))
    var componentTypePairedArray = Array(zip(componentsYValueForMobileView, componentType))
    var fieldPositionPairedArray = Array(zip(componentsYValueForMobileView, joyDocFieldPositionData))
    componentIdPairedArray.sort { $0.0 < $1.0}
    componentTypePairedArray.sort { $0.0 < $1.0 }
    fieldPositionPairedArray.sort { $0.0 < $1.0 }
    
    // Extract the sorted values back into the original arrays
    componentId = componentIdPairedArray.map { $0.1 }
    componentType = componentTypePairedArray.map { $0.1 }
    joyDocFieldPositionData = fieldPositionPairedArray.map { $0.1 }
    componentsYValueForMobileView = componentTypePairedArray.map { $0.0 }
}
//
//func initializeVariablesWithEmptyValues() {
//    cellHeight.append(0)
//    yPointsData.append([])
//    xPointsData.append([])
//    signedImage.append("")
//    optionsData.append([])
//    yCoordinates.append([])
//    xCoordinates.append([])
//    chartPointsId.append([])
//    richTextValue.append("")
//    multiSelect.append(true)
//    tableRowOrder.append([])
//    cellView.append(UIView())
//    graphLabelData.append([])
//    tableCellsData.append([])
//    chartLineTitle.append([""])
//    tableFieldValue.append([])
//    dropdownOptions.append([])
//    tableColumnType.append([])
//    tableColumnTitle.append([])
//    chartValueElement.append([])
//    tableColumnOrderId.append([])
//    multiSelectOptions.append([])
//    uploadedImageCount.append([])
//    multiSelectOptionId.append([])
//    uploadedSingleImage.append([])
//    uploadedMultipleImage.append([])
//    chartLineDescription.append([""])
//    componentTableViewCellHeight.append(0)
//    selectedDropdownOptionIndexPath.append(0)
//    multiChoiseSelectedOptionIndexPath.append([])
//}
//
//func DeinitializeVariables() {
//    // Deinitialize arrays to protect memory leakage
//    cellView.removeAll()
//    cellHeight.removeAll()
//    yPointsData.removeAll()
//    xPointsData.removeAll()
//    optionsData.removeAll()
//    componentId.removeAll()
//    signedImage.removeAll()
//    yCoordinates.removeAll()
//    xCoordinates.removeAll()
//    joyDocPageId.removeAll()
//    chartPointsId.removeAll()
//    richTextValue.removeAll()
//    tableRowOrder.removeAll()
//    componentType.removeAll()
//    graphLabelData.removeAll()
//    tableCellsData.removeAll()
//    chartLineTitle.removeAll()
//    joyDocPageData?.removeAll()
//    dropdownOptions.removeAll()
//    tableColumnType.removeAll()
//    joyDocFieldData.removeAll()
//    tableFieldValue.removeAll()
//    tableColumnTitle.removeAll()
//    joyDocPageOrderId.removeAll()
//    chartValueElement.removeAll()
//    tableColumnOrderId.removeAll()
//    uploadedImageCount.removeAll()
//    multiSelectOptions.removeAll()
//    multiSelectOptionId.removeAll()
//    uploadedSingleImage.removeAll()
//    chartLineDescription.removeAll()
//    uploadedMultipleImage.removeAll()
//    joyDocFieldPositionData.removeAll()
//    componentTableViewCellHeight.removeAll()
//    componentsYValueForMobileView.removeAll()
//    selectedDropdownOptionIndexPath.removeAll()
//    multiChoiseSelectedOptionIndexPath.removeAll()
//}
