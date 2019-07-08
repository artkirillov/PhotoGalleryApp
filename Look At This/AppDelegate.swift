//
//  AppDelegate.swift
//  Look At This
//
//  Created by Artem Kirillov on 07/07/2019.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: .zero)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationController = UINavigationController(rootViewController: GalleryViewController())
        navigationController.navigationBar.barStyle = .blackTranslucent
        navigationController.navigationBar.tintColor = .white
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
}

