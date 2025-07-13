import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK:- Layout
    // MARK: - UI Elements
    private let avatarImageView = UIImageView()
    
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let logoutButton = UIButton(type: .system)
    
    private var constraints: [NSLayoutConstraint] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK:- Layout
        setupView()
        setupSubViews()
        setupLayout()
        
        // MARK:- Logic
        setupProfileInfo()
        
        if let avatarURL = ProfileImageService.shared.avatarURL,// 16
           let url = URL(string: avatarURL) {                   // 17
            // TODO [Sprint 11]  Обновите аватар, если нотификация
            // была опубликована до того, как мы подписались.
            updateAvatar(url: url)

        }
        
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupSubViews() {
        setupAvatarImageView()
        setupNameLabel()
        setupUsernameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
    }
    
    private func setupAvatarImageView() {
        let avatarImage = UIImage(resource: .sampleAvatar)
        avatarImageView.image = avatarImage
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.layer.masksToBounds = true
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        constraints.append(contentsOf: [
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor, multiplier: 1),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.font = UIFont.bold23
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        constraints.append(contentsOf: [
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupUsernameLabel() {
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.textColor = UIColor(resource: .ypGray)
        usernameLabel.font = UIFont.regular13
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        constraints.append(contentsOf: [
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(resource: .ypWhite)
        descriptionLabel.font = UIFont.regular13
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        constraints.append(contentsOf: [
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupLogoutButton() {
        logoutButton.setImage(UIImage(resource: .exitImage), for: UIControl.State.normal)
        logoutButton.addTarget(self, action: #selector(Self.didTapLogoutButton), for: .touchUpInside)
        logoutButton.tintColor = UIColor(resource: .ypRed)
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        constraints.append(contentsOf: [
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor, multiplier: 1),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK:- Logic
    // MARK: - Initializers
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    // MARK: - Deinitialization
    deinit {
        removeObserver()
    }
    
    // MARK: - Private Properties
    private var profileService = ProfileService.shared
    private var storage = OAuth2TokenStorage()
    
    // MARK: - Actions
    @objc func didTapLogoutButton(_ sender: Any) {
    }
    
    // MARK: - Private Methods
    private func setupProfileInfo() {
        
        guard let profile = profileService.profile else {
            Logger.error("Нет информации о профиле")
            return
        }
        
        updateProfileDetails(profile: profile)
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(                 // 1
            self,                                               // 2
            selector: #selector(updateAvatar(notification:)),   // 3
            name: ProfileImageService.didChangeNotification,    // 4
            object: nil)                                        // 5
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(              // 6
            self,                                               // 7
            name: ProfileImageService.didChangeNotification,    // 8
            object: nil)                                        // 9
    }
    
    @objc                                                       // 10
    private func updateAvatar(notification: Notification) {     // 11
        guard
            isViewLoaded,                                       // 12
            let userInfo = notification.userInfo,               // 13
            let profileImageURL = userInfo["URL"] as? String,   // 14
            let url = URL(string: profileImageURL)              // 15
        else { return }
        
        // TODO [Sprint 11] Обновите аватар, используя Kingfisher
        updateAvatar(url: url)
        
    }
    
    private func updateAvatar(url: URL) {
        avatarImageView.kf.setImage(with: url,
                                    placeholder: UIImage(resource: .defaultAvatarImage))
    }
}
