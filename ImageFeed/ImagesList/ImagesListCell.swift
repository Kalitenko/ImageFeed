import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IB Outlets
    @IBOutlet private var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var gradientView: UIView!
    
    // MARK: - Public Static Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Private Properties
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Public Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradientOverlay = UIImageView(image: UIImage(resource: .gradientOverlayImage))
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        gradientOverlay.contentMode = .scaleToFill
        gradientView.addSubview(gradientOverlay)
        
        gradientOverlay.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientOverlay.layer.cornerRadius = 16
        gradientOverlay.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            gradientOverlay.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor),
            gradientOverlay.topAnchor.constraint(equalTo: gradientView.topAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor)
        ])
    }
    
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
