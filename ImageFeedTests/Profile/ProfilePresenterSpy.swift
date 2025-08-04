import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var viewDidLoadCalled: Bool = false
    var logoutCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    var profile: Profile?
    var avatarURL: String?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
    
}
