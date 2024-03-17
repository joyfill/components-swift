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
            HStack{
                Image(systemName: "circlebadge.fill")
                    .foregroundColor(.green)
                Text("Line # 1")
            }
            .padding(.leading, 10)
            
            LineView()
                .padding(.all, 10)
            
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
            .padding(.all,10)
        }
    }
}

struct LineView: View {
    var body: some View {
        VStack {
            PointsView()
                .padding(.all, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
        }
    }
}

struct PointsView: View {
    var points: [Int] = [1,2]
    @State var lineTitle: String = "Line Title"
    @State var lineDescription: String = "Line Description"
    var body: some View {
        VStack(alignment: .leading){
            Text("Line Title")
            
            TextField("", text: $lineTitle)
//                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
            Text("Description")
            
            TextEditor(text: $lineDescription)
//                .disabled(fieldDependency.mode == .readonly)
                .padding(.all, 10)
                .autocorrectionDisabled()
                .frame(minHeight: 100, maxHeight: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
            
            Text("Points")
            ForEach(points, id: \.self){ point in
                PointView(pointLabel: "Point1")
                    .padding(.all, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
            }
            //TODO: Add Line Button
            Button(action: {
            }, label: {
                Text("Add Point")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
            })
            .padding(.top, 6)
        }
    }
}
struct PointView: View {
    @State var pointLabel: String
    var body: some View {
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
    }
}
struct xAndYAxisCoordinateView: View {
    @State var xOrYValue: String
    var body: some View {
        VStack(alignment: .leading){
            Text("xOrY")
            
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
}
