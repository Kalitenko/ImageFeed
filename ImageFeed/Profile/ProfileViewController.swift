import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private let avatarImageView = UIImageView()
    
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let logoutButton = UIButton(type: .system)
    
    // MARK: - Private Properties
    var constraints: [NSLayoutConstraint] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupLayout()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupSubViews() {
        setupAvatarImageView()
        setupNameLabel()
        setupuUsernameLabel()
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
    
    private func setupuUsernameLabel() {
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
    
    // MARK: - Actions
    @objc func didTapLogoutButton(_ sender: Any) {
    }
}
