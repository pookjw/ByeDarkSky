//
//  WeatherView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI
import CoreLocation
import WeatherKit

struct WeatherTempItemView: View {
    let symbolName: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: symbolName)
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct WeatherView: View {
    @EnvironmentObject var mainEnvironmnetObject: MainEnvironmentObject
    @StateObject private var viewModel: WeatherViewModel = .init()
    @MainActor @State private var error: Error?
    
    var body: some View {
        List(Array(viewModel.items.keys), id: \.self, rowContent: { key in
            Section(key) {
                ForEach(viewModel.items[key] ?? []) { item in
                    switch item {
                    case let .image(primaryText, secondaryText, symbolName):
                        WeatherTempItemView(symbolName: symbolName, title: primaryText, value: secondaryText)
                    }
                }
            }
        })
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .onReceive($mainEnvironmnetObject.selectedLocation.wrappedValue.publisher) { selectedLocation in
                Task.detached {
                    do {
                        try await viewModel.request(using: selectedLocation)
                    } catch {
                        await MainActor.run {
                            self.error = error
                        }
                    }
                }
            }
            .alert("Error (번역)", isPresented: .constant(error != nil), actions: {}, message: {
                if let error {
                    Text(String("\(error)"))
                }
            })
    }
}

//struct WeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherView()
//    }
//}
