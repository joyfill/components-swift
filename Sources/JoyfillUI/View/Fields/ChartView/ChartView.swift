//
//  ChartView.swift
//  JoyFill
//
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif
import JoyfillModel

struct ChartView: View {
    private let chartDataModel: ChartDataModel
    @State var valueElements: [ValueElement] = []
    @State var showDetailChartView: Bool = false
    let eventHandler: FieldChangeEvents

//    let data : MultiLineChartData
    public init(chartDataModel: ChartDataModel, eventHandler: FieldChangeEvents) {
        self.chartDataModel = chartDataModel
        self.eventHandler = eventHandler
        _valueElements = State(initialValue: chartDataModel.valueElements ?? [])
//        data = ChartView.getData(fieldDependency: fieldDependency)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(chartDataModel.fieldHeaderModel)
            // Primary visual chart preview
#if canImport(Charts)
            if #available(iOS 16.0, *) {
                ChartPreview(chartDataModel: chartDataModel)
                    .frame(minWidth: 150, maxWidth: .infinity)
                    .frame(height: 230)
                    .padding(.bottom, 8)
            } else {
                ChartUnavailablePlaceholder()
                    .frame(height: 230)
                    .padding(.bottom, 8)
            }
#else
            ChartUnavailablePlaceholder()
                .frame(height: 230)
                .padding(.bottom, 8)
#endif
            
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.allFieldBorderColor, lineWidth: 1)
//                .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
//                .overlay(
//                    MultiLineChart(chartData: data)
////                        .touchOverlay(chartData: data, specifier: "%.01f", unit: .suffix(of: "ºC"))
//                        .pointMarkers(chartData: data)
////                        .xAxisGrid(chartData: data)
////                        .yAxisGrid(chartData: data)
//                        .xAxisLabels(chartData: data)
//                        .yAxisLabels(chartData: data, specifier: "%.01f")
//                        .floatingInfoBox(chartData: data)
////                        .headerBox(chartData: data)
//                    //                        .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible())])
//                        .id(data.id)
//                        .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
//                        .padding(.horizontal)
//                )
            
            Button(action: {
                showDetailChartView = true
                eventHandler.onFocus(event: chartDataModel.fieldIdentifier)
            }, label: {
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Chart View")
                        .darkLightThemeColor()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
            })
            .accessibilityIdentifier("ChartViewIdentifier")
            
            NavigationLink(destination: ChartDetailView(chartDataModel: chartDataModel), isActive: $showDetailChartView) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
    }
    
    // MARK: - Helpers
#if canImport(Charts)
    @available(iOS 16.0, *)
    private struct ChartPreview: View {
        let chartDataModel: ChartDataModel

        var body: some View {
            Chart {
                ForEach(series.indices, id: \.self) { index in
                    let valueElement = series[index]
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

        private var series: [ValueElement] { chartDataModel.valueElements ?? [] }

        private func sortedPoints(of element: ValueElement) -> [Point] {
            let points = element.points ?? []
            return points.sorted { (a, b) -> Bool in
                (a.x ?? 0) < (b.x ?? 0)
            }
        }

        private var xDomain: ClosedRange<Double> {
            let dataXs = series.flatMap { $0.points ?? [] }.compactMap { Double($0.x ?? 0) }
            let dataMin = dataXs.min() ?? 0
            let dataMax = dataXs.max() ?? max(1, dataMin + 1)
            let minValue = min(chartDataModel.xMin ?? dataMin, dataMin)
            let maxValue = max(chartDataModel.xMax ?? dataMax, dataMax)
            return minValue...maxValue
        }

        private var yDomain: ClosedRange<Double> {
            let dataYs = series.flatMap { $0.points ?? [] }.compactMap { Double($0.y ?? 0) }
            let dataMin = dataYs.min() ?? 0
            let dataMax = dataYs.max() ?? max(1, dataMin + 1)
            let minValue = min(chartDataModel.yMin ?? dataMin, dataMin)
            let maxValue = max(chartDataModel.yMax ?? dataMax, dataMax)
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
                Color(red: 0.38, green: 0.76, blue: 0.91), // light blue
                Color(red: 0.51, green: 0.42, blue: 0.80), // purple
                Color(red: 0.95, green: 0.77, blue: 0.06), // yellow
                Color(red: 0.96, green: 0.58, blue: 0.53), // coral
                Color(red: 0.30, green: 0.69, blue: 0.31), // green
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
    
//    static func getData(fieldDependency: FieldDependency) -> MultiLineChartData {
//        let data = MultiLineDataSet(dataSets: getLinesData(valueElements: fieldDependency.fieldData?.value?.images ?? []))
//        
//        return MultiLineChartData(dataSets: data,
//                                  metadata: ChartMetadata(title: fieldDependency.fieldData?.title ?? "", subtitle: ""),
//                                  xAxisLabels: [],
//                                  chartStyle: LineChartStyle(infoBoxPlacement: .floating,
//                                                             markerType: .full(attachment: .line(dot: .style(DotStyle()))),
//                                                             xAxisGridStyle: GridStyle(numberOfLines: 5),
//                                                             xAxisTitle: fieldDependency.fieldData?.xTitle,
//                                                             yAxisGridStyle: GridStyle(numberOfLines: 5),
//                                                             yAxisNumberOfLabels: 6,
//                                                             yAxisTitle: fieldDependency.fieldData?.yTitle,
//                                                             baseline: .minimumValue,
//                                                             topLine: .maximumValue))
//    }
    
//    static func getLinesData(valueElements: [ValueElement]) -> [LineDataSet] {
//        var lineDataSets: [LineDataSet] = []
//        for valueElement in valueElements {
//            let randomColor = Color(red: Double.random(in: 0...1),
//                                    green: Double.random(in: 0...1),
//                                    blue: Double.random(in: 0...1))
//            lineDataSets.append(LineDataSet(dataPoints: getPointsData(valueElement: valueElement),
//                                            legendTitle: valueElement.title ?? "",
//                                            pointStyle: PointStyle(pointType: .filled, pointShape: .circle),
//                                            style: LineStyle(lineColour: ColourStyle(colour: randomColor), lineType: .line)))
//        }
//        return lineDataSets
//    }
//    static func getPointsData(valueElement: ValueElement) -> [LineChartDataPoint] {
//        var lineChartDataPoints: [LineChartDataPoint] = []
//        for point in valueElement.points ?? [] {
//            lineChartDataPoints.append(LineChartDataPoint(value: point.y ?? 0,  xAxisLabel: "\(point.x ?? 0)", description: "wekrhbf"))
//        }
//        return lineChartDataPoints
//    }
}

