//
//  SwiftUIView.swift
//  
//
//

import SwiftUI
import JoyfillModel

struct ChartDetailView: View {
//    var chartData: MultiLineChartData
    var fieldDependency: FieldDependency
    @State var valueElements: [ValueElement] = []
    @State var isCoordinateVisible: Bool = false
    @State var chartCoordinatesData: ChartAxisConfiguration
    
//    public init(chartData: MultiLineChartData,fieldDependency: FieldDependency) {
    public init(fieldDependency: FieldDependency) {

//        self.chartData = chartData
        self.fieldDependency = fieldDependency
        _valueElements = State(initialValue: fieldDependency.fieldData?.value?.images ?? [])
        _chartCoordinatesData = State(initialValue: ChartAxisConfiguration(yTitle: fieldDependency.fieldData?.yTitle, yMax: fieldDependency.fieldData?.yMax, yMin: fieldDependency.fieldData?.yMin, xTitle: fieldDependency.fieldData?.xTitle, xMax: fieldDependency.fieldData?.xMax, xMin: fieldDependency.fieldData?.xMin))
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
                
                ChartCoordinateView(isCoordinateVisible: $isCoordinateVisible, chartCoordinatesData: $chartCoordinatesData, fieldDependency: fieldDependency)
                LinesView(valueElements: $valueElements,addNewLineAction: addNewLine, deleteLineAction: deleteLine, deletePointAction: deletePoint, addPointAction: addNewPoint)
            }
            .onChange(of: valueElements, perform: { newValue in
                guard var fieldData = fieldDependency.fieldData else { return }
                fieldData.value = .valueElementArray(newValue)
                fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
            })
            .onChange(of: chartCoordinatesData,perform:  { newValue in
                guard var fieldData = fieldDependency.fieldData else { return }
                fieldData.xTitle = newValue.xTitle
                fieldData.yTitle = newValue.yTitle
                fieldData.xMax = newValue.xMax
                fieldData.xMin = newValue.xMin
                fieldData.yMax = newValue.yMax
                fieldData.yMin = newValue.yMin
                fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
            })
        }
    }
    
    func addNewLine() {
        var points: [Point] = []
        for i in 0..<3 {
            let point: Point = Point(id: generateObjectId())
            points.append(point)
        }
        var valueElement: ValueElement = ValueElement(id: generateObjectId(),points: points)
        valueElements.append(valueElement)
    }
    
    func addNewPoint(id: String) {
        if let valueElementIndex = valueElements.firstIndex(where: { $0.id == id }) {
            let point: Point = Point(id: generateObjectId())
            valueElements[valueElementIndex].points?.append(point)
        }
    }
    
    func deleteLine(lineId: String) {
        valueElements.removeAll(where: { $0.id == lineId })
    }
    
    func deletePoint(from lineId: String, pointId: String) {
        if let valueElementIndex = valueElements.firstIndex(where: { $0.id == lineId }) {
            valueElements[valueElementIndex].points?.removeAll(where: { $0.id == pointId })
        }
    }
}
struct ChartCoordinateView: View {
    @Binding var isCoordinateVisible: Bool
    @Binding var chartCoordinatesData: ChartAxisConfiguration
    var fieldDependency: FieldDependency
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Chart Coordinates")
                Spacer()
                showCoordinatesButton
            }
            if isCoordinateVisible {
                Group {
                    xAndYCordinate(chartCoordinatesData: $chartCoordinatesData, fieldDependency: fieldDependency, isXAxis: false)
                xAndYCordinate(chartCoordinatesData: $chartCoordinatesData, fieldDependency: fieldDependency, isXAxis: true)
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
    }
}
struct xAndYCordinate: View {
    @Binding var chartCoordinatesData: ChartAxisConfiguration
    var fieldDependency: FieldDependency
    var isXAxis: Bool
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
                    return "\(chartCoordinatesData.xMin ?? 0)"
                } set: { newXMin in
                    chartCoordinatesData.xMin = Int(newXMin)
                }
            }
            var yMinBinding : Binding<String> {
                Binding {
                    return "\(chartCoordinatesData.yMin ?? 0)"
                } set: { newXMin in
                    chartCoordinatesData.yMin = Int(newXMin)
                }
            }
            var xMaxBinding : Binding<String> {
                Binding {
                    return "\(chartCoordinatesData.xMax ?? 0)"
                } set: { newXMin in
                    chartCoordinatesData.xMax = Int(newXMin)
                }
            }
            var yMaxBinding : Binding<String> {
                Binding {
                    return "\(chartCoordinatesData.yMax ?? 0)"
                } set: { newXMin in
                    chartCoordinatesData.yMax = Int(newXMin)
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("Min")
                    
                    xAndYAxisCoordinateView(xOrYValue: isXAxis ? xMinBinding : yMinBinding, placeHolder: "")
                }
                VStack(alignment: .leading) {
                    Text("Max")
                    xAndYAxisCoordinateView(xOrYValue: isXAxis ? xMaxBinding : yMaxBinding, placeHolder: "")
                }
            }
        }
    }
}
struct LinesView: View {
    @Binding var valueElements: [ValueElement]
    var addNewLineAction: () -> Void
    var deleteLineAction: (String) -> Void
    var deletePointAction: (String, String) -> Void
    var addPointAction: (String) -> Void
    
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
                        deleteLineAction(valueElement.id ?? "")
                    }, label: {
                        HStack{
                            Text("Remove")
                                .foregroundColor(.black)
                            
                            Image(systemName: "minus.circle")
                                .foregroundColor(.black)
                        }
                        .padding(.all,5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                        .padding([.trailing,.top], 10)
                    })
                }
                 var valueElementBinding : Binding<ValueElement> {
                        Binding {
                            return valueElement
                        } set: { newValueElement in
                            valueElements[index] = newValueElement
                        }
                    }
                
                LineView(valueElement: valueElementBinding,deletePointAction: deletePointAction, addPointAction: addPointAction)
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
            addNewLineAction()
        }, label: {
            Text("Add Line")
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
        })
    }
}

struct LineView: View {
    @Binding var valueElement: ValueElement
    var deletePointAction: (String, String) -> Void
    var addPointAction: (String) -> Void
    
    var body: some View {
        VStack {
            titleAndDescription
            
            PointsView(points: $valueElement.points, deletePointAction: deletePointAction, lineId: valueElement.id ?? "", addPointAction: addPointAction)
            
        }
    }
    var titleAndDescription: some View {
        VStack(alignment: .leading) {
            Text("Title & Description")
            var linetitleBinding : Binding<String> {
                Binding {
                    return valueElement.title ?? ""
                } set: { newLineTitle in
                    valueElement.title = newLineTitle
                }
            }
            
            TextField("Type title", text: linetitleBinding)
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
                    valueElement.description = newLineDescription
                }
            }
            
            TextField("Type description", text: lineDescriptionBinding)
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
    @Binding var points: [Point]?
    var deletePointAction: (String, String) -> Void
    var lineId: String
    var addPointAction: (String) -> Void
   
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text("Points")
                Spacer()
                Button(action: {
                    addPointAction(lineId)
                }, label: {
                    Text("Add Point +")
                        .padding(.all,5)
                })
            }
            ForEach(Array(points?.enumerated() ?? [Point]().enumerated()) , id: \.element.id){ index, point in
                    var pointBinding : Binding<Point> {
                           Binding {
                                return point
                           } set: { newPoint in
                               points?[index] = newPoint
                           }
                       }
                    PointView(point: pointBinding, deletePointAction: deletePointAction, lineId: lineId)
                        .padding(.bottom, 20)
                    //                    .overlay(
                    //                        RoundedRectangle(cornerRadius: 10)
                    //                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    //                    )
                }
            }
    }
    
}
struct PointView: View {
    @Binding var point: Point
    var deletePointAction: (String, String) -> Void
    var lineId: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                var pointLabelBinding : Binding<String> {
                    Binding {
                        return point.label ?? ""
                    } set: { newPointLabel in
                        point.label = newPointLabel
                    }
                }
                TextField("Label", text: pointLabelBinding)
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
                    xAndYAxisCoordinateView(xOrYValue: xBinding, placeHolder: "Horizontal value")
                    xAndYAxisCoordinateView(xOrYValue: yBinding, placeHolder: "Vertical value")
                }
            }
            
            Button(action: {
                deletePointAction(lineId, point.id ?? "")
            }, label: {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
            })
        }
    }
    
    func setY(y: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        let number = formatter.number(from: y)
        self.point.y = CGFloat(number?.doubleValue ?? 0)
    }
    
    func setX(x: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        let number = formatter.number(from: x)
        self.point.x = CGFloat(number?.doubleValue ?? 0)
    }
}

struct xAndYAxisCoordinateView: View {
    @Binding var xOrYValue: String
    var placeHolder: String
    var body: some View {
        TextField(placeHolder, text: $xOrYValue)
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

