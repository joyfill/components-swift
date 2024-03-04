//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import SwiftUI
import JoyfillModel


struct TableModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var tableViewModel: TableViewModel
    
    init(tableViewModel: TableViewModel) {
        self.tableViewModel = tableViewModel
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView()
                .padding(10)
            scrollArea
        }
    }
    
    var scrollArea: some View {
        
        HStack(alignment: .top, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("")
                    Text("#")
                }.frame(width: 80, height: 50)
                
                ScrollView([.vertical]) {
                    rowsHeader
                        .offset(y: offset.y)
                    
                }
                .scrollIndicators(.hidden)
                .disabled(true)
            }
            VStack(alignment: .leading, spacing: 0) {
                ScrollView([.horizontal]) {
                    colsHeader
                        .offset(x: offset.x)
                }
                .disabled(true)
                
                table
                    .coordinateSpace(name: "scroll")
            }
        }
        
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }
    
    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(tableViewModel.columns, id: \.self) { col in
                
                ZStack {
                    Rectangle()
                        .stroke()
                        .foregroundColor(Color.tableCellBorderColor)
                    Text(tableViewModel.getColumnTitle(columnId: col))
                }.background(Color.tableColumnBgColor).frame(width: 170, height: 50)
                
            }
        }
    }
    
    var rowsHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(tableViewModel.rows.enumerated()), id: \.offset) { (index, row) in
                HStack(spacing: 0) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: false ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: 50)
                            .border(Color.tableCellBorderColor)
                    })
                    
                    Text("\(index+1)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: 50)
                        .border(Color.tableCellBorderColor)
                        .id("\(row)")
                }
            }
        }
    }
    
    var table: some View {
        ScrollViewReader { cellProxy in
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(tableViewModel.rows, id: \.self) { row in
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Array(tableViewModel.columns.enumerated()), id: \.offset) { index, col in
                                // Cell
                                let t = tableViewModel.getFieldTableColumn(row: row, col: index)
                                ZStack {
                                    Rectangle()
                                        .stroke()
                                        .foregroundColor(Color.tableCellBorderColor)
                                    // TODO: Switch view here
                                    Text(t?.title ?? "(\(row), \(col))")
                                }.frame(width: 170, height: 50).id("\(row)_\(col)")
                            }
                        }
                    }
                }
                .background( GeometryReader { geo in
                    Color.clear
                        .preference(key: ViewOffsetKey.self, value: geo.frame(in: .named("scroll")).origin)
                })
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    //ScrollView scrolling, offset changed
                    offset = value
                }
            }
        }
    }
}

#Preview {
    TableModalView(tableViewModel: TableViewModel(mode: .fill, joyDocModel: fakeTableData()))
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGPoint
    static var defaultValue = CGPoint.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.x += nextValue().x
        value.y += nextValue().y
    }
}



//TODO: Remove this
func fakeTableData() -> JoyDocField? {
    let data = response.data(using: .utf8)!
    do {
        return try? JSONDecoder().decode(JoyDocField.self, from: data)
    } catch {
        return nil
    }
}

let response = """
{
                    "type": "table",
                    "_id": "65c77d9a72b975711c99bd50",
                    "identifier": "field_65c77d9e631e9e53679fdda4",
                    "title": "Table",
                    "description": "",
                    "value": [
                        {
                            "_id": "65c7643b72de876e31fc30f7",
                            "deleted": false,
                            "cells": {
                                "65c7643b970dfa70f906eacf": "Hi, First Row",
                                "65c7643b7afdd89dda43bf28": "65c7643b8157b971f6c65174",
                                "65c7643bce0aff8c2346400d": "last column, first row"
                            }
                        },
                        {
                            "_id": "65c7643b7bc07d67096dfeb3",
                            "deleted": false,
                            "cells": {
                                "65c7643b970dfa70f906eacf": "",
                                "65c7643b7afdd89dda43bf28": "65c7643b9c4d5149e7fe997a"
                            }
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacde",
                            "deleted": false,
                            "cells": {
                                "65c7643b970dfa70f906eacf": "Last Row, First column",
                                "65c7643bce0aff8c2346400d": "last, last"
                            }
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdf",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdg",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdh",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdi",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdj",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdk",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdl",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdm",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdn",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdo",
                            "deleted": false
                        },
                        {
                            "_id": "65c7643b0100c4d3899dacdp",
                            "deleted": false
                        },

                    ],
                    "required": false,
                    "tipTitle": "",
                    "tipDescription": "",
                    "tipVisible": false,
                    "metadata": {},
                    "rowOrder": [
                        "65c7643b72de876e31fc30f7",
                        "65c7643b7bc07d67096dfeb3",
                        "65c7643b0100c4d3899dacde",
                        "65c7643b0100c4d3899dacdf",
                        "65c7643b0100c4d3899dacdg",
                        "65c7643b0100c4d3899dacdh",
                        "65c7643b0100c4d3899dacdi",
                        "65c7643b0100c4d3899dacdj",
                        "65c7643b0100c4d3899dacdk",
                        "65c7643b0100c4d3899dacdl",
                        "65c7643b0100c4d3899dacdm",
                        "65c7643b0100c4d3899dacdn",
                        "65c7643b0100c4d3899dacdo",
                        "65c7643b0100c4d3899dacdp"
                    ],
                    "tableColumns": [
                        {
                            "_id": "65c7643b970dfa70f906eacf",
                            "type": "text",
                            "title": "Text Column",
                            "width": 0,
                            "identifier": "field_column_65c77d9ed79e7e7cc5ef0f3e"
                        },
                        {
                            "_id": "65c7643b7afdd89dda43bf28",
                            "type": "dropdown",
                            "title": "Dropdown Column",
                            "width": 0,
                            "identifier": "field_column_65c77d9e726506a0ed24eab8",
                            "options": [
                                {
                                    "_id": "65c7643b9c4d5149e7fe997a",
                                    "value": "Yes",
                                    "deleted": false
                                },
                                {
                                    "_id": "65c7643b83ed521e925907f8",
                                    "value": "No",
                                    "deleted": false
                                },
                                {
                                    "_id": "65c7643b8157b971f6c65174",
                                    "value": "N/A",
                                    "deleted": false
                                }
                            ]
                        },
                        {
                            "_id": "65c7643bce0aff8c2346400d",
                            "type": "text",
                            "title": "Text Column",
                            "width": 0,
                            "identifier": "field_column_65c77d9ec51d700b47d4f9f2"
                        }
                    ],
                    "tableColumnOrder": [
                        "65c7643b970dfa70f906eacf",
                        "65c7643b7afdd89dda43bf28",
                        "65c7643bce0aff8c2346400d"
                    ],
                    "file": "65c7637bcca019774a4ca5e2"
                }
"""
