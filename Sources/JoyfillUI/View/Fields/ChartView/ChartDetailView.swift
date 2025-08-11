//
//  SwiftUIView.swift
//  
//
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif
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
                // Primary visual chart
#if canImport(Charts)
                if #available(iOS 16.0, *) {
                    DetailChart(chartDataModel: chartDataModel, valueElements: valueElements, chartCoordinatesData: chartCoordinatesData)
                        .frame(height: 280)
                        .padding(.horizontal)
                } else {
                    ChartUnavailablePlaceholder()
                        .frame(height: 280)
                        .padding(.horizontal)
                }
#else
                ChartUnavailablePlaceholder()
                    .frame(height: 280)
                    .padding(.horizontal)
#endif
                
                ChartCoordinateView(isCoordinateVisible: $isCoordinateVisible, chartCoordinatesData: $chartCoordinatesData, chartDataModel: chartDataModel)
                LinesView(valueElements: $valueElements, updateValueElements: updateValueElements, xTitle: chartDataModel.xTitle, yTitle: chartDataModel.yTitle)
                    .disabled(chartDataModel.mode == .readonly)
            }
            .onChange(of: chartCoordinatesData, perform:  { newValue in
                let chartData = ChartData(xTitle: newValue.xTitle, yTitle: newValue.yTitle, xMax: newValue.xMax, xMin: newValue.xMin, yMax: newValue.yMax, yMin: newValue.yMin)
                let fieldEvent = FieldChangeData(fieldIdentifier: chartDataModel.fieldIdentifier, updateValue: .valueElementArray(valueElements), chartData: chartData)
                chartDataModel.documentEditor?.onChange(event: fieldEvent)
            })
            .modifier(KeyboardDismissModifier())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }

    func updateValueElements(valueElements: [ValueElement]) {
        self.valueElements.removeAll()
        self.valueElements = valueElements
        let fieldEvent = FieldChangeData(fieldIdentifier: chartDataModel.fieldIdentifier, updateValue: .valueElementArray(valueElements))
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
    var xTitle: String?
    var yTitle: String?

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
                        guard let id = valueElement.id else {
                            Log("Missing line ID", type: .error)
                            return
                        }
                        deleteLine(lineId: id)
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
                LineView(valueElement: valueElement, updateValueElement: updateValueElement, xTitle: xTitle, yTitle: yTitle)
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
    var xTitle: String?
    var yTitle: String?

    var body: some View {
        VStack {
            titleAndDescription
            PointsView(points: valueElement.points, lineId: valueElement.id ?? "", updatePoints: updatePoints, xTitle: xTitle, yTitle: yTitle)
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
    var xTitle: String?
    var yTitle: String?

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
                PointView(point: point, deletePointAction: deletePoint, lineId: lineId, updatePoint: updatePoint, xTitle: xTitle, yTitle: yTitle)
                    .padding(.bottom, 20)
            }
        }
    }

    func updatePoint(point: Point) {
        if let index = points?.firstIndex(where: { $0.id == point.id }) {
            var points = points
            points?[index] = point
            updatePoints(points)
        } else {
            Log("Point with ID \(point.id) not found", type: .error)
            return
        }
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
    var xTitle: String?
    var yTitle: String?

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
                    xAndYAxisCoordinateView(xOrYValue: xBinding, placeHolder: xTitle?.isEmpty == false ? (xTitle ?? "") : "Horizontal", identifier: "HorizontalPointsValue")
                    xAndYAxisCoordinateView(xOrYValue: yBinding, placeHolder: yTitle?.isEmpty == false ? (yTitle ?? "") : "Vertical", identifier: "VerticalPointsValue")
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

// MARK: - Chart components
#if canImport(Charts)
@available(iOS 16.0, *)
private struct DetailChart: View {
    let chartDataModel: ChartDataModel
    let valueElements: [ValueElement]
    let chartCoordinatesData: ChartAxisConfiguration

    var body: some View {
        Chart {
            ForEach(Array(valueElements.enumerated()), id: \.element.id) { (index, valueElement) in
                ForEach(sortedPoints(of: valueElement), id: \.id) { point in
                    if let x = point.x, let y = point.y {
                        LineMark(
                            x: .value(chartDataModel.xTitle ?? "Horizontal", Double(x)),
                            y: .value(chartDataModel.yTitle ?? "Vertical", Double(y))
                        )
                        .foregroundStyle(color(for: index))
                        .interpolationMethod(.linear)
                    }
                }
            }
        }
        .chartXAxisLabel(position: .bottom, alignment: .center) {
            Text(chartDataModel.xTitle ?? "Horizontal")
        }
        .chartYAxisLabel(position: .leading, alignment: .center) {
            Text(chartDataModel.yTitle ?? "Vertical")
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: yDomain)
        .chartXAxis { axisMarks }
        .chartYAxis { axisMarks }
    }

    private func sortedPoints(of element: ValueElement) -> [Point] {
        let points = element.points ?? []
        return points.sorted { (a, b) -> Bool in
            (a.x ?? 0) < (b.x ?? 0)
        }
    }

    private var xDomain: ClosedRange<Double> {
        let xs = valueElements.flatMap { $0.points ?? [] }.compactMap { Double($0.x ?? 0) }
        let xmin = xs.min() ?? 0
        let xmax = xs.max() ?? max(1, xmin + 1)
        let minValue = min(chartCoordinatesData.xMin ?? xmin, xmin)
        let maxValue = max(chartCoordinatesData.xMax ?? xmax, xmax)
        return minValue...maxValue
    }

    private var yDomain: ClosedRange<Double> {
        let ys = valueElements.flatMap { $0.points ?? [] }.compactMap { Double($0.y ?? 0) }
        let ymin = ys.min() ?? 0
        let ymax = ys.max() ?? max(1, ymin + 1)
        let minValue = min(chartCoordinatesData.yMin ?? ymin, ymin)
        let maxValue = max(chartCoordinatesData.yMax ?? ymax, ymax)
        return minValue...maxValue
    }

    @AxisContentBuilder
    private var axisMarks: some AxisContent {
        AxisMarks(position: .automatic) { _ in
            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            AxisTick()
            AxisValueLabel()
        }
    }

    private func color(for index: Int) -> Color {
        let palette: [Color] = [
            Color(red: 0.38, green: 0.76, blue: 0.91),
            Color(red: 0.51, green: 0.42, blue: 0.80),
            Color(red: 0.95, green: 0.77, blue: 0.06),
            Color(red: 0.96, green: 0.58, blue: 0.53),
            Color(red: 0.30, green: 0.69, blue: 0.31),
        ]
        return palette[index % palette.count]
    }
}
#endif

private struct ChartUnavailablePlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
            Text("Chart preview requires iOS 16+")
                .foregroundColor(.secondary)
        }
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

