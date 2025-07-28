import UIKit

private enum Alert {
    static let somethingWentWrongTitle = "Что-то пошло не так("
    static let OkActionTitle = "OK"
    static let authMessage = "Не удалось войти в систему"
    static let likeMessage = "Попробуйте еще раз"
    static let photoMessage = "Сервер передал данные с ошибкой"
    static let loadFullSizeImageErrorMessage = "Что-то пошло не так. Попробовать ещё раз?"
    static let tryAgainActionTitle = "Повторить"
    static let doNotActionTitle = "Не надо"
    static let logoutTitle = "Пока, пока!"
    static let logoutMessage = "Уверены, что хотите выйти?"
    static let yesActionTitle = "Да"
    static let noActionTitle = "Нет"
}

extension UIAlertController {
    
    static func getSomethingWentWrongAlert(with message: String) -> UIAlertController {
        
        let alertController = UIAlertController(
            title: Alert.somethingWentWrongTitle,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: Alert.OkActionTitle, style: .default))
        
        return alertController
    }
    
    static func getSomethingWentWrongWithAuthAlert() -> UIAlertController {
        return getSomethingWentWrongAlert(with: Alert.authMessage)
    }
    
    static func getSomethingWentWrongWithLikesAlert() -> UIAlertController {
        return getSomethingWentWrongAlert(with: Alert.likeMessage)
    }
    
    static func getSomethingWentWrongWithPhotosAlert() -> UIAlertController {
        return getSomethingWentWrongAlert(with: Alert.photoMessage)
    }
    
    static func getShowErrorAlert(tryAgainHandler: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(
            title: Alert.somethingWentWrongTitle,
            message: Alert.loadFullSizeImageErrorMessage,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: Alert.tryAgainActionTitle,
                                                style: .default,
                                                handler: { _ in tryAgainHandler?() }
                                               )
        )
        alertController.addAction(UIAlertAction(title: Alert.doNotActionTitle, style: .cancel))
        
        return alertController
    }
    
    static func getLogoutAlert(logoutHandler: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(
            title: Alert.logoutTitle,
            message: Alert.logoutMessage,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: Alert.yesActionTitle,
                                                style: .default,
                                                handler: { _ in logoutHandler?() }
                                               )
        )
        alertController.addAction(UIAlertAction(title: Alert.noActionTitle, style: .cancel))
        
        return alertController
    }
    
}
