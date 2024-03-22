//
//  SwiftUIView.swift
//  
//
//

import SwiftUI
import SwiftUICharts
import JoyfillModel

struct ChartDetailView: View {
    var chartData: MultiLineChartData
    var fieldDependency: FieldDependency
    @State var valueElements: [ValueElement] = []
    @State var isCoordinateVisible: Bool = false
    
    public init(chartData: MultiLineChartData,fieldDependency: FieldDependency) {
        self.chartData = chartData
        self.fieldDependency = fieldDependency
        _valueElements = State(initialValue: fieldDependency.fieldData?.value?.images ?? [])
    }
    
    var body: some View {
        VStack {
            ScrollView {
                
                MultiLineChart(chartData: chartData)
                //                        .touchOverlay(chartData: data, specifier: "%.01f", unit: .suffix(of: "ºC"))
                    .pointMarkers(chartData: chartData)
                //                        .xAxisGrid(chartData: data)
                //                        .yAxisGrid(chartData: data)
                    .xAxisLabels(chartData: chartData)
                    .yAxisLabels(chartData: chartData, specifier: "%.01f")
                    .floatingInfoBox(chartData: chartData)
                    .headerBox(chartData: chartData)
                    .legends(chartData: chartData, columns: [GridItem(.flexible()), GridItem(.flexible())])
                    .id(chartData.id)
                    .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                    .padding(.horizontal)
                
                ChartCoordinateView(isCoordinateVisible: $isCoordinateVisible, fieldDependency: fieldDependency)
                
                LinesView(valueElements: $valueElements,addNewLineAction: addNewLine, deleteLineAction: deleteLine, deletePointAction: deletePoint, addPointAction: addNewPoint)
            }
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
                    xAndYCordinate(fieldDependency: fieldDependency, isXAxis: false)
                    xAndYCordinate(fieldDependency: fieldDependency, isXAxis: true)
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
    @State var title: String = "dsfghj"
    var fieldDependency: FieldDependency
    var isXAxis: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(isXAxis ? "Horizontal (X)" : "Vertical (Y)")
                
                TextField("", text: isXAxis ? Binding.constant(fieldDependency.fieldData?.xTitle ?? "") : Binding.constant(fieldDependency.fieldData?.yTitle ?? ""))
//                            .disabled(fieldDependency.mode == .readonly)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
                    .cornerRadius(10)
                
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("Min")
                    
                    xAndYAxisCoordinateView(xOrYValue: isXAxis ? "\(fieldDependency.fieldData?.xMin ?? 0)" : "\(fieldDependency.fieldData?.yMin ?? 0)")
                }
                
                VStack(alignment: .leading) {
                    Text("Max")
                    
                    xAndYAxisCoordinateView(xOrYValue: isXAxis ? "\(fieldDependency.fieldData?.xMax ?? 0)" : "\(fieldDependency.fieldData?.yMax ?? 0)")
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
                
                LineView(valueElement: valueElementBinding,deletePointAction: deletePointAction,addPointAction: addPointAction)
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
            
            TextField("", text: Binding.constant(valueElement.title ?? ""))
            //                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
            
            TextField("", text: Binding.constant(valueElement.description ?? ""))
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
            ForEach(Array(points?.enumerated() ?? [Point]().enumerated()) , id: \.element.id){ index,point in
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
                TextField("", text: Binding.constant(point.label ?? ""))
                //                .disabled(fieldDependency.mode == .readonly)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
                    .cornerRadius(10)
                
                HStack {
                    xAndYAxisCoordinateView(xOrYValue: "\(point.x ?? 0)")
                    xAndYAxisCoordinateView(xOrYValue: "\(point.y ?? 0)")
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
}
struct xAndYAxisCoordinateView: View {
    @State var xOrYValue: String
    var body: some View {
        TextField("", text: $xOrYValue)
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

