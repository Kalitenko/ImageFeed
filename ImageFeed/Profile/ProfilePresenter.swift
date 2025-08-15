import Foundation

// MARK: - Protocol
public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var profile: Profile? { get }
    var avatarURL: String? { get }
    func logout()
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    // MARK: - Initializers
    init() {
        addObserver()
    }
    
    // MARK: - Deinitialization
    deinit {
        removeObserver()
    }
    
    // MARK: - Public Properties
    weak var view: ProfileViewControllerProtocol?
    var profile: Profile? {
        return self.profileService.profile
    }
    var avatarURL: String? {
        return self.profileImageService.avatarURL
    }
    
    // MARK: - Private Properties
    private var profileService = ProfileService.shared
    private var storage = OAuth2TokenStorage.shared
    private var logoutService = ProfileLogoutService.shared
    private var profileImageService = ProfileImageService.shared
    
    // MARK: - Public Methods
    func logout() {
        self.logoutService.logout()
    }
    
    func viewDidLoad() {
        if let profile = profile {
            view?.updateProfileDetails(profile: profile)
        }
        
        if let avatarURL = avatarURL, let url = URL(string: avatarURL) {
            view?.updateAvatar(url: url)
        }
    }
    
    // MARK: - Private Methods
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(url: url)
    }
    
}
