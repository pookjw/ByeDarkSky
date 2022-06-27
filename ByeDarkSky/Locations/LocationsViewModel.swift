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

actor LocationsViewModel: NSObject, ObservableObject {
    @MainActor @Published var locations: [Location] = []
    private var statusContinuations: [CLLocationManager: CheckedContinuation<CLAuthorizationStatus, Never>] = [:]
    private var clLocationContinuations: [CLLocationManager: CheckedContinuation<CLLocation, Error>] = [:]
    private let clGeocoder: CLGeocoder = .init()
    private let weatherService: WeatherService = .shared
    private let measurementFormatter: MeasurementFormatter = .init()
    
    nonisolated func addCurrentLocation() async throws {
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
                Task { [weak self] in
                    await self?.add(statusContinuation: continuation, clLocationManager: clLocationManager)
                    clLocationManager.requestWhenInUseAuthorization()
                }
            }
            await removeStatusContinuation(with: clLocationManager)
            
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
        
        log.info("Authorized!")
        
        let clLocation: CLLocation = try await withCheckedThrowingContinuation { [weak self, clLocationManager] continuation in
            Task { [weak self] in
                await self?.add(clLocationContinuation: continuation, clLocationManager: clLocationManager)
                clLocationManager.requestLocation()
            }
        }
        await removeCLLocationContinuation(with: clLocationManager)
        
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
    
    func deleteLocation(at indexSet: IndexSet) async {
        var locations: [Location] = await locations
        indexSet.forEach { index in
            locations.remove(at: index)
        }
        await MainActor.run { [weak self, locations] in
            self?.locations = locations
        }
    }
    
    func delete(location: Location) async {
        var locations: [Location] = await locations
        locations.removeAll { $0 == location }
        await MainActor.run { [weak self, locations] in
            self?.locations = locations
        }
    }
    
    private func add(statusContinuation: CheckedContinuation<CLAuthorizationStatus, Never>, clLocationManager: CLLocationManager) {
        statusContinuations[clLocationManager] = statusContinuation
    }
    
    private func add(clLocationContinuation: CheckedContinuation<CLLocation, Error>, clLocationManager: CLLocationManager) {
        clLocationContinuations[clLocationManager] = clLocationContinuation
    }
    
    private func removeStatusContinuation(with clLocationManager: CLLocationManager) {
        statusContinuations.removeValue(forKey: clLocationManager)
    }
    
    private func removeCLLocationContinuation(with clLocationManager: CLLocationManager) {
        clLocationContinuations.removeValue(forKey: clLocationManager)
    }
}

extension LocationsViewModel: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task.detached { [weak self] in
            guard let statusContinuation: CheckedContinuation<CLAuthorizationStatus, Never> = await self?.statusContinuations[manager] else {
                log.warning("Failed to find Continunation - is it canceled?")
                return
            }
            
            statusContinuation.resume(returning: manager.authorizationStatus)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task.detached { [weak self] in
            guard let clLocationContinuation: CheckedContinuation<CLLocation, Error> = await self?.clLocationContinuations[manager] else {
                log.warning("Failed to find Continunation - is it canceled?")
                return
            }
            
            clLocationContinuation.resume(throwing: error)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task.detached { [weak self] in
            guard let clLocationContinuation: CheckedContinuation<CLLocation, Error> = await self?.clLocationContinuations[manager] else {
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
}
