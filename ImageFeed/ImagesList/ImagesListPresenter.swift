import Foundation

// MARK: - Protocol
public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func getPhotoByIndexPath(_ indexPath: IndexPath) -> Photo
    func didTapLike(_ indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ImagesListViewControllerProtocol?
    var photosCount: Int {
        photos.count
    }
    
    // MARK: - Private Properties
    private var imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    // MARK: - Initializers
    init() {
        addDidChangeNotificationObserver()
        addDidEncounterWrongPhotoDataObserver()
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage ()
    }
    
    func getPhotoByIndexPath(_ indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    
    func didTapLike(_ indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        view?.showLoadingIndicator()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.updateRow(at: indexPath)
                self.view?.hideLoadingIndicator()
            case .failure:
                self.view?.hideLoadingIndicator()
                self.view?.showSomethingWentWrongWithLikesAlert()
                Logger.error("Не удалось изменить лайк")
            }
        }
    }
    
    // MARK: - Private Methods
    private func addDidChangeNotificationObserver() {
        NotificationCenter.default
            .addObserver(forName: ImagesListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                preparePhotosForInsertion()
            }
    }
    
    private func addDidEncounterWrongPhotoDataObserver() {
        NotificationCenter.default
            .addObserver(forName: ImagesListService.didEncounterWrongPhotoData,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                view?.showSomethingWentWrongWithPhotosAlert()
            }
    }
    
    private func preparePhotosForInsertion() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            view?.updateTableViewAnimated(paths: indexPaths, oldCount: oldCount, newCount: newCount)
        }
    }
    
}
