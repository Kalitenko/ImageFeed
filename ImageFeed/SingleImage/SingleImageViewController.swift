import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private var imageView = UIImageView()
    private var scrollView = UIScrollView()
    
    private let backwardButton = UIButton(type: .custom)
    private let shareButton = UIButton(type: .custom)
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Lifecycle Layout
        setupView()
        setupSubViews()
        
        // MARK: Lifecycle Logic
        guard let image else { return }
        setAndRescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupSubViews() {
        setupImageView()
        setupScrollView()
        setupBackwardButton()
        setupShareButton()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        scrollView.delegate = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBackwardButton() {
        backwardButton.setImage(UIImage(resource: .backward), for: .normal)
        backwardButton.addTarget(self, action: #selector(Self.didTapCloseButton), for: .touchUpInside)
        
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backwardButton)
        
        NSLayoutConstraint.activate([
            backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backwardButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backwardButton.heightAnchor.constraint(equalToConstant: 48),
            backwardButton.widthAnchor.constraint(equalTo: backwardButton.heightAnchor, multiplier: 1)
        ])
    }
    
    private func setupShareButton() {
        shareButton.setImage(UIImage(resource: .sharing), for: .normal)
        shareButton.addTarget(self, action: #selector(Self.didTapShareButton), for: .touchUpInside)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor, multiplier: 1)
        ])
    }    
    
    // MARK: - Logic
    
    // MARK: - Public Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            setAndRescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
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
