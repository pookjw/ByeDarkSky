//
//  Location.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/27/22.
//

@preconcurrency import CoreLocation

struct Location: Identifiable, Hashable, Sendable {
    let clLocation: CLLocation
    let symbolName: String
    let title: String
    let temperature: String
    let condition: String
    
    var id: Int { hashValue }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(clLocation)
        hasher.combine(symbolName)
        hasher.combine(title)
        hasher.combine(temperature)
        hasher.combine(condition)
    }
}
