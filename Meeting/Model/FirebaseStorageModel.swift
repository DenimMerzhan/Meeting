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
    
    private var userID = String()
    
    init(userID: String = String()) {
        self.userID = userID
    }
    
    func uploadImageToStorage(image: UIImage) async -> Bool {
        
        let imageID = "photoImage" + randomString(length: 5)
        
        let imagesRef = Storage.storage().reference().child("UsersPhoto").child(userID).child(imageID) /// Создаем ссылку на файл
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { /// Преобразуем в Jpeg c сжатием
            return false
        }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg" /// Указываем явный тип данных в FireBase
        
        do {
            try await imagesRef.putDataAsync(imageData)
            let url = try await imagesRef.downloadURL()
            let status = await uploadDataToFirestore(url: url, imageID: imageID)
            return status
        }catch {
            print(error)
            return false
        }
        
    }
    
    
    
    func uploadDataToFirestore(url:URL,imageID: String) async -> Bool {
     
        let db = Firestore.firestore().collection("Users").document(userID) /// Добавляем в FiresStore ссылку на фото\
        
        do {
           try await db.setData([imageID : url.absoluteString], merge: true)
            return true
        }catch{
            print(error)
            return false
        }
    }
    
}



extension FirebaseStorageModel {
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
