//
//  WeatherView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI

struct WeatherView: View {
    @Binding var location: Location?
    
    var body: some View {
        Image(systemName: location?.symbolName ?? "folder")
            .navigationTitle(location?.title ?? .init())
            .navigationBarTitleDisplayMode(.inline)
    }
}

//struct WeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherView()
//    }
//}
