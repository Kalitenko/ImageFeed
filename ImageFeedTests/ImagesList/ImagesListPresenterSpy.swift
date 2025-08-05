import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    var photosCount: Int = 0
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        
    }
    
    func getPhotoByIndexPath(_ indexPath: IndexPath) -> Photo {
        return Photo(id: "test", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "thumbImageURL", largeImageURL: "largeImageURL", isLiked: true)
    }
    
    func didTapLike(_ indexPath: IndexPath) {
        
    }
}
