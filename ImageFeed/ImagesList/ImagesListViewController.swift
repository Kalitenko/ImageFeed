import UIKit

private enum ClassConstants {
    static let contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    static let imageInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
}

final class ImagesListViewController: UIViewController {
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(resource: .ypBlack)
        tableView.separatorStyle = .none
        tableView.contentMode = .scaleToFill
        tableView.contentInset = ClassConstants.contentInset
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        return tableView
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
        
        imagesListService.fetchPhotosNextPage()
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupSubViews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Navigation
    private func showSingleImageScreen(url: String) {
        let singleImageController = SingleImageViewController()
        singleImageController.fullSizeImageURL = url
        singleImageController.modalPresentationStyle = .fullScreen
        present(singleImageController, animated: true)
    }
    
    // MARK: - Logic
    
    // MARK: - Private Properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let currentDateString = Date().dateTimeString
    private var imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Private Methods
    @objc
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = photos[indexPath.row].largeImageURL
        showSingleImageScreen(url: url)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = ClassConstants.imageInset
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        guard let url = URL(string: photo.thumbImageURL) else {
            Logger.error("Не получилось получить URL из \(photo.thumbImageURL)")
            return UITableViewCell()
        }
        
        imageListCell.configure(
            imageURL: url,
            dateString: photo.createdAt?.dateTimeString ?? "",
            isLiked: photo.isLiked
        )
        imageListCell.delegate = self
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
    ) {
        guard indexPath.row + 1 == photos.count else { return }
        imagesListService.fetchPhotosNextPage()
    }
    
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showSomethingWentWrongAlert()
                Logger.error("Не удалось изменить лайк")
            }
        }
    }
    
    private func showSomethingWentWrongAlert() {
        let alertController = UIAlertController.getSomethingWentWrongWithLikesAlert()
        present(alertController, animated: true)
    }
    
}
