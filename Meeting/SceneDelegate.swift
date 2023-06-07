//
//  SceneDelegate.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var delegate: UserReturnedToChat?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) { /// После закрытия приложения удаляем все фото с директории пользователя
        print("sceneDidDisconnect")
        
        let fileManager = FileManager.default
        
        let userLibary = fileManager.urls(for: .documentDirectory, in: .userDomainMask) /// Стандартная библиотека пользователя
        let usersFolder = userLibary[0].appendingPathComponent("OtherUsersPhoto") /// Добавляем к ней новую папку
        
        let currentUserAuthFolder = userLibary[0].appendingPathComponent("CurrentUserPhoto") /// Добавляем к ней новую папку
        
        do {
            try fileManager.removeItem(at: usersFolder)
            try fileManager.removeItem(at: currentUserAuthFolder)
        }catch{
            print("Ошибка удаления папок при закрытие приложения - \(error)")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "sceneWillEnterForeground"), object: nil)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    

}

