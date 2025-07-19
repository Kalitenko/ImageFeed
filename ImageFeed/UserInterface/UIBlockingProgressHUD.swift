import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.windows.first
    }
    
    static func show() {
        if Thread.isMainThread {
            window?.isUserInteractionEnabled = false
            ProgressHUD.animate()
        } else {
            DispatchQueue.main.async {
                window?.isUserInteractionEnabled = false
                ProgressHUD.animate()
            }
        }
    }
    
    static func dismiss() {
        if Thread.isMainThread {
            window?.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
        } else {
            DispatchQueue.main.async {
                window?.isUserInteractionEnabled = true
                ProgressHUD.dismiss()
            }
        }
    }
}
