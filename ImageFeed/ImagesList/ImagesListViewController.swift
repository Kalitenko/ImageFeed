import UIKit

// MARK: - Protocol
public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(paths indexPaths: [IndexPath], oldCount: Int, newCount: Int)
    func showSomethingWentWrongWithPhotosAlert()
    func showSomethingWentWrongWithLikesAlert()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func updateRow(at indexPath: IndexPath)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Constants
    private enum Layout {
        static let contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        static let imageInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        static let stubHeight = CGFloat(100)
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(resource: .ypBlack)
        tableView.separatorStyle = .none
        tableView.contentMode = .scaleToFill
        tableView.contentInset = Layout.contentInset
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        return tableView
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
        presenter?.viewDidLoad()
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
    
    // MARK: - Public Properties
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Public Methods
    func updateTableViewAnimated(paths indexPaths: [IndexPath], oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func showSomethingWentWrongWithPhotosAlert() {
        let alertController = UIAlertController.getSomethingWentWrongWithPhotosAlert()
        present(alertController, animated: true)
    }
    
    func showSomethingWentWrongWithLikesAlert() {
        let alertController = UIAlertController.getSomethingWentWrongWithLikesAlert()
        present(alertController, animated: true)
    }
    
    func showLoadingIndicator() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoadingIndicator() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func updateRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Private Methods
    private func photosCount() -> Int {
        presenter?.photosCount ?? Int.zero
    }
    
    private func getPhotoByRowIndexPath(indexPath: IndexPath) -> Photo? {
        guard let photo = presenter?.getPhotoByIndexPath(indexPath) else {
            return nil
        }
        return photo
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = getPhotoByRowIndexPath(indexPath: indexPath)?.largeImageURL else { return }
        showSingleImageScreen(url: url)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = getPhotoByRowIndexPath(indexPath: indexPath) else {
            Logger.error("Не найдено фото с indexPath \(indexPath)")
            return Layout.stubHeight
        }
        
        let imageInsets = Layout.imageInset
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
        photosCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        guard let photo = getPhotoByRowIndexPath(indexPath: indexPath) else {
            Logger.error("Не найдено фото с indexPath \(indexPath)")
            return UITableViewCell()
        }
        
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
        guard indexPath.row + 1 == photosCount() else { return }
        presenter?.fetchPhotosNextPage()
    }
    
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(indexPath)
    }
}
