//
//  Location.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import CoreLocation

struct Location: Identifiable {
    let clPlacemark: CLPlacemark
    
    var id: Int { clPlacemark.hash }
}
