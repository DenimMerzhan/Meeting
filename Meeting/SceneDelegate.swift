//
//  SceneDelegate.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var currentAuthUser: CurrentAuthUser?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { /// После закрытия приложения удаляем все фото с директории пользователя
        print("sceneDidDisconnect")
        
        if let image = CurrentAuthUser.shared.imageArr.first?.image {
            guard let imageData = image.jpegData(compressionQuality: 1) else {return}
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent("AvatarCurrentUser.jpeg")
            do {
                try imageData.write(to: url)
            }catch {
                print("Ошибка записи аватара текущего пользователя в каталог \(error)")
            }
            
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "sceneDidDisconnect"), object: nil)
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

