//
//  SwiftUIView.swift
//  
//
//

import SwiftUI
import JoyfillModel

struct ChartDetailView: View {
//    var chartData: MultiLineChartData
    var chartDataModel: ChartDataModel
    @State var valueElements: [ValueElement] = []
    @State var isCoordinateVisible: Bool = false
    @State var chartCoordinatesData: ChartAxisConfiguration
    
//    public init(chartData: MultiLineChartData,fieldDependency: FieldDependency) {
    public init(chartDataModel: ChartDataModel) {
//        self.chartData = chartData
        self.chartDataModel = chartDataModel
        _valueElements = State(initialValue: chartDataModel.valueElements ?? [])
        _chartCoordinatesData = State(initialValue: ChartAxisConfiguration(yTitle: chartDataModel.yTitle,
                                                                           yMax: chartDataModel.yMax,
                                                                           yMin: chartDataModel.yMin,
                                                                           xTitle: chartDataModel.xTitle,
                                                                           xMax: chartDataModel.xMax,
                                                                           xMin: chartDataModel.xMin))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                
//                MultiLineChart(chartData: chartData)
//                //                        .touchOverlay(chartData: data, specifier: "%.01f", unit: .suffix(of: "ºC"))
//                    .pointMarkers(chartData: chartData)
//                //                        .xAxisGrid(chartData: data)
//                //                        .yAxisGrid(chartData: data)
//                    .xAxisLabels(chartData: chartData)
//                    .yAxisLabels(chartData: chartData, specifier: "%.01f")
//                    .floatingInfoBox(chartData: chartData)
//                    .headerBox(chartData: chartData)
//                    .legends(chartData: chartData, columns: [GridItem(.flexible()), GridItem(.flexible())])
//                    .id(chartData.id)
//                    .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
//                    .padding(.horizontal)
                
                ChartCoordinateView(isCoordinateVisible: $isCoordinateVisible, chartCoordinatesData: $chartCoordinatesData, chartDataModel: chartDataModel)
                LinesView(valueElements: $valueElements, updateValueElements: updateValueElements)
                    .disabled(chartDataModel.mode == .readonly)
            }
            .onChange(of: chartCoordinatesData, perform:  { newValue in
                let chartData = ChartData(xTitle: newValue.xTitle, yTitle: newValue.yTitle, xMax: newValue.xMax, xMin: newValue.xMin, yMax: newValue.yMax, yMin: newValue.yMin)
                let fieldEvent = FieldChangeData(fieldID: chartDataModel.fieldId!, pageID: chartDataModel.pageId, fileID: chartDataModel.fileId, updateValue: .valueElementArray(valueElements), chartData: chartData)
                chartDataModel.documentEditor?.onChange(event: fieldEvent)
            })
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }

    func updateValueElements(valueElements: [ValueElement]) {
        self.valueElements.removeAll()
        self.valueElements = valueElements
        let fieldEvent = FieldChangeData(fieldID: chartDataModel.fieldId!, pageID: chartDataModel.pageId, fileID: chartDataModel.fileId, updateValue: .valueElementArray(valueElements))
        chartDataModel.documentEditor?.onChange(event: fieldEvent)
    }
}

struct ChartCoordinateView: View {
    @Binding var isCoordinateVisible: Bool
    @Binding var chartCoordinatesData: ChartAxisConfiguration
    var chartDataModel: ChartDataModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Chart Coordinates")
                Spacer()
                showCoordinatesButton
            }
            if isCoordinateVisible {
                Group {
                    xAndYCordinate(chartCoordinatesData: $chartCoordinatesData, chartDataModel: chartDataModel, isXAxis: false, identifier: "VerticalTextFieldIdentifier")
                        .disabled(chartDataModel.mode == .readonly)
                xAndYCordinate(chartCoordinatesData: $chartCoordinatesData, chartDataModel: chartDataModel, isXAxis: true, identifier: "HorizontalTextFieldIdentifier")
                        .disabled(chartDataModel.mode == .readonly)
                }
                .padding(.all,10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
            }
        }
        .padding(.all,10)
    }
    
    var showCoordinatesButton: some View {
        Button(action: {
            isCoordinateVisible.toggle()
        }, label: {
            HStack(spacing: 5){
                Text(isCoordinateVisible ? "Hide" : "Show")
                    .foregroundColor(.blue)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.blue)
            }
            
        })
        .accessibilityIdentifier("ShowHideButtonIdentifier")
    }
}
struct xAndYCordinate: View {
    @Binding var chartCoordinatesData: ChartAxisConfiguration
    var chartDataModel: ChartDataModel
    var isXAxis: Bool
    var identifier: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(isXAxis ? "Horizontal (X)" : "Vertical (Y)")
                var xTitle : Binding<String> {
                    Binding {
                        return chartCoordinatesData.xTitle ?? ""
                    } set: { newXTitle in
                        chartCoordinatesData.xTitle = newXTitle
                    }
                }
                var yTitle : Binding<String> {
                    Binding {
                        return chartCoordinatesData.yTitle ?? ""
                    } set: { newYTitle in
                        chartCoordinatesData.yTitle = newYTitle
                    }
                }
                TextField("", text: isXAxis ? xTitle : yTitle )
                    .accessibilityIdentifier(identifier)
//                            .disabled(fieldDependency.mode == .readonly)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
                    .cornerRadius(10)
                
            }
            var xMinBinding : Binding<String> {
                Binding {
                    return formatNumber(chartCoordinatesData.xMin ?? 0)
                } set: { newXMin in
                    chartCoordinatesData.xMin = Double(newXMin)
                }
            }
            var yMinBinding : Binding<String> {
                Binding {
                    return formatNumber(chartCoordinatesData.yMin ?? 0)
                } set: { newXMin in
                    chartCoordinatesData.yMin = Double(newXMin)
                }
            }
            var xMaxBinding : Binding<String> {
                Binding {
                    return formatNumber(chartCoordinatesData.xMax ?? 0)
                } set: { newXMin in
                    chartCoordinatesData.xMax = Double(newXMin)
                }
            }
            var yMaxBinding : Binding<String> {
                Binding {
                    return formatNumber(chartCoordinatesData.yMax ?? 0)
                } set: { newXMin in
                    chartCoordinatesData.yMax = Double(newXMin)
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("Min")
                    
                    xAndYAxisCoordinateView(xOrYValue: isXAxis ? xMinBinding : yMinBinding, placeHolder: "", identifier: !isXAxis ? "MinY": "MinX")
                }
                VStack(alignment: .leading) {
                    Text("Max")
                    xAndYAxisCoordinateView(xOrYValue: isXAxis ? xMaxBinding : yMaxBinding, placeHolder: "", identifier: !isXAxis ? "MaxY": "MaxX")
                }
            }
        }
    }
    
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 20
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}

struct LinesView: View {
    @Binding var valueElements: [ValueElement]
    var updateValueElements: ([ValueElement]) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(valueElements.enumerated()), id: \.element.id) { index, valueElement in
                HStack {
                    HStack{
                        Image(systemName: "circlebadge.fill")
                            .foregroundColor(.green)
                        Text("Line #\(index + 1)")
                            .foregroundColor(.green)
                    }
                    .padding(.all,5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .padding([.leading,.top], 10)
                    
                    Spacer()
                    
                    Button(action: {
                        deleteLine(lineId: valueElement.id!)
                    }, label: {
                        HStack{
                            Text("Remove")
                                .darkLightThemeColor()
                            
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .padding(.all,5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                        .padding([.trailing,.top], 10)
                    })
                    .accessibilityIdentifier("RemoveLineIdentifier")
                }
                LineView(valueElement: valueElement, updateValueElement: updateValueElement)
                    .padding([.leading,.trailing,.bottom], 10)
                Divider()
            }
                        
            addLineButton
                .padding(.all,10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
        )
        .padding(.all,10)
    }
    
    
    var addLineButton: some View {
        Button(action: {
            addNewLine()
        }, label: {
            Text("Add Line")
                .darkLightThemeColor()
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
        })
        .accessibilityIdentifier("AddLineIdentifier")
    }

    func addNewLine() {
        var points: [Point] = []
        for i in 0..<3 {
            let point: Point = Point(id: generateObjectId())
            points.append(point)
        }
        var valueElement: ValueElement = ValueElement(id: generateObjectId(),points: points)
        valueElements.append(valueElement)
        updateValueElements(valueElements)
    }

    func updateValueElement(valueElement: ValueElement) {
        if let valueElementIndex = valueElements.firstIndex(where: { $0.id == valueElement.id }) {
            var elements = valueElements
            elements[valueElementIndex] = valueElement
            updateValueElements(elements)
        }
    }

    func deleteLine(lineId: String) {
        valueElements.removeAll(where: { $0.id == lineId })
        updateValueElements(valueElements)
    }
}

struct LineView: View {
    let valueElement: ValueElement
    let updateValueElement: (ValueElement) -> Void

    var body: some View {
        VStack {
            titleAndDescription
            PointsView(points: valueElement.points, lineId: valueElement.id ?? "", updatePoints: updatePoints)
        }
    }

    func updatePoints(points: [Point]?) {
        var valueElement = valueElement
        valueElement.points = points
        updateValueElement(valueElement)
    }

    var titleAndDescription: some View {
        VStack(alignment: .leading) {
            Text("Title & Description")
            var linetitleBinding : Binding<String> {
                Binding {
                    return valueElement.title ?? ""
                } set: { newLineTitle in
                    var valueElement = valueElement
                    valueElement.title = newLineTitle
                    updateValueElement(valueElement)
                }
            }
            
            TextField("Type title", text: linetitleBinding)
                .accessibilityIdentifier("TitleTextFieldIdentifier")
            //                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
            
            var lineDescriptionBinding : Binding<String> {
                Binding {
                    return valueElement.description ?? ""
                } set: { newLineDescription in
                    var valueElement = valueElement
                    valueElement.description = newLineDescription
                    updateValueElement(valueElement)
                }
            }
            
            TextField("Type description", text: lineDescriptionBinding)
                .accessibilityIdentifier("DescriptionTextFieldIdentifier")
            //                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
        }
    }
}

struct PointsView: View {
    let points: [Point]?
    var lineId: String
    let updatePoints: ([Point]?) -> Void

    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text("Points")
                Spacer()
                Button(action: {
                    addNewPoint(id: lineId)
                }, label: {
                    Text("Add Point +")
                        .padding(.all,5)
                })
                .accessibilityIdentifier("AddPointIdentifier")
            }
            
            ForEach(points ?? [], id: \.id) { point in
                PointView(point: point, deletePointAction: deletePoint, lineId: lineId, updatePoint: updatePoint)
                    .padding(.bottom, 20)
            }
        }
    }

    func updatePoint(point: Point) {
        let index = (points?.firstIndex(where: { $0.id == point.id }))!
        var points = points
        points?[index] = point
        updatePoints(points)
    }

    func addNewPoint(id: String? = nil) {
        var points = points ?? []
        points.append(Point(id: generateObjectId()))
        updatePoints(points)
    }

    func deletePoint(from lineId: String, pointId: String) {
        var points = points
        points?.removeAll(where: { $0.id == pointId })
        updatePoints(points)
    }

}

struct PointView: View {
    let point: Point
    var deletePointAction: (String, String) -> Void
    var lineId: String
    var updatePoint: (Point) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                var pointLabelBinding : Binding<String> {
                    Binding {
                        return point.label ?? ""
                    } set: { newPointLabel in
                        var point = point
                        point.label = newPointLabel
                        updatePoint(point)
                    }
                }
                TextField("Label", text: pointLabelBinding)
                    .accessibilityIdentifier("PointLabelTextFieldIdentifier")
                //                .disabled(fieldDependency.mode == .readonly)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
                    .cornerRadius(10)
                
                HStack {
                    var xBinding : Binding<String> {
                           Binding {
                               let formatter = NumberFormatter()
                               formatter.numberStyle = .decimal
                               formatter.usesGroupingSeparator = false
                               let formattedNumberString = formatter.string(from: NSNumber(value: point.x ?? 0)) ?? ""
                               return formattedNumberString
                           } set: { newX in
                               setX(x: newX)
                           }
                       }
                    var yBinding : Binding<String> {
                           Binding {
                               let formatter = NumberFormatter()
                               formatter.numberStyle = .decimal
                               formatter.usesGroupingSeparator = false
                               let formattedNumberString = formatter.string(from: NSNumber(value: point.y ?? 0)) ?? ""
                               return formattedNumberString
                           } set: { newY in
                               setY(y: newY)
                           }
                       }
                    xAndYAxisCoordinateView(xOrYValue: xBinding, placeHolder: "Horizontal value", identifier: "HorizontalPointsValue")
                    xAndYAxisCoordinateView(xOrYValue: yBinding, placeHolder: "Vertical value", identifier: "VerticalPointsValue")
                }
            }
            
            Button(action: {
                deletePointAction(lineId, point.id ?? "")
            }, label: {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
            })
            .accessibilityIdentifier("RemovePointIdentifier")
        }
    }
    
    func setY(y: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        let number = formatter.number(from: y)
        var point = self.point
        point.y = CGFloat(number?.doubleValue ?? 0)
        updatePoint(point)
    }
    
    func setX(x: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        let number = formatter.number(from: x)
        var point = self.point
        point.x = CGFloat(number?.doubleValue ?? 0)
        updatePoint(point)
    }
}

struct xAndYAxisCoordinateView: View {
    @Binding var xOrYValue: String
    var placeHolder: String
    var identifier: String
    var body: some View {
        TextField(placeHolder, text: $xOrYValue)
            .accessibilityIdentifier(identifier)
        //                .disabled(fieldDependency.mode == .readonly)
            .padding(.horizontal, 10)
            .frame(height: 40)
            .keyboardType(.decimalPad)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            .cornerRadius(10)
    }
}

