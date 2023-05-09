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
    
    init(userID: String = String()) {
        self.currentUserID = userID
    }
    
    
    
//MARK: -  Загрузка фото на сервер
    
    func uploadImageToStorage(image: UIImage) async -> (succes:Bool,fileName:String)  {
        
        let imageID = "photoImage" + randomString(length: 15)
        
        let imagesRef = storage.reference().child("UsersPhoto").child(currentUserID).child(imageID) /// Создаем ссылку на файл
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { /// Преобразуем в Jpeg c сжатием
            return (false,"")
        }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg" /// Указываем явный тип данных в FireBase
        
        do {
            try await imagesRef.putDataAsync(imageData)
            let url = try await imagesRef.downloadURL()
            let status = await uploadDataToFirestore(url: url, imageID: imageID)
            if status {
                let fileName = savePhotoToUserPhone(image: image, fileName: imageID)
                return (status,fileName)
            }
        }catch {
            print(error)
            return (false,"")
        }
        return(false,"")
    }
    
    
    private func uploadDataToFirestore(url:URL,imageID: String) async -> Bool {
     
        let colletcion = db.collection("Users").document(currentUserID) /// Добавляем в FiresStore ссылку на фото\
        
        do {
           try await colletcion.setData([imageID : url.absoluteString], merge: true)
            return true
        }catch{
            print("Ошибка загрузки данных фото на сервер Firebase Firestore \(error)")
            return false
        }
    }
    

    
//MARK: -  Загрузка фото пользователя с сервера
    
    
    func loadUsersFromServer(newUserID: String, completion: @escaping (User?) -> Void) {
        
        Task {
            
            var newUser = await loadDataUser(newUserID: newUserID)
            if newUser.urlPhotoArr?.count == 0 {
                print("Нет фото у пользователя по этому ID \(currentUserID)")
                completion(nil)
                return
            }
            var user = User(name: newUser.name,age: newUser.age,imageArr: [UIImage]())
            var countIndex = 0
            
            for urlPhoto in newUser.urlPhotoArr! {
                
                let Reference = storage.reference(forURL: urlPhoto)
                
                Reference.getData(maxSize: Int64(1*2048*2048)) { data, erorr in
                   
                    if let err = erorr {
                        print("Ошибка загрузки данных изображения с FirebaseStorage \(err)")
                        newUser.urlPhotoArr!.removeAll()
                        completion(nil)
                        return
                    }else {
                        if let image = UIImage(data: data!) {
                            user.imageArr.append(image)
                        }
                        countIndex += 1
                    }
                    
                    if countIndex == newUser.urlPhotoArr!.count {
                        completion(user)
                    }
                }
                
            }
        }
        
    }
    
    
//MARK: -  Загрузка метаданных о пользователе с FireStore
    
    private func loadDataUser(newUserID: String) async -> User {
        
        var newUser = User(urlPhotoArr: [String]())
        let collection  = db.collection("Users")
        
        do {
            let querySnapshot = try await collection.getDocuments()
            for document in querySnapshot.documents {
                if document.documentID == currentUserID {
                    for data in document.data() {
                        if data.key.contains("photoImage") {
                            if let url = data.value as? String {
                                newUser.urlPhotoArr?.append(url)
                            }
                        }else if data.key == "Name" {
                            if let name = data.value as?  String {
                                newUser.name = name
                            }
                        }else if data.key == "Age"{
                            if let age = data.value as?  Int {
                                newUser.age = age
                            }
                        }
                     }
                }
            }
        }catch{
            print("Ошибка получения ссылок на фото с сервера FirebaseFirestore - \(error)")
        }
        return (newUser)
    }
  
//MARK: - Загрузка определленого количества ID пользователей, кроме текущего пользователя
    
    func loadUsersID(countUser: Int,currentUserID: String) async -> [String]? {
        var count = 0
        let collection  = db.collection("Users")
        var userIDArr = [String]()
        do {
            let querySnapshot = try await collection.getDocuments()
            for document in querySnapshot.documents {
                
//                if document.documentID != currentUserID {
//                    userIDArr.append(document.documentID)
//                    count += 1
//                }
                userIDArr.append(document.documentID)
                count += 1
                if count == countUser {
                    break
                }
            }
        }catch{
            print("Ошибка загрузки ID пользователей - \(error)")
            return nil
        }
        return userIDArr
    }
    
    //MARK: - Удаление фото с сервера

    func removePhotoFromServer(userID:String,imageID:String){
        
        var newImageServerID = imageID /// Создаем новое имя файла для сервера
        if let dotRange = newImageServerID.range(of: ".") {
          newImageServerID.removeSubrange(dotRange.lowerBound..<newImageServerID.endIndex) /// Удаляем расширение
        }
        
        let imagesRef = storage.reference().child("UsersPhoto").child(userID).child(newImageServerID)
        imagesRef.delete { error in
            if let err = error {
                print("Ошибка удаления фото с сервера FirebaseStorage \(err)")
            }else {
                deletePhotoFromFirebase(imageId: newImageServerID)
                deletePhotoOnUserPhone(fileName: imageID)
            }
        }
    }
    
    func deletePhotoFromFirebase(imageId: String){
        let fieldID = "photoImage" + imageId
        db.collection("Users").document(currentUserID).updateData([fieldID : FieldValue.delete()]) { err in
            if let error = err {print( "Ошибка удаления фото с сервера FirebaseFirestore \(error)")}
        }
    }
}







//MARK:  - Сохранение фото пользователя на устройстве

private extension FirebaseStorageModel {
    
    func savePhotoToUserPhone(image: UIImage, fileName:String) -> String {
        
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else { /// Преобразуем фото в дата данные
            return ""
        }
        
        let userLibary = fileManager.urls(for: .documentDirectory, in: .userDomainMask) /// Стандартная библиотека пользователя
        let newFolder = userLibary[0].appendingPathComponent("CurrentUsersPhoto") as NSURL /// Добавляем к ней новую папку
        
        if checkDirectoryExist(directory: newFolder as URL) == false { /// Если директории нет создаем эту папку
            try! fileManager.createDirectory(at: newFolder as URL, withIntermediateDirectories: false)
        }
        
        do {
            try data.write(to: newFolder.appendingPathComponent("\(fileName).png")!) /// Создаем новый файл по директории
            return "\(fileName).png"
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    func checkDirectoryExist(directory: URL) -> Bool { /// Проверка существует ли директория по указаному пути
        let exists = FileManager.default.fileExists(atPath: directory.path)
        return exists
    }
    
}



//MARK:  - Удаление фото пользователя на устройстве

private extension FirebaseStorageModel {
    
    func deletePhotoOnUserPhone(fileName:String){
        
        let userLibary = fileManager.urls(for: .documentDirectory, in: .userDomainMask) /// Стандартная библиотека пользователя
        let filePath = userLibary[0].appendingPathComponent("CurrentUsersPhoto").appendingPathComponent(fileName) /// Добавляем к ней новую папку
        
        do {
            try fileManager.removeItem(at: filePath)
        } catch {
            print("Ошибка удаления файла с директории - ",error.localizedDescription)
        }
    }
}







//MARK: -  Расширение для формирования рандомного ID для фото - Надо исправить т.к есть шанс получить одинаковый ID

private extension FirebaseStorageModel {
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
