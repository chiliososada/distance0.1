//
//  HomeViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/05.
//

import SwiftUI
import CoreLocation

final class HomeViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var isShowingPostInputView = false
    @Published var isViewTabBarHidden = false
    @Published var showMenu = false
    @Published var offset: CGFloat = 0
    @Published var lastStoredOffset: CGFloat = 0
    @Published var search: String = ""
    @Published var userLocationText = ""
    @Published var locationManager = LocationManager.shared
    @Published var isNavigationBarHidden: Bool = false
    @Published var tabState: Visibility = .visible
    
    private var isInteracting = false
    private var previousLocation: CLLocation?
    
    let sideBarWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    
    var isHomeTab: Bool {
        selectedTab == 0
    }
    
    init() {
        isNavigationBarHidden = false
        tabState = .visible
        setupLocationUpdates()
    }
    
    // MARK: - Setup Methods
    private func setupLocationUpdates() {
        // 监听位置更新
        locationManager.locationUpdated = { [weak self] coordinate in
            self?.handleLocationUpdate(CLLocation(latitude: coordinate.latitude,
                                                longitude: coordinate.longitude))
        }
    }
    
    // MARK: - Location Methods
    private func handleLocationUpdate(_ location: CLLocation) {
        // 检查是否需要更新（位置变化超过100米）
        if let previous = previousLocation,
           location.distance(from: previous) < 1000 {
            return
        }
        
        previousLocation = location
        
        // 使用 LocationManager 的 reverseGeocode 方法
        locationManager.reverseGeocode(coordinate: location.coordinate) { [weak self] placemark in
            guard let self = self,
                  let placemark = placemark else { return }
            
            var components: [String] = []
            
            if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                components.append(subLocality)
            }
            if let locality = placemark.locality, !locality.isEmpty {
                components.append(locality)
            }
            if let area = placemark.administrativeArea, !area.isEmpty {
                components.append(area)
            }
            
            self.userLocationText = components.joined(separator: ", ")
        }
    }
    
    // MARK: - Menu Control Methods
    func closeMenu() {
        guard !isInteracting else { return }
        isInteracting = true
        
        withAnimation {
            showMenu = false
            offset = 0
        }
        
        resetInteractionState()
    }
    
    func toggleMenu() {
        guard !isInteracting else { return }
        isInteracting = true
        
        withAnimation {
            showMenu.toggle()
        }
        
        resetInteractionState()
    }
    
    private func resetInteractionState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isInteracting = false
        }
    }
}
