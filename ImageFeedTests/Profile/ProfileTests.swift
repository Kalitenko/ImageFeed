@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterHandlesAvatarUpdateNotification() {
        // Given
        let presenter = ProfilePresenter()
        let view = ProfileViewControllerSpy()
        presenter.view = view
        let newAvatarURL = "https://avatar.com/avatar.jpg"
        
        // When
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: nil,
            userInfo: ["URL": newAvatarURL]
        )
        
        // Then
        XCTAssertEqual(view.updatedAvatarURL?.absoluteString, newAvatarURL)
    }
}
