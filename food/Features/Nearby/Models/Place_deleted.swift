////
////  Place.swift
////  food
////
////  Created by toyousoft on 2024/11/04.
////
//import SwiftUI
//import MapKit
//class Place: NSObject, MKAnnotation, Identifiable {
//    let id: String
//    let name: String
//    let coordinate: CLLocationCoordinate2D
//    let image: String
//    let sponsored: Bool
//    
//    // 使用计算属性包装私有存储属性
//    private var _cachedDistance: Double?
//    var cachedDistance: Double? {
//        get { _cachedDistance }
//        set { _cachedDistance = newValue }
//    }
//    
//    var title: String? { name }
//    
//    init(id: String = UUID().uuidString,
//         name: String,
//         latitude: Double,
//         longitude: Double,
//         sponsored: Bool = false) {
//        self.id = id
//        self.name = name
//        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        self.image = "placeholder"
//        self.sponsored = sponsored
//        super.init()
//    }
//    
//}
//extension Place {
//    func updateDistance(from coordinate: CLLocationCoordinate2D) {
//        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        let placeLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
//        self.cachedDistance = placeLocation.distance(from: location)
//    }
//    
//    func isWithinDistance(_ threshold: Double, from coordinate: CLLocationCoordinate2D) -> Bool {
//        if cachedDistance == nil {
//            updateDistance(from: coordinate)
//        }
//        return cachedDistance ?? .infinity <= threshold
//    }
//}
