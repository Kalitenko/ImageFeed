import UIKit

final class AuthViewController: UIViewController {
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private let unsplashLogoImageView = UIImageView()
    private let loginButton = UIButton(type: .system)
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupSubViews() {
        setupUnsplashLogoImageView()
        setupLoginButton()
    }
    
    private func setupUnsplashLogoImageView() {
        let logoImage = UIImage(resource: .unsplashLogoImage)
        unsplashLogoImageView.image = logoImage
        
        unsplashLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsplashLogoImageView)
        
        NSLayoutConstraint.activate([
            unsplashLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            unsplashLogoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            
        ])
    }
    
    private func setupLoginButton() {
        loginButton.addTarget(self, action: #selector(Self.didTapLoginButton), for: .touchUpInside)
        loginButton.tintColor = UIColor(resource: .ypBlack)
        loginButton.backgroundColor = UIColor(resource: .ypWhite)
        loginButton.titleLabel?.font = UIFont.bold17
        loginButton.setTitle("Войти", for: .normal)
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
    
    // MARK: - Navigation
    
    @objc
    private func didTapLoginButton() {
        showWebViewScreen()
    }
    
    private func showWebViewScreen() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
    // MARK: - Logic
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let segueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared
    
    // MARK: - Private Methods
    private func showSomethingWentWrongAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        oAuth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            Logger.info("\(result)\n")
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(_):
                Logger.success("Авторизация выполнена")
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                Logger.error("Авторизация не удалась: \(error)")
                showSomethingWentWrongAlert()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

