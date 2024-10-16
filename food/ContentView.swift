//
//  ContentView.swift
//  food
//
//  Created by Abu Anwar MD Abdullah on 25/1/21.
//

import SwiftUI

struct ContentView: View {
    
    
    var body: some View {
        VStack {
           // HomeView()
            HomeLoginView() 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabBarManager()) // Injecting the TabBarManager environment object
    }
}



