import UIKit

private enum Alert {
    static let title = "Что-то пошло не так("
    static let actionTitle = "OK"
    static let authMessage = "Не удалось войти в систему"
    static let likeMessage = "попробуйте еще раз"
}

extension UIAlertController {
    
    static func getSomethingWentWrongAlert(with message: String) -> UIAlertController {
        
        let alertController = UIAlertController(
            title: Alert.title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: Alert.actionTitle, style: .default))
        
        return alertController
    }
    
    static func getSomethingWentWrongWithAuthAlert() -> UIAlertController {
        return getSomethingWentWrongAlert(with: Alert.authMessage)
    }
    
    static func getSomethingWentWrongWithLikesAlert() -> UIAlertController {
        return getSomethingWentWrongAlert(with: Alert.likeMessage)
    }
    
}
