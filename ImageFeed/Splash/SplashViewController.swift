import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        let logoImage = UIImage(resource: .unsplashLogoImage)
        imageView.image = logoImage
        
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupSubViews() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: - Logic
    
    // MARK: - Private Properties
    private let tokenStorage = OAuth2TokenStorage.shared
    private var profileService = ProfileService.shared
    
    // MARK: - Lifecycle Logic
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = tokenStorage.token else {
            showAuthenticationScreen()
            return
        }
        fetchProfile(token)
    }
    
    // MARK: - Navigation
    private func showAuthenticationScreen() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first
        else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = TabBarController()
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
