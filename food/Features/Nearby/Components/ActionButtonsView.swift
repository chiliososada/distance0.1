//
//  ActionButtonsView.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import  SwiftUI

struct ActionButtonsView: View {
    var viewModel: NearbyViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.handleHotspotsTap()
            } label: {
                Label("", systemImage: "flame.fill")
            }
            .buttonStyle(.borderedProminent)

            Button {
                viewModel.handleLocationTap()
            } label: {
                Label("", systemImage: "location.fill")
            }
            .buttonStyle(.bordered)

            Button {
                viewModel.handleBuildingsTap()
            } label: {
                Label("", systemImage: "building.2")
            }
            .buttonStyle(.bordered)

            Button {
                viewModel.handleWavesTap()
            } label: {
                Label("", systemImage: "water.waves")
            }
            .buttonStyle(.bordered)
        }
    }
}
