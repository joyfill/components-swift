//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 02/01/25.
//

import SwiftUI

struct TableProgressView: View {
    @Binding var cellModel: TableCellModel
    @ObservedObject var viewModel: TableViewModel
    
    public init(cellModel: Binding<TableCellModel>, viewModel: TableViewModel) {
        _cellModel = cellModel
        self.viewModel = viewModel
    }
    
    var body: some View {
        ProgressCircleView(currentProgress: viewModel.getProgress(rowId: cellModel.rowID), totalProgress: viewModel.tableDataModel.cellModels.first?.cells.count ?? 0)
    }
}

struct ProgressCircleView: View {
    let currentProgress: Int
    let totalProgress: Int

    var body: some View {
        HStack {
            Text("\(currentProgress)/\(totalProgress)")
                .font(.system(size: 15))

            ZStack {
                Circle()
                    .stroke(lineWidth: 5)
                    .foregroundColor(Color.gray.opacity(0.3))

                Circle()
                    .trim(from: 0, to: CGFloat(currentProgress) / CGFloat(totalProgress))
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .round
                        )
                    )
                    .darkLightThemeColor()
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 20, height: 20)
        }
    }
}
