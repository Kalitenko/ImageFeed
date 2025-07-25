import UIKit

private enum Alert {
    static let title = "Что-то пошло не так("
    static let OkActionTitle = "OK"
    static let authMessage = "Не удалось войти в систему"
    static let likeMessage = "Попробуйте еще раз"
    static let loadFullSizeImageErrorMessage = "Что-то пошло не так. Попробовать ещё раз?"
    static let tryAgainActionTitle = "Повторить"
    static let doNotActionTitle = "Не надо"
}

extension UIAlertController {
    
    static func getSomethingWentWrongAlert(with message: String) -> UIAlertController {
        
        let alertController = UIAlertController(
            title: Alert.title,
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
    
    static func getShowErrorAlert(tryAgainHandler: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(
            title: Alert.title,
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
    
}
