//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import SwiftUI

struct TableQuickView : View {
    private var data  = Array(1...3) // TODO: replace with actual rows
    private var data2  = Array(1...9) // TODO: replace with actual rows
    
    @ObservedObject var viewModel: TableViewModel
    
    init(tableViewModel: TableViewModel) {
        self.viewModel = tableViewModel
    }
    
    private let adaptiveColumn = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        
        VStack {
            HStack {
                
                if(viewModel.shouldShowTableTitle) {
                    Text(viewModel.tableViewTitle)
                        .lineLimit(1)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    Text("View")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.blue)
                        .font(.system(size: 8, weight: .heavy))
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 0, trailing: 8))
                    
                    Text(viewModel.viewMoreText)
                        .font(.system(size: 14))
                }
            }.padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
                .onTapGesture {
                    viewModel.isTableModalViewPresented.toggle()
                }
                .sheet(isPresented: $viewModel.isTableModalViewPresented) {
                    TableModalView(tableViewModel: viewModel)
                }
            
            HStack {
                Grid(verticalSpacing: 1) {
                    LazyVGrid(columns: adaptiveColumn, spacing: 4) {
                        ForEach(data, id: \.self) { item in
                            ZStack {
                                Rectangle()
                                    .stroke()
                                    .foregroundColor(Color.tableCellBorderColor)
                                
                                Text(String("Floor\(item)"))
                                    .frame(height: 50)
                            }.background(Color.tableColumnBgColor)
                            
                        }
                    }
                    .cornerRadius(14, corners: [.topLeft, .topRight])
                    
                    LazyVGrid(columns: adaptiveColumn, spacing: 0) {
                        ForEach(data2, id: \.self) { item in
                            ZStack {
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke()
                                    .foregroundColor(Color.tableCellBorderColor)
                                Text(String("Floor\(item)"))
                                    .frame(height: 50)
                            }
                            
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.tableBorderBgColor, lineWidth: 1)
            )
            .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
            
            Spacer()
        }
        
    }
}

#Preview {
    TableQuickView(tableViewModel: TableViewModel(mode: .fill, joyDocModel: fakeTableData()))
}
