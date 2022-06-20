//
//  LocationsView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI
import CoreLocation

struct LocationsView: View {
    @State private var error: Error?
    @ObservedObject private var viewModel: LocationsViewModel = .init()
    
    var body: some View {
        List(viewModel.locations, rowContent: { location in
            Text(String("\(location.clPlacemark.name!)"))
        })
            .navigationTitle(Localizable.LOCATIONS.localizedString)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            Task { [viewModel] in
                                do {
                                    try await viewModel.addCurrentLocation()
                                } catch {
                                    self.error = error
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
                    .menuOrder(.automatic)
                }
            }
            .alert("Error (번역)", isPresented: .constant(error != nil), actions: {
                
            }, message: {
                if let error {
                    Text(String("\(error)"))
                }
            })
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
    }
}
