import UIKit

// MARK: - Constants
private enum ClassConstants {
    fileprivate enum Layout {
        static let loginButtonTitle = "Войти"
        static let loginButtonCornerRadius: CGFloat = 16
        
        static let buttonHeight: CGFloat = 48
        static let horizontalInset: CGFloat = 16
        static let bottomInset: CGFloat = 90
    }
    
    fileprivate enum Alert {
        static let title = "Что-то пошло не так("
        static let message = "Не удалось войти в систему"
        static let actionTitle = "OK"
    }
}

final class AuthViewController: UIViewController {
    
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
        button.setTitle(ClassConstants.Layout.loginButtonTitle, for: .normal)
        button.layer.cornerRadius = ClassConstants.Layout.loginButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(Self.didTapLoginButton), for: .touchUpInside)
        
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
            
            loginButton.heightAnchor.constraint(equalToConstant: ClassConstants.Layout.buttonHeight),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ClassConstants.Layout.horizontalInset),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ClassConstants.Layout.horizontalInset),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ClassConstants.Layout.bottomInset)
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
    private let oAuth2Service = OAuth2Service.shared
    
    // MARK: - Private Methods
    private func showSomethingWentWrongAlert() {
        let alertController = UIAlertController(
            title: ClassConstants.Alert.title,
            message: ClassConstants.Alert.message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: ClassConstants.Alert.actionTitle, style: .default))
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

