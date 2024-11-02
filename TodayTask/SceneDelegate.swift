//
//  SceneDelegate.swift
//  TodayTask
//
//  Created by Андрей on 07.09.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        UserDefaults.standard.setValue(false, forKey: "networkDataLoaded")
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = TodayNotesAssemly.createViewController()
        window.makeKeyAndVisible()
        
        self.window = window
    }
}
