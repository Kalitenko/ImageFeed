import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Private Properties
    private let storage: KeychainWrapper = .standard
    
    // MARK: - Public Properties
    var token: String? {
        get {
            storage.string(forKey: StorageKeys.oAuthToken.rawValue)
        }
        set {
            guard let newValue else {
                Logger.error("Попытка сохранить токен равный nil")
                return
            }
            storage.set(newValue, forKey: StorageKeys.oAuthToken.rawValue)
        }
    }
}
