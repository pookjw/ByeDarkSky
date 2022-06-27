//
//  MainView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/27/22.
//

import SwiftUI
import CoreLocation

actor MainViewModel: ObservableObject {
    @MainActor @Published var selectedLocation: CLLocation?
}

struct MainView: View {
    @StateObject var mainViewModel: MainViewModel = .init()
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            LocationsView()
        } detail: {
            WeatherView()
        }
        .navigationSplitViewStyle(.balanced)
        .environmentObject(mainViewModel)
    }
}
