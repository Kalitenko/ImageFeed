import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var updatedAvatarURL: URL?
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    
    func updateProfileDetails(profile: Profile) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar(url: URL) {
        updatedAvatarURL = url
        updateAvatarCalled = true
    }
}
