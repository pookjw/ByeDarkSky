//
//  WeatherView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    @Binding var location: CLLocation?
    
    var body: some View {
        Text(String(describing: location))
            .navigationBarTitleDisplayMode(.inline)
    }
}

//struct WeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherView()
//    }
//}
