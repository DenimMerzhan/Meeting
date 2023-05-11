//
//  User.swift
//  Meeting
//
//  Created by Деним Мержан on 20.04.23.
//

import Foundation
import UIKit
import FirebaseFirestore

class User {
    
    var ID = String()
    
    var name = String()
    var age = Int()
    
    var imageArr = [UIImage]()
    var urlPhotoArr = [String]()
    
    private let db = Firestore.firestore()
    private let fileManager = FileManager.default
    
    init(ID:String) {
        self.ID = ID
    }
    
    
    
//MARK: - Загрузка метаданных о пользователе
    
    func loadMetaData() async {
        
        let collection  = db.collection("Users2").document(ID)
        
        do {
            let docSnap = try await collection.getDocument()
            if let dataDoc = docSnap.data() {
                
                if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                    self.name = name
                    self.age = age
                    
                    for data in dataDoc {
                        if data.key.contains("photoImage") {
                            if let urlPhoto = data.value as? String {
                                self.urlPhotoArr.append(urlPhoto)
                            }
                        }
                    }
                    
                }else {
                    print("Ошибка в преобразование имени и возраста у данного пользователя \(ID)")
                }
            }
            
        }catch{
            print("Ошибка получения ссылок на фото с сервера FirebaseFirestore - \(error)")
        }
    }
    
    
//MARK: - Загрузка фото пользователя с директории
    
    func loadPhotoFromDirectory(urlFileArr: [URL] ){
        
        for url in urlFileArr {
            if let newImage = UIImage(contentsOfFile: url.path) {
                imageArr.append(newImage)
//                newImage = .remove
            }
        }
    }
    
    func cleanPhotoUser(){
        
        let userLibary = fileManager.urls(for: .documentDirectory, in: .userDomainMask) /// Стандартная библиотека пользователя
        let currentFolder = userLibary[0].appendingPathComponent("OtherUsersPhoto/\(ID)") /// Добавляем к ней новую папку
        
        do {
            try fileManager.removeItem(at: currentFolder)
        }catch{
            print("Ошибка удаления файла")
        }
    }
}




struct CurrentUserFile {
    
    var nameFile = String()
    var image = UIImage()
    
}
