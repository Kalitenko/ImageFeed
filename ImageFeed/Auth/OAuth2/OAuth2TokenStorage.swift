import Foundation

final class OAuth2TokenStorage {
    
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard
    
    // MARK: - Public Properties
    var token: String? {
        get {
            storage.string(forKey: StorageKeys.oAuthToken.rawValue)
        }
        set {
            storage.set(newValue, forKey: StorageKeys.oAuthToken.rawValue)
        }
    }
}
