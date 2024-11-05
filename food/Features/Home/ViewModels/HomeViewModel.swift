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
    @Published var tabState: Visibility = .visible
    @Published var showMenu = false
    @Published var offset: CGFloat = 0
    @Published var lastStoredOffset: CGFloat = 0
    @Published var search: String = ""
    @Published var isNavigationBarHidden = false
    @Published var userLocationText = ""
    @Published var locationManager = LocationManager.shared
    
    private var isInteracting = false
    private var previousLocation: CLLocation?
    
    let sideBarWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    
    var isHomeTab: Bool {
          selectedTab == 0
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
    
    // MARK: - Location Methods
    func updateLocationText() {
        guard let location = locationManager.userLocation else { return }
        
        if let previous = previousLocation, location.distance(from: previous) < 100 {
            return
        }
        
        previousLocation = location
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else { return }
            
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
            
            DispatchQueue.main.async {
                self.userLocationText = components.joined(separator: ", ")
            }
        }
    }
}
