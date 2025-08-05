@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterHandlesFetchPhotosNotification() {
        // given
        let presenter = ImagesListPresenter()
        let view = ImagesListViewControllerSpy()
        view.presenter = presenter
        presenter.view = view
        
        // when
        NotificationCenter.default.post(
            name: ImagesListService.didEncounterWrongPhotoData,
            object: nil,
            userInfo: ["id": 0]
        )
        
        // then
        XCTAssertTrue(view.showSomethingWentWrongWithPhotosAlertCalled)
    }
    
}
