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
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init(userID: String = String()) {
        self.userID = userID
    }
    
    
//MARK: -  Загрузка фото на сервер
    
    func uploadImageToStorage(image: UIImage) async -> Bool {
        
        let imageID = "photoImage" + randomString(length: 5)
        
        let imagesRef = storage.reference().child("UsersPhoto").child(userID).child(imageID) /// Создаем ссылку на файл
        
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
    
    
    
    private func uploadDataToFirestore(url:URL,imageID: String) async -> Bool {
     
        let colletcion = db.collection("Users").document(userID) /// Добавляем в FiresStore ссылку на фото\
        
        do {
           try await colletcion.setData([imageID : url.absoluteString], merge: true)
            return true
        }catch{
            print(error)
            return false
        }
    }
    
    
    
//MARK: -  Заггрузка фото с сервера
    
    func loadImage() async -> [UIImage] {
        
        
        var imageArr = [UIImage]()
        let urlArr = await loadUrlImage()
        
        for url in urlArr {
            let pathReference = storage.reference(forURL: url)
            let megaByte = Int64(1*2048*2048)
            
            pathReference.getData(maxSize: megaByte) { data, error in
                if let err = error {
                    print(err)
                }else {
                    let image = UIImage(data: data!)
                    imageArr.append(image!)
                }
            }
        }
        
        return imageArr
    }
    
    
    private func loadUrlImage() async -> [String] {
        
        var urlArr = [String]()
        let collection  = db.collection("Users")
        
        do {
            let querySnapshot = try await collection.getDocuments()
            for document in querySnapshot.documents {
                if document.documentID == userID {
                    for data in document.data() {
                        if data.key.contains("photoImage") {
                            if let url = data.value as? String {
                                urlArr.append(url)
                            }
                        }
                    }
                }
            }
        }catch{
            print("Ошибка получения данных - \(error)")
        }
        return urlArr
    }
    
}









//MARK: -  Расширение для формирования рандомного ID для фото - Надо исправить т.к есть шанс получить одинаковый ID

private extension FirebaseStorageModel {
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
