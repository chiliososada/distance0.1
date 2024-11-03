//
//  MapBottonView.swift
//  food
//
//  Created by toyousoft on 2024/09/27.
//

import SwiftUI
import MapKit
extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 35.765, longitude: 139.8485)  // 替换为你的坐标
    static let parking1 = CLLocationCoordinate2D(latitude: 35.764, longitude: 139.8486)  // 替换为你的坐标
}
extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.360256,
            longitude: -71.057279
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
        )
    )

    static let northShore = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.547408,
            longitude: -70.870085
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5
        )
    )
}
struct MapButtonsView: View {
    @State private var searchText = "" // 用于存储搜索框的输入内容
    @Binding var position : MapCameraPosition
    @Binding var searchResults: [MKMapItem]
    @State private var search: String = ""
    var visibleRegin: MKCoordinateRegion?
    
    
     
        var body: some View {
                VStack(spacing: 5) { // 使用 VStack 使内容垂直排列
                    // 搜索框
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

// 为 MapButtonsView 添加 SwiftUI 预览
struct MapButtonsView_Previews: PreviewProvider {
    @State static var position: MapCameraPosition = .automatic
    @State static var searchResults: [MKMapItem] = []
    
    static var previews: some View {
        MapButtonsView(position: $position, searchResults: $searchResults)
    }
}
