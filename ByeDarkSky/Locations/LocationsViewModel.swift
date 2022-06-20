//
//  LocationsViewModel.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/20/22.
//

import SwiftUI
import CoreLocation
import ByeDarkSkyCore

final actor LocationsViewModel: NSObject, ObservableObject {
    @MainActor @Published var locations: [Location] = []
    private var statusContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var clLocationContinuation: CheckedContinuation<CLLocation, Error>?
    private let clLocationManager: CLLocationManager = .init()
    private let clGeocoder: CLGeocoder = .init()
    
    override init() {
        super.init()
        clLocationManager.delegate = self
    }
    
    func addCurrentLocation() async throws {
        switch clLocationManager.authorizationStatus {
        case .notDetermined:
            let status: CLAuthorizationStatus = await withCheckedContinuation { continuation in
                statusContinuation = continuation
                clLocationManager.requestWhenInUseAuthorization()
            }
            
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
        
        let clLocation: CLLocation = try await withCheckedThrowingContinuation { continuation in
            clLocationContinuation = continuation
            clLocationManager.requestLocation()
        }
        
        guard let clPlacemark: CLPlacemark = try await clGeocoder.reverseGeocodeLocation(clLocation).first else {
            throw BDSError.noLocationFound
        }
        
        await MainActor.run { [weak self] in
            self?.locations.append(.init(clPlacemark: clPlacemark))
        }
    }
    
    private func clearStatusContinuation() {
        statusContinuation = nil
    }
    
    private func clearCLLocationContinuation() {
        clLocationContinuation = nil
    }
}

extension LocationsViewModel: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { [weak self] in
            await self?.statusContinuation?.resume(returning: manager.authorizationStatus)
            await self?.clearStatusContinuation()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { [weak self] in
            if let locationContinuation: CheckedContinuation<CLLocation, Error> = await self?.clLocationContinuation {
                locationContinuation.resume(throwing: error)
                await self?.clearCLLocationContinuation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { [weak self] in
            if let locationContinuation: CheckedContinuation<CLLocation, Error> = await self?.clLocationContinuation {
                if let location: CLLocation = locations.first {
                    locationContinuation.resume(returning: location)
                } else {
                    locationContinuation.resume(throwing: BDSError.noLocationFound)
                }
                
                await self?.clearStatusContinuation()
            }
        }
    }
}
