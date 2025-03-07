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
    let progress: (Int, Int)
    
    public init(cellModel: Binding<TableCellModel>, viewModel: TableViewModel) {
        _cellModel = cellModel
        self.viewModel = viewModel
        progress = viewModel.getProgress(rowId: cellModel.wrappedValue.rowID)
    }
    
    var body: some View {
        ProgressCircleView(currentProgress: progress.0, totalProgress: progress.1)
    }
}

struct CollectionProgressView: View {
    @Binding var cellModel: TableCellModel
    @ObservedObject var viewModel: CollectionViewModel
    let progress: (Int, Int)
    
    public init(cellModel: Binding<TableCellModel>, viewModel: CollectionViewModel) {
        _cellModel = cellModel
        self.viewModel = viewModel
        progress = viewModel.getProgress(rowId: cellModel.wrappedValue.rowID)
    }
    
    var body: some View {
        ProgressCircleView(currentProgress: progress.0, totalProgress: progress.1)
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
                    .animation(.easeOut(duration: 0.5), value: currentProgress)
            }
            .frame(width: 20, height: 20)
        }
    }
}
