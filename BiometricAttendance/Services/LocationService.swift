import CoreLocation
import Foundation

enum LocationError: LocalizedError {
    case permissionDenied
    case unavailable
    case outOfRange(Double)
    case timeout

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location access denied. Please enable it in Settings > Privacy > Location Services."
        case .unavailable:
            return "Unable to determine your location. Please try again."
        case .outOfRange(let dist):
            return String(format: "You are %.0f metres from the office. Please be on office premises to mark attendance.", dist)
        case .timeout:
            return "Location request timed out. Please check your GPS signal and try again."
        }
    }
}

// MARK: - Office Configuration
struct OfficeConfig {
    /// Set your office coordinates here
    static let latitude:  CLLocationDegrees = 6.721746
    static let longitude: CLLocationDegrees = 3.502094
    static let allowedRadius: CLLocationDistance = 200  // metres
}

final class LocationService: NSObject {
    static let shared = LocationService()
    private override init() { super.init(); manager.delegate = self }

    private let manager = CLLocationManager()
    private var completion: ((Result<CLLocation, LocationError>) -> Void)?
    private var timer: Timer?

    func verifyOfficeLocation(completion: @escaping (Result<CLLocation, LocationError>) -> Void) {
        self.completion = completion

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            completion(.failure(.permissionDenied))
        default:
            startUpdating()
        }
    }

    private func startUpdating() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()

        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { [weak self] _ in
            self?.manager.stopUpdatingLocation()
            self?.completion?(.failure(.timeout))
            self?.completion = nil
        }
    }

    private func handle(location: CLLocation) {
        timer?.invalidate()
        timer = nil
        manager.stopUpdatingLocation()

        let office = CLLocation(latitude: OfficeConfig.latitude, longitude: OfficeConfig.longitude)
        let distance = location.distance(from: office)

        if distance <= OfficeConfig.allowedRadius {
            completion?(.success(location))
        } else {
            completion?(.failure(.outOfRange(distance)))
        }
        completion = nil
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last, loc.horizontalAccuracy >= 0 else { return }
        handle(location: loc)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        timer?.invalidate(); timer = nil
        completion?(.failure(.unavailable))
        completion = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        case .denied, .restricted:
            completion?(.failure(.permissionDenied))
            completion = nil
        default: break
        }
    }
}
