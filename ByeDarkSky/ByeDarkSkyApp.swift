//
//  ByeDarkSkyApp.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI

@main
struct ByeDarkSkyApp: App {
    @State private var selectedLocation: Location?
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
                LocationsView(selectedLocation: $selectedLocation, viewModel: LocationsViewModel())
            } detail: {
                WeatherView(location: $selectedLocation)
            }
            .navigationSplitViewStyle(.balanced)
        }
    }
}
