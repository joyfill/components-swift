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
    let fieldDependency: FieldDependency
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
                
                ChartCoordinateView(isCoordinateVisible: $isCoordinateVisible)
                
                LinesView(valueElements: $valueElements)
                
            }
        }
    }
}
struct ChartCoordinateView: View {
    @Binding var isCoordinateVisible: Bool
    @State var verticletitle: String = "Verticle"
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Chart Coordinates")
                
                Spacer()
                
                showCoordinatesButton
            }
            
            if isCoordinateVisible {
                Group {
                    xAndYCordinate(title: $verticletitle, isXAxis: false)
                    xAndYCordinate(title: $verticletitle, isXAxis: true)
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
    @Binding var title: String
    var isXAxis: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(isXAxis ? "Horizontal (X)" : "Vertical (Y)")
                
                TextField("", text: $title)
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
                    
                    xAndYAxisCoordinateView(xOrYValue: "45")
                }
                
                VStack(alignment: .leading) {
                    Text("Max")
                    
                    xAndYAxisCoordinateView(xOrYValue: "45")
                }
            }
            
        }
    }
}
struct LinesView: View {
    @Binding var valueElements: [ValueElement]
    
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
                    
                    removeLineButton
                }
                
                LineView(valueElement: valueElement)
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
    
    var removeLineButton: some View {
        Button(action: {
            
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
    var addLineButton: some View {
        Button(action: {
            
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
    @State var valueElement: ValueElement
    @State var lineTitle: String = "Line Title"
    @State var lineDescription: String = "Line Description"
    var body: some View {
        VStack {
            titleAndDescription
            
            PointsView(points: valueElement.points ?? [])
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
//    var points: [Int] = [1,2]
    @State var points: [Point]
   
    var body: some View {
        VStack(alignment: .leading){
                        
            HStack {
                Text("Points")
                
                Spacer()
                
                Button(action: {
                    
                }, label: {
                        Text("Add Point +")
                        .padding(.all,5)
                })
            }
            
            ForEach(points, id: \.self){ point in
                PointView(point: point)
                    .padding(.bottom, 10)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
//                    )
            }
        }
    }
    
}
struct PointView: View {
    var point: Point
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
                    xAndYAxisCoordinateView(xOrYValue: "\(point.x!)")
                    xAndYAxisCoordinateView(xOrYValue: "\(point.y!)")
                }
            }
            
            Button(action: {
                
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
