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
        VStack {
            Image(systemName: symbolName)
            Text(title)
            Text(value)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
                .opacity(0.1)
        }
        .cornerRadius(20, antialiased: true)
    }
}

struct WeatherView: View {
    @EnvironmentObject var mainEnvironmnetObject: MainEnvironmentObject
    @StateObject private var viewModel: WeatherViewModel = .init()
    @MainActor @State private var error: Error?
    @MainActor @State private var itemSize: CGSize = .init(width: 150, height: 150)
    
    var body: some View {
        List(Array(viewModel.items.keys), id: \.self, rowContent: { key in
            Section(key) {
                WeatherLayout(itemSize: itemSize, horizontalContentMode: .fit) {
                    ForEach(viewModel.items[key] ?? []) { item in
                        switch item {
                        case let .image(primaryText, secondaryText, symbolName):
                            WeatherTempItemView(symbolName: symbolName, title: primaryText, value: secondaryText)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .animation(.easeOut, value: itemSize)
        })
            .listStyle(PlainListStyle())
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Test") {
                        itemSize = .init(width: .random(in: 100...300), height: .random(in: 100...300))
                    }
                }
            }
//            .frame(minWidth: itemSize.width, minHeight: itemSize.height)
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
