import Combine
import CoreLocation
import Foundation

final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var coordinate: PrayerCoordinate?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var errorMessage: AppMessage?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.distanceFilter = 5_000
        authorizationStatus = manager.authorizationStatus
    }

    func requestCurrentLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = .locationServicesDisabled
            return
        }

        errorMessage = nil
        authorizationStatus = manager.authorizationStatus

        let status = manager.authorizationStatus

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorized, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = .locationAccessNotAvailable
        @unknown default:
            errorMessage = .locationStatusUnsupported
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationAllowsLocation(manager.authorizationStatus) {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        coordinate = PrayerCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        errorMessage = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = .raw(error.localizedDescription)
    }

    private func authorizationAllowsLocation(_ status: CLAuthorizationStatus) -> Bool {
        #if os(macOS)
            status == .authorized || status == .authorizedAlways
        #else
            status == .authorizedAlways || status == .authorizedWhenInUse
        #endif
    }
}
