@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterHandlesFetchPhotosNotification() {
        // Given
        let presenter = ImagesListPresenter()
        let view = ImagesListViewControllerSpy()
        view.presenter = presenter
        presenter.view = view
        
        // When
        NotificationCenter.default.post(
            name: ImagesListService.didEncounterWrongPhotoData,
            object: nil,
            userInfo: ["id": 0]
        )
        
        // Then
        XCTAssertTrue(view.showSomethingWentWrongWithPhotosAlertCalled)
    }
    
}
