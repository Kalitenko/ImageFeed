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
    
    // MARK: - Private Methods
    private func updateGradientFrame() {
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - Public Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradientLayer.colors = [
            try? UIColor(hex: "#1B2200").withAlphaComponent(0).cgColor,
            try? UIColor(hex: "#1B2200").withAlphaComponent(1).cgColor
        ].compactMap { $0 }
        
        gradientLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientLayer.cornerRadius = 16
        gradientLayer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientLayer.superlayer == nil {
            gradientView.layer.addSublayer(gradientLayer)
        }
        gradientLayer.frame = gradientView.bounds
    }
    
    func configure(imageName: String, dateString: String, isLiked: Bool) {
        
        guard let image = UIImage(named: imageName) else {
            return
        }
        
        cellImage.image = image
        dateLabel.text = dateString
        let imageState = isLiked == true ? "Active" : "No Active"
        let buttonImage = UIImage(named: imageState)
        likeButton.setImage(buttonImage, for: .normal)
        layoutIfNeeded()
        updateGradientFrame()
    }
    
}
