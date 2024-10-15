//
//  HomeNavBarView.swift
//  food
//
//  Created by Abu Anwar MD Abdullah on 25/1/21.
//

import SwiftUI

struct HomeNavBarView: View {
    var body: some View {
        HStack {
            // Menu Button
            Image(uiImage: #imageLiteral(resourceName: "menu"))
                .onTapGesture {
                    handleMenuTap()
                }
            Spacer()
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .foregroundColor(.gray)
            
            Text("東京都 葛飾区 立石")
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding()
    }
    
    // Function to handle menu tap event
    func handleMenuTap() {
        print("Menu tapped")
        // Add your action here (e.g., open a side menu, navigate to another view)
    }
    
    // Function to handle notifications tap event
    func handleNotificationsTap() {
        print("Notifications tapped")
        // Add your action here (e.g., open notifications list)
    }
}

struct HomeNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        HomeNavBarView()
    }
}
