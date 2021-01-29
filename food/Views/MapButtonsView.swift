//
//  MapBottonView.swift
//  food
//
//  Created by toyousoft on 2024/09/27.
//

import SwiftUI
import MapKit

struct MapButtonsView: View {
    @State private var searchText = "" // 用于存储搜索框的输入内容
    @Binding var position : MapCameraPosition
    @Binding var searchResults: [MKMapItem]
    @State private var search: String = ""
    var visibleRegin: MKCoordinateRegion?
    
    
     
        var body: some View {
                VStack(spacing: 5) { // 使用 VStack 使内容垂直排列
                    // 搜索框
//                    TextField("请搜索你要关心的事情", text: $searchText, onCommit: {
//                        search(for: searchText) // 用户点击 return 键时，执行搜索
//                    })
//                    .textFieldStyle(.roundedBorder)
//                    .padding(.horizontal)
                    SearchAndFilterView(search: $search)
                    // 按钮区域
                    HStack(spacing: 10) { // 内部 VStack 使按钮垂直排列
                        Button {
                            search(for: "playground")
                        } label: {
                            Label("", systemImage: "flame.fill")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            search(for: "beach")
                        } label: {
                            Label("", systemImage: "location.fill")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            position = .region(.boston)
                        } label: {
                            Label("", systemImage: "building.2")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            position = .region(.northShore)
                        } label: {
                            Label("", systemImage: "water.waves")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                
                .background(Color.clear) // 使用系统的 Material 背景样式
               
              
    }
    
    // 搜索功能
       func search(for query: String) {
           let request = MKLocalSearch.Request()
           request.naturalLanguageQuery = query
           request.resultTypes = .pointOfInterest
           
           request.region = visibleRegin ?? MKCoordinateRegion(
               center: .parking,
               span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
           )

           Task {
               let search = MKLocalSearch(request: request)
               let response = try? await search.start()
               searchResults = response?.mapItems ?? []
           }
       }
}


