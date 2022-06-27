//
//  WeatherViewModel.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/27/22.
//

import SwiftUI
import CoreLocation
import WeatherKit
import ByeDarkSkyCore

actor WeatherViewModel: ObservableObject {
    @MainActor @Published private(set) var items: [String: [WeatherItem]] = [:]
    private let weatherService: WeatherService = .shared
    private let measurementFormatter: MeasurementFormatter = .init()
    private var currentCLLocation: CLLocation?
    
    nonisolated func request(using clLocation: CLLocation) async throws {
        if let currentCLLocation: CLLocation = await currentCLLocation,clLocation.isEqual(currentCLLocation) {
            return
        }
        await setCurrentCLLocation(clLocation)
        log.info("Requested: \(clLocation)")
        
        let weather: Weather = try await weatherService.weather(for: clLocation)
        let currentWeather: CurrentWeather = weather.currentWeather
        
        let currentWeatherItems: [WeatherItem] = [
            .image(primaryText: "체감 온도 (번역)", secondaryText: measurementFormatter.string(from: currentWeather.apparentTemperature), symbolName: currentWeather.symbolName),
            .image(primaryText: "이슬점 (번역)", secondaryText: measurementFormatter.string(from: currentWeather.dewPoint), symbolName: "allergens"),
            .image(primaryText: "습도 (번역)", secondaryText: String(currentWeather.humidity), symbolName: "humidity"),
            .image(primaryText: "온도 (번역)", secondaryText: measurementFormatter.string(from: currentWeather.temperature), symbolName: "thermometer"),
            .image(primaryText: "대기압 (번역)", secondaryText: measurementFormatter.string(from: currentWeather.pressure), symbolName: "rectangle.compress.vertical"),
            .image(primaryText: "대기압 상태 (번역)", secondaryText: currentWeather.pressureTrend.description, symbolName: {
                switch currentWeather.pressureTrend {
                case .rising:
                    return "arrow.up"
                case .falling:
                    return "arrow.down"
                case .steady:
                    return "minus"
                @unknown default:
                    return "rectangle.compress.vertical"
                }
            }()),
            .image(primaryText: "풍향 (번역)", secondaryText: "\(currentWeather.wind.compassDirection.description) (\(measurementFormatter.string(from: currentWeather.wind.direction)))", symbolName: "wind"),
            .image(primaryText: "돌풍 속력 (번역)", secondaryText: {
                if let gust: Measurement<UnitSpeed> = currentWeather.wind.gust {
                    return measurementFormatter.string(from: gust)
                } else {
                    return "(데이터 없음) (번역)"
                }
            }(), symbolName: "wind"),
            .image(primaryText: "풍속 (번역)", secondaryText: measurementFormatter.string(from: currentWeather.wind.speed), symbolName: "wind"),
            .image(primaryText: "운량 (번역)", secondaryText: String(currentWeather.cloudCover), symbolName: "cloud"),
            .image(primaryText: "낮/밤 (번역)", secondaryText: currentWeather.isDaylight ? "낮 (번역)" : "밤 (번역)", symbolName: currentWeather.isDaylight ? "sun.max" : "moon"),
            .image(primaryText: "UV (번역)", secondaryText: "\(currentWeather.uvIndex.category.description) (\(currentWeather.uvIndex.value))", symbolName: "sun.max"),
            .image(primaryText: "가시성 (번역)", secondaryText: measurementFormatter.string(from: currentWeather.visibility), symbolName: "eye")
        ]
        
        let items: [String: [WeatherItem]] = [
            "현재 온도 (번역)": currentWeatherItems
        ]
        
        await withTaskCancellationHandler { [weak self] in
            await MainActor.run { [weak self] in
                self?.items = items
            }
        } onCancel: {
            log.info("Cancelled!")
        }
    }
    
    private func setCurrentCLLocation(_ clLocation: CLLocation) {
        self.currentCLLocation = clLocation
    }
}
