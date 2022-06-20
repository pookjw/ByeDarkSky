//
//  WeatherKitTests.swift
//  ByeDarkSkyCoreTests
//
//  Created by Jinwoo Kim on 6/20/22.
//

import XCTest
import WeatherKit
import CoreLocation
@testable import ByeDarkSkyCore

final class WeatherKitTests: XCTestCase {
    private var weatherService: WeatherService!
    
    override func setUp() async throws {
        try await super.setUp()
        weatherService = .shared
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        weatherService = nil
    }
    
    func test_getWeather() async throws {
        let seoulLocation: CLLocation = .init(latitude: 37.532600, longitude: 127.024612)
        let _: Weather = try await weatherService.weather(for: seoulLocation)
    }
}
