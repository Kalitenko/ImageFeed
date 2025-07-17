import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Public Static Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - UI Elements
    private let cellImage = UIImageView()
    private let gradientView = UIView()
    private let likeButton = UIButton(type: .custom)
    private let dateLabel = UILabel()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        backgroundColor = UIColor(resource: .ypBlack)
        contentView.backgroundColor = UIColor.clear
    }
    
    private func setupSubViews() {
        setupCellImage()
        setupGradientView()
        setupLikeButton()
        setupDateLabel()
    }
    
    private func setupCellImage() {
        
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        cellImage.clipsToBounds = true
        
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellImage)
        
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    private func setupGradientView() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        cellImage.addSubview(gradientView)
        
        let gradientOverlay = UIImageView(image: UIImage(resource: .gradientOverlayImage))
        gradientOverlay.contentMode = .scaleToFill
        
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(gradientOverlay)
        
        NSLayoutConstraint.activate([
            gradientView.heightAnchor.constraint(equalToConstant: 30),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            
            gradientOverlay.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor),
            gradientOverlay.topAnchor.constraint(equalTo: gradientView.topAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor)
        ])
    }
    
    private func setupLikeButton() {
        likeButton.setImage(UIImage(resource: .isNotLiked), for: .normal)
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.widthAnchor.constraint(equalTo: likeButton.heightAnchor, multiplier: 1),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor)
        ])
    }
    
    private func setupDateLabel() {
        dateLabel.font = UIFont.regular13
        dateLabel.textColor = UIColor(resource: .ypWhite)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Public Methods
    func configure(imageName: String, dateString: String, isLiked: Bool) {
        
        guard let image = UIImage(named: imageName) else {
            return
        }
        
        cellImage.image = image
        dateLabel.text = dateString
        let buttonImage = isLiked == true ? UIImage(resource: .isLiked) : UIImage(resource: .isNotLiked)
        likeButton.setImage(buttonImage, for: .normal)
    }
}
