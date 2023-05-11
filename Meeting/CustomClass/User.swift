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
    
    init(ID:String) {
        self.ID = ID
    }
    
    
//MARK:  Загрузка метаданных о пользователе
    
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
    
    
//MARK: - Загрузка фото пользователя
    
    func loadPhoto(completion: @escaping (Bool) -> Void) {
        FirebaseStorageModel().loadPhotoFromServer(urlArrUser: urlPhotoArr, userID: ID) { [unowned self] imageUserArr,err in
            
            if let error = err {
                print(error)
                completion(false)
            }
            
            guard imageUserArr != nil else {return}
            
            self.imageArr = imageUserArr!
            completion(true)
        }
    }
    
}




struct CurrentUserFile {
    
    var nameFile = String()
    var image = UIImage()
    
}
