//
//  DismissButton.swift
//  food
//
//  Created by toyousoft on 2024/11/06.
//

import SwiftUI

struct DismissButton: View {
    let dismiss: DismissAction
    let selectedTab: TabRoute
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: PostInputViewModel
    @State private var showingActionSheet = false
    
    var body: some View {
        Button(action: handleDismiss) {
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundColor(.black)
        }
        .modifier(DraftActionSheet(
            isPresented: $showingActionSheet,
            onSave: {
                viewModel.saveDraft()
                dismissView()
            },
            onDelete: {
                viewModel.clearDraft()
                dismissView()
            }
        ))
    }
    
    private func handleDismiss() {
        if viewModel.showDraftActionSheet() {
            showingActionSheet = true
        } else {
            dismissView()
        }
    }
    
    private func dismissView() {
        withAnimation {
            AppNavigationManager.shared.switchTab(to: selectedTab)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isPresented = false
                dismiss()
            }
        }
    }
}
