import UIKit
import Kingfisher

// MARK: - Constants
private enum ClassConstants {
    static let reuseIdentifier = "ImagesListCell"
}

private enum Layout {
    static let cellImageCornerRadius: CGFloat = 16
    
    static let cellImageTop: CGFloat = 4
    static let cellImageHorizontal: CGFloat = 16
    static let cellImageBottom: CGFloat = 4
    
    static let gradientHeight: CGFloat = 30
    
    static let likeButtonSize: CGFloat = 44
    
    static let dateLabelHorizontalInset: CGFloat = 8
    static let dateLabelBottomInset: CGFloat = 8
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Public Static Properties
    static let reuseIdentifier = ClassConstants.reuseIdentifier
    
    // MARK: - UI Elements
    private lazy var cellImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.cornerRadius = Layout.cellImageCornerRadius
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var gradientView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .gradientOverlayImage)
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .isNotLiked), for: .normal)
        
        return button
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regular13
        label.textColor = UIColor(resource: .ypWhite)
        
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
        setupSubViews()
        setupConstraints()
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
        [cellImage, gradientView, likeButton, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [cellImage, likeButton].forEach {
            contentView.addSubview($0)
        }
        cellImage.addSubview(gradientView)
        gradientView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cellImageTop),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cellImageHorizontal),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.cellImageHorizontal),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cellImageBottom),
            
            gradientView.heightAnchor.constraint(equalToConstant: Layout.gradientHeight),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            
            likeButton.heightAnchor.constraint(equalToConstant: Layout.likeButtonSize),
            likeButton.widthAnchor.constraint(equalTo: likeButton.heightAnchor, multiplier: 1),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: Layout.dateLabelHorizontalInset),
            dateLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -Layout.dateLabelHorizontalInset),
            dateLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -Layout.dateLabelBottomInset)
        ])
    }
    
    // MARK: - Public Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    
    func configure(imageURL url: URL, dateString: String, isLiked: Bool) {
        
        cellImage.kf.setImage(with: url,
                              placeholder: UIImage(resource: .defaultFeedImage))
        cellImage.kf.indicatorType = .activity
        dateLabel.text = dateString
        let buttonImage = isLiked == true ? UIImage(resource: .isLiked) : UIImage(resource: .isNotLiked)
        likeButton.setImage(buttonImage, for: .normal)
    }
}
