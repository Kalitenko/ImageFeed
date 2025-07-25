import UIKit
import Kingfisher

private enum Layout {
    static let minimumZoomScale = 0.1
    static let maximumZoomScale = 1.25
    
    static let sideInset: CGFloat = 8
    static let bottomInset: CGFloat = 17
    
    static let backwardButtonSize: CGFloat = 48
    static let shareButtonSize: CGFloat = 50
}

final class SingleImageViewController: UIViewController {
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = Layout.minimumZoomScale
        scrollView.maximumZoomScale = Layout.maximumZoomScale
        scrollView.delegate = self
        
        return scrollView
    }()
    
    private lazy var backwardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .backward), for: .normal)
        button.addTarget(self, action: #selector(Self.didTapCloseButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .sharing), for: .normal)
        button.addTarget(self, action: #selector(Self.didTapShareButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Lifecycle Layout
        setupView()
        setupSubViews()
        setupConstraints()
        setFullSizeImage()
        
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupSubViews() {
        [scrollView, backwardButton, shareButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        scrollView.addSubview(imageView)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.sideInset),
            backwardButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.sideInset),
            backwardButton.heightAnchor.constraint(equalToConstant: Layout.backwardButtonSize),
            backwardButton.widthAnchor.constraint(equalTo: backwardButton.heightAnchor, multiplier: 1),
            
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.bottomInset),
            shareButton.heightAnchor.constraint(equalToConstant: Layout.shareButtonSize),
            shareButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor, multiplier: 1)
        ])
    }
    
    // MARK: - Logic
    
    // MARK: - Public Properties
    var fullSizeImageURL: String = "" {
        didSet {
            guard let url = URL(string: fullSizeImageURL) else {
                Logger.error("Ошибка в URL полноразмерного изображения")
                return
            }
            imageUrl = url
        }
    }
    
    // MARK: - Private Properties
    private var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            setAndRescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Public Properties
    private var imageUrl: URL?
    
    // MARK: - IB Actions
    @objc
    private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else {
            return
        }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        DispatchQueue.main.async { [weak self] in
            self?.present(share, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: true)
    }
    
    private func centerImageViewInScrollView() {
        let visibleRectSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        let x = max(Double.zero, (visibleRectSize.width - contentSize.width) / 2)
        let y = max(Double.zero, (visibleRectSize.height - contentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }
    
    private func setAndRescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func setFullSizeImage() {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageUrl) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.image = imageResult.image
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController.getShowErrorAlert() {
            self.setFullSizeImage()
        }
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageViewInScrollView()
    }
}
