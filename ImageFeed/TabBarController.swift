import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Layout
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureTabBar()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func configureTabBar() {
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActiveImage),
            selectedImage: nil
        )
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActiveImage),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .ypBlack)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(resource: .ypWhiteAlpha50)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(resource: .ypWhite)
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.isTranslucent = false
    }
}
