//
//  ChartView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

struct ChartView: View {
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    @State var valueElements: [ValueElement] = []
    @State var showDetailChartView: Bool = false
    
    let data : MultiLineChartData?
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        _valueElements = State(initialValue: fieldDependency.fieldData?.value?.valueElements ?? [])
        data = ChartView.getData(fieldDependency: fieldDependency)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
           FieldHeaderView(fieldDependency)
            if let data = data {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                    .overlay(
                        MultiLineChart(chartData: data)
    //                        .touchOverlay(chartData: data, specifier: "%.01f", unit: .suffix(of: "ºC"))
                            .pointMarkers(chartData: data)
    //                        .xAxisGrid(chartData: data)
    //                        .yAxisGrid(chartData: data)
                            .xAxisLabels(chartData: data)
                            .yAxisLabels(chartData: data, specifier: "%.01f")
                            .floatingInfoBox(chartData: data)
    //                        .headerBox(chartData: data)
                        //                        .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible())])
                            .id(data.id)
                            .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                            .padding(.horizontal)
                    )
            }

            
            Button(action: {
                showDetailChartView = true
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
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
            .padding(.top, 6)
            if let data = data {
                NavigationLink(destination: ChartDetailView(chartData: data, fieldDependency: fieldDependency), isActive: $showDetailChartView) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }
        }
    }
    
    
    static func getData(fieldDependency: FieldDependency) -> MultiLineChartData? {
        guard let fieldData = fieldDependency.fieldData else { return nil  }
        guard let valueElements = fieldData.value?.valueElements else { return nil  }
        let data = MultiLineDataSet(dataSets: getLinesData(valueElements: valueElements))
        return MultiLineChartData(dataSets: data,
                                  metadata: ChartMetadata(title: fieldDependency.fieldData?.title ?? "", subtitle: ""),
                                  xAxisLabels: xAxisLabel(fieldData: fieldData),
                                  yAxisLabels: yAxisLabel(fieldData: fieldData),
                                  chartStyle: LineChartStyle(infoBoxPlacement: .floating,
                                                             markerType: .full(attachment: .line(dot: .style(DotStyle()))),
                                                             xAxisGridStyle: GridStyle(numberOfLines: 5),
                                                             xAxisLabelsFrom: .chartData(rotation: .zero), xAxisTitle: fieldDependency.fieldData?.xTitle,
                                                             yAxisGridStyle: GridStyle(numberOfLines: 5),
                                                             yAxisNumberOfLabels: 6,
                                                             yAxisTitle: fieldDependency.fieldData?.yTitle,
                                                             baseline: .minimumValue,
                                                             topLine: .maximumValue))
    }
    
    static func getLinesData(valueElements: [ValueElement]) -> [LineDataSet] {
        var lineDataSets: [LineDataSet] = []
        for valueElement in valueElements {
            let randomColor = Color(red: Double.random(in: 0...1),
                                    green: Double.random(in: 0...1),
                                    blue: Double.random(in: 0...1))
            lineDataSets.append(LineDataSet(dataPoints: getPointsData(valueElement: valueElement),
                                            legendTitle: valueElement.title ?? "",
                                            pointStyle: PointStyle(pointType: .filled, pointShape: .circle),
                                            style: LineStyle(lineColour: ColourStyle(colour: randomColor), lineType: .line)))
        }
        return lineDataSets
    }
    static func getPointsData(valueElement: ValueElement) -> [LineChartDataPoint] {
        var lineChartDataPoints: [LineChartDataPoint] = []
        for point in valueElement.points?.sorted(by: { $0.x! < $1.x!}) ?? [] {
            lineChartDataPoints.append(LineChartDataPoint(value: point.y ?? 0,  xAxisLabel: "\(point.x ?? 0)", description: "wekrhbf"))
        }
        return lineChartDataPoints
    }

    static func xAxisLabel(fieldData: JoyDocField) -> [String] {
        ["10", "20", "30", "40", "50", "60",]
    }

    static func yAxisLabel(fieldData: JoyDocField) -> [String] {
        ["10", "20", "30", "40", "50", "60",]
    }
}
