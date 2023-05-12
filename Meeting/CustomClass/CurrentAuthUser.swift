//
//  CurrentAuthUserID.swift
//  Meeting
//
//  Created by Деним Мержан on 10.05.23.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage


class CurrentAuthUser {
    
    
    var ID  = String()
    
    var name = String()
    var age = Int()
    
    var urlPhotoArr = [String]()
    var imageArr = [CurrentUserImage]()
    
    var likeArr = [String]()
    var disLikeArr = [String]()
    var superLikeArr = [String]()
    
    var couplesOver = Bool()
    var userLoaded = Bool()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
   
    init(ID: String){
        self.ID = ID
    }
    
    
    
    //MARK: -  Загрузка метаданных о текущем авторизованном пользователе с FireStore
            
    func loadMetadata() async -> Bool {
        
        let collection  = db.collection("Users").document(ID)
        
        do {
            
            let docSnap = try await collection.getDocument()
            if let dataDoc = docSnap.data() {
                
                if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                    
                    self.name = name
                    self.age = age
                    
                    if let likeArr = dataDoc["LikeArr"] as? [String], let disLikeArr = dataDoc["DisLikeArr"] as? [String], let superLikeArr = dataDoc["SuperLikeArr"] as? [String]  {
                        self.likeArr = likeArr
                        self.disLikeArr = disLikeArr
                        self.superLikeArr = superLikeArr
                    }
                    
                    
                    for data in dataDoc {
                        if data.key.contains("photoImage") {
                            if let urlPhoto = data.value as? String {
                                self.urlPhotoArr.append(urlPhoto)
                            }
                        }
                    }
                }else {
                    print("Ошибка в преобразование данных о текущем пользователе")
                    return false
                }
            }
            
        }catch{
            print("Ошибка получения ссылок на фото с сервера FirebaseFirestore - \(error)")
            return false
        }
        
        if urlPhotoArr.count == 0 {
            userLoaded = true /// Если фото у пользователя нету, то указываем что он загрузился
        }
        return true
    }

    
    
//MARK:  - Записиь информации о парах
    
    func writingPairsInfrormation(){
        
        
        let documenRef = db.collection("Users").document(ID)
    
        documenRef.setData([
            "LikeArr" : self.likeArr,
            "DisLikeArr" : self.disLikeArr,
            "SuperLikeArr": self.superLikeArr
        ],merge: true) { err in
            if let error = err {
                print("Ошибка записи данных о парах пользователя - \(error)")
            }
            
        }
    }
    
//MARK: -  Загрузка фото с директории
    
    func loadPhotoFromDirectory(urlFileArr: [URL]){
        
        for url in urlFileArr {
            if let newImage = UIImage(contentsOfFile: url.path) {
                let imageID = url.lastPathComponent
                imageArr.append(CurrentUserImage(imageID: imageID,image: newImage))
//                newImage = .remove
            }
            userLoaded = true
        }
    }
    
    
    //MARK: -  Загрузка фото на сервер
        
    func uploadImageToStorage(image: UIImage) async -> Bool  {
            
            let imageID = "photoImage" + "".randomString(length: 5)
            
            let imagesRef = storage.reference().child("UsersPhoto").child(ID).child(imageID) /// Создаем ссылку на файл
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { /// Преобразуем в Jpeg c сжатием
                return false
            }
            
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg" /// Указываем явный тип данных в FireBase
            
            do {
                try await imagesRef.putDataAsync(imageData)
                let url = try await imagesRef.downloadURL()
                let status = await uploadDataToFirestore(url: url, imageID: imageID)
                if status {
                    imageArr.append(CurrentUserImage(imageID: imageID,image: image))
                    return (status)
                }
            }catch {
                print(error)
                return false
            }
            return false
        }
        
        
        private func uploadDataToFirestore(url:URL,imageID: String) async -> Bool {
         
            let colletcion = db.collection("Users").document(ID) /// Добавляем в FiresStore ссылку на фото\
            
            do {
               try await colletcion.setData([imageID : url.absoluteString], merge: true)
                return true
            }catch{
                print("Ошибка загрузки данных фото на сервер Firebase Firestore \(error)")
                return false
            }
        }
    
    
    //MARK: - Удаление фото с сервера
    
    func removePhotoFromServer(imageID:String){
        
        let imagesRef = storage.reference().child("UsersPhoto").child(ID).child(imageID)
        imagesRef.delete { [unowned self] error in
            if let err = error {
                print("Ошибка удаления фото с хранилища Firebase \(err)")
            }else {
                self.deletePhotoFromFirebase(imageId: imageID)
            }
        }
    }
    
    func deletePhotoFromFirebase(imageId: String){
        db.collection("Users").document(ID).updateData([imageId : FieldValue.delete()]) { err in
            if let error = err {print( "Ошибка удаления фото с Firestore \(error)")}
        }
    }
}



