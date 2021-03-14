//
//  SceneDelegate.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene),
                  let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }

            let manager = APIManager()
            let initialViewController = MainViewController(context: context, apiManager: manager)
            let navigationController = UINavigationController(rootViewController: initialViewController)

            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
}
