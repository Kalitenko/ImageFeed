import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var showSomethingWentWrongWithPhotosAlertCalled: Bool = false
    
    func updateTableViewAnimated(paths indexPaths: [IndexPath], oldCount: Int, newCount: Int) {
        
    }
    
    func showSomethingWentWrongWithPhotosAlert() {
        showSomethingWentWrongWithPhotosAlertCalled = true
    }
    
    func showSomethingWentWrongWithLikesAlert() {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func updateRow(at indexPath: IndexPath) {
        
    }
    
}
