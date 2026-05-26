import LocalAuthentication
import Foundation

enum BiometricError: LocalizedError {
    case notAvailable
    case notEnrolled
    case authFailed
    case cancelled
    case lockout
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:  return "Biometric authentication is not available on this device."
        case .notEnrolled:   return "No biometrics are enrolled. Please register Face ID / Touch ID in Settings."
        case .authFailed:    return "Biometric authentication failed. Please try again."
        case .cancelled:     return "Authentication was cancelled."
        case .lockout:       return "Biometrics are locked out due to too many failed attempts."
        case .unknown(let m): return m
        }
    }
}

final class BiometricService {
    static let shared = BiometricService()
    private init() {}

    // Returns the available biometric type label
    var biometricType: String {
        let ctx = LAContext()
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
            return "Biometrics"
        }
        switch ctx.biometryType {
        case .faceID:   return "Face ID"
        case .touchID:  return "Touch ID"
        default:        return "Biometrics"
        }
    }

    var isBiometricAvailable: Bool {
        let ctx = LAContext()
        var err: NSError?
        return ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err)
    }

    /// Authenticate with biometrics (falls back to device passcode)
    func authenticate(reason: String, completion: @escaping (Result<Void, BiometricError>) -> Void) {
        let ctx = LAContext()
        ctx.localizedCancelTitle = "Cancel"
        var error: NSError?

        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let mapped = mapError(error)
            DispatchQueue.main.async { completion(.failure(mapped)) }
            return
        }

        ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                           localizedReason: reason) { success, evalError in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(self.mapError(evalError as NSError?)))
                }
            }
        }
    }

    private func mapError(_ error: NSError?) -> BiometricError {
        guard let err = error else { return .authFailed }
        switch err.code {
        case LAError.biometryNotAvailable.rawValue:    return .notAvailable
        case LAError.biometryNotEnrolled.rawValue:     return .notEnrolled
        case LAError.authenticationFailed.rawValue:    return .authFailed
        case LAError.userCancel.rawValue,
             LAError.systemCancel.rawValue:            return .cancelled
        case LAError.biometryLockout.rawValue:         return .lockout
        default: return .unknown(err.localizedDescription)
        }
    }
}
