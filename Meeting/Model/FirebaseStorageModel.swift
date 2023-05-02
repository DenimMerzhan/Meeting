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
    
    
    func uploadImageToStorage(image: UIImage) -> Bool {
        
        var successfulUpload = Bool()
        
        let imageID = "photoImage" + randomString(length: 5)
        
        let imagesRef = Storage.storage().reference().child("UsersPhoto").child(userID).child(imageID) /// Создаем ссылку на файл
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { /// Преобразуем в Jpeg c сжатием
            return false
        }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg" /// Указываем явный тип данных в FireBase
        
        imagesRef.putData(imageData,metadata: metaData) { metadata, erorr in
            
            
            if let err = erorr {
                print(err)
            }
            else {
                imagesRef.downloadURL { url, error in /// Получаем URL адрес фото
                    
                    if let url = url {
                        if uploadDataToFirestore(url: url, imageID: imageID) {
                            successfulUpload = true
                        }
                    }
                }
            }
        }
        
        return successfulUpload
    }
    
    
    
    func uploadDataToFirestore(url:URL,imageID: String) -> Bool {
     
        var successfulUpload = false
        
        let db = Firestore.firestore().collection("Users").document(userID) /// Добавляем в FiresStore ссылку на фото
        
        db.setData([imageID : url.absoluteString],merge: true) { err in
            if let error = err {
                print(error)
            }else{ /// В случае успешного выполнения обновляем архив
                successfulUpload = true
            }
        }
        return successfulUpload
    }
    
}







extension FirebaseStorageModel {
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
