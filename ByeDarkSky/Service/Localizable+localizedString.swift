//
//  Localizable+localizedString.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import Foundation

extension Localizable {
    var localizedString: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
