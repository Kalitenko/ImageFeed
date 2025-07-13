import UIKit

final class SplashViewController: UIViewController {
    
    // MARK:- Layout
    // MARK: - UI Elements
    private let logoImageView = UIImageView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLogoImageView()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupLogoImageView() {
        let logoImage = UIImage(resource: .unsplashLogoImage)
        logoImageView.image = logoImage
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK:- Logic
    // MARK: - Private Properties
    private let tokenStorage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private var profileService = ProfileService.shared
    
    // MARK: - Lifecycle Logic
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = tokenStorage.token else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            return
        }
        fetchProfile(token)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first
        else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else {
                Logger.debug("❗️ self is nil")
                return
            }
                        
            switch result {
            case .success(let profile):
                Logger.success("Информация о профиле получена")
                let username = profile.username
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in}
                let avatarURL = ProfileImageService.shared.avatarURL
                Logger.success("URL аватарки: \(String(describing: avatarURL))")
                self.switchToTabBarController()
            case .failure(let error):
                Logger.error("Информация о профиле не получена: \(error)")
                // TODO [Sprint 11] Покажите ошибку получения профиля
                
                break
            }
        }
    }
    
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) {[weak self] in
            
            guard let token = self?.tokenStorage.token else {
                Logger.success("Нет авторизационного токена")
                return
            }
            
            self?.fetchProfile(token)
        }
    }
}
