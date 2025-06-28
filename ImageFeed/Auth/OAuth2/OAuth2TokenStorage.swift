import Foundation

final class OAuth2TokenStorage {
    
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard
    
    // MARK: - Public Properties
    var token: String? {
        get {
            storage.string(forKey: StorageKeys.OAuthToken.rawValue)
        }
        set {
            storage.set(newValue, forKey: StorageKeys.OAuthToken.rawValue)
        }
    }
}
