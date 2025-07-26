import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Shared Instance
    static let shared = ProfileLogoutService()
    
    // MARK: - Initializer
    private init() { }
    
    // MARK: - Private Properties
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Public Methods
    func logout() {
        cleanCookies()
        logoutStorage()
        logoutProfileService()
        logoutProfileImageService()
        logoutImagesListService()
        Logger.success("Данные пользователя удалены")
        switchToSplashViewController()
    }
    
    // MARK: - Private Methods
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func logoutStorage() {
        tokenStorage.logout()
    }
    
    private func logoutProfileService() {
        profileService.logout()
    }
    
    private func logoutProfileImageService() {
        profileService.logout()
    }
    
    private func logoutImagesListService() {
        imagesListService.logout()
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
