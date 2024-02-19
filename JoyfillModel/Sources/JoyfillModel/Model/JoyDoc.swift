import Foundation
import UIKit

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
struct JoyDoc: Codable {
    let id, type, stage: String?
    let metadata: Metadata?
    let identifier, name: String?
    let createdOn: Int?
    var files: [File]?
    var fields: [JoyDocField]?
    let categories: [JSONAny]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, stage, metadata, identifier, name, createdOn, files, fields, categories
    }
}

// MARK: - JoyDocField
struct JoyDocField: Codable, Identifiable {
    var type, id, identifier, title: String?
    var value: ValueUnion?
    let fieldRequired: Bool?
    let metadata: Metadata?
    let file: String?
    let options: [Option]?
    let tipTitle, tipDescription: String?
    let tipVisible: Bool?
    let multi: Bool?
    let yTitle: String?
    var yMax, yMin: Int?
    let xTitle: String?
    var xMax, xMin: Int?
    var rowOrder: [String]?
    var tableColumns: [FieldTableColumn]?
    var tableColumnOrder: [String]?
    
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
struct Metadata: Codable {
    let deficiencies, blockImport, blockAutoPopulate, requireDeficiencyTitle: Bool?
    let requireDeficiencyDescription, requireDeficiencyPhoto: Bool?
    let list, listColumn: String?
}

// MARK: - Option
struct Option: Codable {
    let value: String?
    let deleted: Bool?
    let id: String?
    let width: Int?
    
    enum CodingKeys: String, CodingKey {
        case value, deleted
        case id = "_id"
        case width
    }
}

// MARK: - FieldTableColumn
struct FieldTableColumn: Codable {
    let id, type, title: String?
    let width: Int?
    let identifier: String?
    let options: [Option]?
    let value: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, title, width, identifier, options, value
    }
}

enum ValueUnion: Codable {
    case integer(Int)
    case string(String)
    case array([String])
    case valueElementArray([ValueElement])
    case null
    
    
    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
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
struct ValueElement: Codable {
    let id: String?
    var url: String?
    let fileName, filePath: String?
    let deleted: Bool?
    let title, description: String?
    var points: [Point]?
    var cells: [String: ValueUnion]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case url, fileName, filePath, deleted, title, description, points, cells
    }
}

// MARK: - Point
struct Point: Codable {
    var id, label: String?
    var y, x: CGFloat?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case label, y, x
    }
}

// MARK: - File
struct File: Codable {
    let id: String?
    let metadata: Metadata?
    let name: String?
    let version: Int?
    let styles: Metadata?
    var pages: [Page]?
    var pageOrder: [String]?
    var views: [ModelView]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case metadata, name, version, styles, pages, views, pageOrder
    }
}

// MARK: - Page
struct Page: Codable {
    let name: String?
    var fieldPositions: [FieldPosition]?
    let metadata: Metadata?
    let width, height, cols, rowHeight: Int?
    let layout, presentation: String?
    let margin, padding, borderWidth: Int?
    var id: String?
    
    enum CodingKeys: String, CodingKey {
        case name, fieldPositions, metadata, width, height, cols, rowHeight, layout, presentation, margin, padding, borderWidth
        case id = "_id"
    }
}

// MARK: - FieldPosition
struct FieldPosition: Codable {
    var field: String?
    let displayType: String?
    let width: Double?
    let height: Double?
    let x: Double?
    var y: Double?
    var id, type, targetValue: String?
    let fontSize: Int?
    let fontColor, fontStyle, fontWeight, textAlign: String?
    let primaryDisplayOnly: Bool?
    let format: String?
    let column: String?
    let backgroundColor: String?
    let borderColor: String?
    let textDecoration: String?
    let borderWidth: Int?
    let borderRadius: Int?
    
    enum CodingKeys: String, CodingKey {
        case field, displayType, width, height, x, y
        case id = "_id"
        case type, targetValue, fontSize, fontColor, fontStyle, fontWeight, textAlign, primaryDisplayOnly, format, column
        case backgroundColor, borderColor, textDecoration, borderWidth, borderRadius
    }
}

// MARK: - View
struct ModelView: Codable {
    let type: String?
    var pageOrder: [String]?
    var pages: [Page]?
    let id: String?
    
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
func fetchDataFromJoyDoc() {
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
