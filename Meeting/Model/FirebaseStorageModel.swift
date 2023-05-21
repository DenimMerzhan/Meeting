//
//  FirebaseStorageModel.swift
//  Meeting
//
//  Created by Деним Мержан on 02.05.23.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore


struct FirebaseStorageModel {
    
    private var currentUserID = String()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private let fileManager = FileManager.default
    private let defaults = UserDefaults.standard
    
    init(userID: String = String()) {
        self.currentUserID = userID
    }
    
    
    
    
    //MARK: - Загрузка фото с сервера в память устройства
    
    func loadPhotoToFile(urlPhotoArr: [String],userID: String,currentUser: Bool) async -> [URL]? {
        
        var urlFileArr = [URL]()
        if urlPhotoArr.count == 0 {
            return nil
        }
        let userLibary = fileManager.urls(for: .documentDirectory, in: .userDomainMask) /// Стандартная библиотека пользователя
        
        var newFolder = userLibary[0]
        
        if currentUser {
            newFolder = newFolder.appendingPathComponent("CurrentUserPhoto")
        }else{
            newFolder = newFolder.appendingPathComponent("OtherUsersPhoto/\(userID)")
        }
        
        if checkDirectoryExist(directory: newFolder) == false { /// Если директории нет создаем эту папку
            try! fileManager.createDirectory(at: newFolder, withIntermediateDirectories: true)
        }
        
        for urlPhoto in urlPhotoArr {
            
            let Reference = storage.reference(forURL: urlPhoto)
            do {
                if let namePhoto = try await Reference.getMetadata().name {
                    let url = try await Reference.writeAsync(toFile: newFolder.appendingPathComponent(namePhoto))
                    urlFileArr.append(url)
                }
            }catch{
                print(error)
            }
        }
        return urlFileArr
    }
    
}

//MARK: -  Проверки существует ли директория

private extension FirebaseStorageModel {
    
    func checkDirectoryExist(directory: URL) -> Bool { /// Проверка существует ли директория по указаному пути
        let exists = FileManager.default.fileExists(atPath: directory.path)
        return exists
    }
}

//MARK: -  Расширение для формирования рандомного ID для фото - Надо исправить т.к есть шанс получить одинаковый ID

extension String {
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
