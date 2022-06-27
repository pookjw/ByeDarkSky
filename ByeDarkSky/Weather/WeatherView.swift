//
//  WeatherView.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        Text(String(describing: mainViewModel.selectedLocation))
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

//struct WeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherView()
//    }
//}
