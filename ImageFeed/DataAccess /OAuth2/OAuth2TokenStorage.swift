import Foundation
import SwiftKeychainWrapper

enum StorageKeys: String {
    case oAuthToken
}

final class OAuth2TokenStorage {
    
    // MARK: - Shared Instance
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Initializer
    private init() {}
    
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
    
    // MARK: - Public Methods
    func logout() {
        storage.removeObject(forKey: StorageKeys.oAuthToken.rawValue)
    }
    
}
