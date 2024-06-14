//
//  SceneDelegate.swift
//  HeatWaveShelterApp
//
//  Created by 나은정 on 6/5/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
                
        let tabBarController = UITabBarController()
        
        let weatherVC = WeatherViewController()
        weatherVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "weather-icon"), selectedImage: UIImage(named: "weather-icon-selected"))
        weatherVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        
        let homeVC = HomeViewController()
        let homeNavController = UINavigationController(rootViewController: homeVC)
        homeNavController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "home-icon"), selectedImage: UIImage(named: "home-icon-selected"))
        homeNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        
        let systemsettingsVC = SystemSettingsViewController()
        systemsettingsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "setting-icon"), selectedImage: UIImage(named: "setting-icon-selected"))
        systemsettingsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        
        tabBarController.viewControllers = [weatherVC, homeNavController, systemsettingsVC]
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        
        let tabBarHeight: CGFloat = 70
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(hex: "#BBDEFB")
        itemAppearance.selected.iconColor = UIColor(hex: "#1E88E5")
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        appearance.stackedLayoutAppearance = itemAppearance
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        
        if let tabBar = tabBarController.tabBar as? CustomTabBar {
            tabBar.customTabBarHeight = tabBarHeight
        }
        
        tabBarController.selectedIndex = 1
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

class CustomTabBar: UITabBar {
    var customTabBarHeight: CGFloat = 70
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = customTabBarHeight
        return sizeThatFits
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
