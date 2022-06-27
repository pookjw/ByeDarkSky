//
//  MainView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/27/22.
//

import SwiftUI
import CoreLocation

actor MainEnvironmentObject: ObservableObject {
    @MainActor @Published var selectedLocation: CLLocation?
}

struct MainView: View {
    @StateObject var mainEnvironmnetObject: MainEnvironmentObject = .init()
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            LocationsView()
        } detail: {
            WeatherView()
        }
        .navigationSplitViewStyle(.balanced)
        .environmentObject(mainEnvironmnetObject)
    }
}
