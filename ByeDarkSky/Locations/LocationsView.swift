//
//  LocationsView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI
import CoreLocation

struct LocationsView: View {
    @EnvironmentObject var mainEnvironmnetObject: MainEnvironmentObject
    @StateObject private var viewModel: LocationsViewModel = .init()
    @MainActor @State private var error: Error?
    
    var body: some View {
        List(selection: $mainEnvironmnetObject.selectedLocation) {
            ForEach(viewModel.locations, id: \.clLocation) { location in
                HStack {
                    Image(systemName: location.symbolName)
                    
                    VStack(alignment: .leading) {
                        Text(location.title)
                        Text(location.condition)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(location.temperature)
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.secondary)
                }
                .contextMenu {
                    Button {
                        Task.detached {
                            await viewModel.delete(location: location)
                        }
                    } label: {
                        Image(systemName: "trash")
                        Text("Delete (번역)")
                    }
                }
            }
            .onDelete { indexSet in
                Task.detached {
                    await viewModel.deleteLocation(at: indexSet)
                }
            }
        }
        .animation(.easeOut, value: viewModel.locations)
        .navigationTitle(Localizable.LOCATIONS.localizedString)
        .toolbar {
#if os(macOS)
            ToolbarItem(placement: .automatic) {
                Button {
                    Task.detached {
                        do {
                            try await viewModel.addCurrentLocation()
                        } catch {
                            await MainActor.run {
                                self.error = error
                            }
                        }
                    }
                } label: {
                    Image(systemName: "location")
                }
            }
#else
            ToolbarItem(placement: .automatic) {
                EditButton()
            }
            
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button {
                        Task.detached {
                            do {
                                try await viewModel.addCurrentLocation()
                            } catch {
                                await MainActor.run {
                                    self.error = error
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "location")
                        Text("Add from Current Location (번역)")
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "map")
                        Text("Add from Maps (번역)")
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .menuOrder(.fixed)
            }
#endif
        }
        .alert("Error (번역)", isPresented: .constant(error != nil), actions: {}, message: {
            if let error {
                Text(String("\(error)"))
            }
        })
    }
}

#if DEBUG
//fileprivate struct LocationsView_Previews: PreviewProvider {
////    private final class LocationsViewMockModel: LocationsViewModel {
////        var locations: [Location] = [
////
////        ]
////
////        func addCurrentLocation() async throws {
////
////        }
////    }
//    
//    static var previews: some View {
//        LocationsView()
//    }
//}
#endif
