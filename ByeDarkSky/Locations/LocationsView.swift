//
//  LocationsView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI
import CoreLocation

struct LocationsView: View {
    @Binding var selectedLocation: Location?
    @StateObject var viewModel: LocationsViewModel
    @State private var error: Error?
    
    var body: some View {
        List(selection: $selectedLocation) {
            ForEach(viewModel.locations, id: \.self) { location in
                HStack {
                    Image(systemName: location.symbolName)

                    VStack(alignment: .leading) {
                        Text(location.title)
                        Text(location.condition)
                            .foregroundColor(Color(uiColor: .tertiaryLabel))
                    }

                    Spacer()

                    Text(location.temperature)
                    Image(systemName: "chevron.forward")
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                }
            }
            .onDelete { indexSet in
                Task.detached(priority: .medium) {
                    do {
                        try await viewModel.deleteLocation(at: indexSet)
                    } catch {
                        await MainActor.run {
                            self.error = error
                        }
                    }
                }
            }
        }
            .animation(.easeOut, value: viewModel.locations)
            .navigationTitle(Localizable.LOCATIONS.localizedString)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            Task.detached(priority: .medium) {
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
