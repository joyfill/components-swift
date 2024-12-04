//
//  ChartView.swift
//  JoyFill
//
//

import SwiftUI
//import SwiftUICharts
import JoyfillModel

struct ChartView: View {
    private let chartDataModel: ChartDataModel
    @FocusState private var isFocused: Bool // Declare a FocusState property
    @State var valueElements: [ValueElement] = []
    @State var showDetailChartView: Bool = false
    
//    let data : MultiLineChartData
    public init(chartDataModel: ChartDataModel) {
        self.chartDataModel = chartDataModel
        _valueElements = State(initialValue: chartDataModel.valueElements ?? [])
//        data = ChartView.getData(fieldDependency: fieldDependency)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(chartDataModel.fieldHeaderModel)
            
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
                let fieldEvent = FieldEvent(fieldID: chartDataModel.fieldId!, pageID: chartDataModel.pageId, fileID: chartDataModel.fileId)
                chartDataModel.eventHandler.onFocus(event: fieldEvent)
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

