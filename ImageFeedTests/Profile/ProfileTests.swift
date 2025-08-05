@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterHandlesAvatarUpdateNotification() {
        // given
        let presenter = ProfilePresenter()
        let view = ProfileViewControllerSpy()
        presenter.view = view
        let newAvatarURL = "https://avatar.com/avatar.jpg"
        
        // when
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: nil,
            userInfo: ["URL": newAvatarURL]
        )
        
        // then
        XCTAssertEqual(view.updatedAvatarURL?.absoluteString, newAvatarURL)
    }
}
