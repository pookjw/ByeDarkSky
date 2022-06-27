//
//  WeatherItem.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/28/22.
//

import Foundation

enum WeatherItem: Identifiable, Hashable {
    case image(primaryText: String, secondaryText: String, symbolName: String)
//    case graph
    
    var id: Int { hashValue }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .image(primaryText, secondaryText, symbolName):
            hasher.combine(primaryText)
            hasher.combine(secondaryText)
            hasher.combine(symbolName)
        }
    }
}
