//
//  LocationsViewModel.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI
import CoreLocation
import WeatherKit
import ByeDarkSkyCore

final class LocationsViewModel: NSObject, ObservableObject {
    @MainActor @Published var locations: [Location] = []
    private var statusContinuations: [CLLocationManager: CheckedContinuation<CLAuthorizationStatus, Never>] = [:]
    private var clLocationContinuations: [CLLocationManager: CheckedContinuation<CLLocation, Error>] = [:]
    private let clGeocoder: CLGeocoder = .init()
    private let weatherService: WeatherService = .shared
    private let measurementFormatter: MeasurementFormatter = .init()
    
    func addCurrentLocation() async throws {
        let clLocationManager: CLLocationManager = await MainActor.run { [weak self] in
            /*
             Core Location calls the methods of your delegate object on the runloop from the thread on which you initialized CLLocationManager. That thread must itself have an active run loop, like the one found in your app’s main thread.
             https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate
             */
            let clLocationManager: CLLocationManager = .init()
            clLocationManager.delegate = self
            return clLocationManager
        }
        
        switch clLocationManager.authorizationStatus {
        case .notDetermined:
            let status: CLAuthorizationStatus = await withCheckedContinuation { [weak self, clLocationManager] continuation in
                self?.statusContinuations[clLocationManager] = continuation
                clLocationManager.requestWhenInUseAuthorization()
            }
            statusContinuations.removeValue(forKey: clLocationManager)
            
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                break
            default:
                throw BDSError.failedToGetLocationAuthorization
            }
        case .denied, .restricted:
            throw BDSError.failedToGetLocationAuthorization
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw BDSError.failedToGetLocationAuthorization
        }
        
        log.info("Authorized")
        
        let clLocation: CLLocation = try await withCheckedThrowingContinuation { [weak self, clLocationManager] continuation in
            self?.clLocationContinuations[clLocationManager] = continuation
            clLocationManager.requestLocation()
        }
        clLocationContinuations.removeValue(forKey: clLocationManager)
        
        async let currentWeather: CurrentWeather = weatherService.weather(for: clLocation, including: .current)
        async let clPlacemarks: [CLPlacemark] = clGeocoder.reverseGeocodeLocation(clLocation)
        guard let clPlacemark: CLPlacemark = try await clPlacemarks.first else {
            throw BDSError.noLocationFound
        }
        let location: Location = try await .init(clLocation: clLocation,
                                                 symbolName: currentWeather.symbolName,
                                                 title: clPlacemark.name ?? "(no name 번역)",
                                                 temperature: measurementFormatter.string(from: currentWeather.temperature),
                                                 condition: currentWeather.condition.localizedString)
        
        await MainActor.run { [weak self] in
            self?.locations.insert(location, at: 0)
        }
    }
    
    func deleteLocation(at indexSet: IndexSet) async throws {
        var locations: [Location] = await locations
        indexSet.forEach { index in
            locations.remove(at: index)
        }
        await MainActor.run { [weak self, locations] in
            self?.locations = locations
        }
    }
}

extension LocationsViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let statusContinuation: CheckedContinuation<CLAuthorizationStatus, Never> = statusContinuations[manager] else {
            log.warning("Failed to find Continunation - is it canceled?")
            return
        }
        
        statusContinuation.resume(returning: manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clLocationContinuation: CheckedContinuation<CLLocation, Error> = clLocationContinuations[manager] else {
            log.warning("Failed to find Continunation - is it canceled?")
            return
        }
        
        clLocationContinuation.resume(throwing: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let clLocationContinuation: CheckedContinuation<CLLocation, Error> = clLocationContinuations[manager] else {
            log.warning("Failed to find Continunation - is it canceled?")
            return
        }
        
        guard let clLocation: CLLocation = locations.first else {
            clLocationContinuation.resume(throwing: BDSError.noLocationFound)
            return
        }
        
        clLocationContinuation.resume(returning: clLocation)
    }
}
