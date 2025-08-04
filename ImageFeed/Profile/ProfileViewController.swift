import UIKit
import Kingfisher

// MARK: - Protocol
public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(profile: Profile)
    func updateAvatar(url: URL)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - Constants
    private enum Layout {
        static let avatarCornerRadius: CGFloat = 35
        
        static let nameLabelExampleText = "Екатерина Новикова"
        static let usernameLabelExampleText = "@ekaterina_nov"
        static let descriptionLabelExampleText = "Hello, world!"
        
        static let avatarSize: CGFloat = 70
        static let topInset: CGFloat = 32
        static let horizontalInset: CGFloat = 16
        static let labelSpacing: CGFloat = 8
        static let logoutButtonSize: CGFloat = 44
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        let avatarImage = UIImage(resource: .sampleAvatar)
        imageView.image = avatarImage
        imageView.layer.cornerRadius = Layout.avatarCornerRadius
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.nameLabelExampleText
        label.textColor = UIColor(resource: .ypWhite)
        label.font = UIFont.bold23
        
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.usernameLabelExampleText
        label.textColor = UIColor(resource: .ypGray)
        label.font = UIFont.regular13
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.descriptionLabelExampleText
        label.textColor = UIColor(resource: .ypWhite)
        label.font = UIFont.regular13
        
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .exitImage), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(Self.didTapLogoutButton), for: .touchUpInside)
        button.tintColor = UIColor(resource: .ypRed)
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Lifecycle Layout
        setupView()
        setupSubViews()
        setupConstraints()
        
        // MARK: Lifecycle Logic
        presenter?.viewDidLoad()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupSubViews() {
        [avatarImageView, nameLabel, usernameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: Layout.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor, multiplier: 1),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.topInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalInset),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalInset),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalInset),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Layout.labelSpacing),
            
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Layout.labelSpacing),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Layout.labelSpacing),
            
            logoutButton.widthAnchor.constraint(equalToConstant: Layout.logoutButtonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor, multiplier: 1),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalInset),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    // MARK: - Logic
    
    // MARK: - Initializers
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Public Properties
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - Actions
    @objc func didTapLogoutButton(_ sender: Any) {
        let alertController = UIAlertController.getLogoutAlert {
            self.presenter?.logout()
        }
        present(alertController, animated: true)
    }
    
    // MARK: - Public Methods
    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func updateAvatar(url: URL) {
        avatarImageView.kf.setImage(with: url,
                                    placeholder: UIImage(resource: .defaultAvatarImage))
    }
    
}
