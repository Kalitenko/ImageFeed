import UIKit

final class AuthViewController: UIViewController {
    
    // MARK: - Constants
    enum Constants {
        static let loginButtonTitle = "Войти"
        static let loginButtonAccessibilityIdentifier = "Authenticate"
        static let loginButtonCornerRadius: CGFloat = 16
        
        static let buttonHeight: CGFloat = 48
        static let horizontalInset: CGFloat = 16
        static let bottomInset: CGFloat = 90
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var unsplashLogoImageView: UIImageView = {
        let imageView = UIImageView()
        let logoImage = UIImage(resource: .unsplashLogoImage)
        imageView.image = logoImage
        
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(resource: .ypBlack)
        button.backgroundColor = UIColor(resource: .ypWhite)
        button.titleLabel?.font = UIFont.bold17
        button.setTitle(Constants.loginButtonTitle, for: .normal)
        button.layer.cornerRadius = Constants.loginButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(Self.didTapLoginButton), for: .touchUpInside)
        button.accessibilityIdentifier = Constants.loginButtonAccessibilityIdentifier
        
        return button
    }()
    
    // MARK: - View Life Cycles
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
        [unsplashLogoImageView, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            unsplashLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            unsplashLogoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            loginButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalInset),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomInset)
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
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
    // MARK: - Logic
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let oAuth2Service = OAuth2Service.shared
    
    // MARK: - Private Methods
    private func showSomethingWentWrongAlert() {
        let alertController = UIAlertController.getSomethingWentWrongWithAuthAlert()
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

