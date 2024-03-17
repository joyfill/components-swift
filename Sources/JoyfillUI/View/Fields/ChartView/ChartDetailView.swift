//
//  SwiftUIView.swift
//  
//
//

import SwiftUI
import SwiftUICharts

struct ChartDetailView: View {
    var chartData: MultiLineChartData
    
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
                LinesView()
            }
        }
    }
}
struct LinesView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                lineNumberBadge
                
                Spacer()
                
                removeLineButton
            }
            
            LineView()
                .padding([.leading,.trailing,.bottom], 10)
            
            addLineButton
                .padding(.all,10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
        )
        .padding(.all,10)
    }
    
    var lineNumberBadge: some View {
        HStack{
            Image(systemName: "circlebadge.fill")
                .foregroundColor(.green)
            Text("Line #1")
        }
        .padding(.all,5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
        )
        .padding([.leading,.top], 10)
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
    var body: some View {
        VStack {
            PointsView()
        }
    }
}

struct PointsView: View {
    var points: [Int] = [1,2]
    @State var lineTitle: String = "Line Title"
    @State var lineDescription: String = "Line Description"
    var body: some View {
        VStack(alignment: .leading){
            
            titleAndDescription
            
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
                PointView(pointLabel: "Point1")
                    .padding(.all, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
            }
        }
    }
    var titleAndDescription: some View {
        VStack(alignment: .leading) {
            Text("Title & Description")
            
            TextField("", text: $lineTitle)
            //                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
            
            TextField("", text: $lineDescription)
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
struct PointView: View {
    @State var pointLabel: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Label")
                
                TextField("", text: $pointLabel)
                //                .disabled(fieldDependency.mode == .readonly)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
                    .cornerRadius(10)
                
                HStack {
                    xAndYAxisCoordinateView(xOrYValue: "45")
                    xAndYAxisCoordinateView(xOrYValue: "45")
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
