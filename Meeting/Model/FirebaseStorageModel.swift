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
    
    
    func loadUserFromServer(urlArrUser: [String],userID: String, completion: @escaping ([UIImage]?) -> Void) {
        
        Task {
            
            if urlArrUser.count == 0 {
                print("Нет фото у пользователя по этому ID \(userID)")
                completion(nil)
                return
            }
            var imageArr = [UIImage]()
            var countIndex = 0
            var urlArr = urlArrUser
            
            for urlPhoto in urlArr {
                
                let Reference = storage.reference(forURL: urlPhoto)
                
                Reference.getData(maxSize: Int64(1*2048*2048)) { data, erorr in
                   
                    if let err = erorr {
                        print("Ошибка загрузки данных изображения с FirebaseStorage \(err)")
                        completion(nil)
                        urlArr.removeAll()
                        return
                    }else {
                        if let image = UIImage(data: data!) {
                            imageArr.append(image)
                        }
                        countIndex += 1
                    }
                    
                    if countIndex == urlArr.count {
                        completion(imageArr)
                    }
                }
                
            }
        }
        
    }
    
    
//MARK: -  Загрузка метаданных о пользователе с FireStore
    
    func loadMetaDataNewUser(newUserID: String) async -> User {
        
        var newUser = User(ID: newUserID, urlPhotoArr: [String]())
        let collection  = db.collection("Users").document(newUserID)
        
        do {
            let docSnap = try await collection.getDocument()
            if let dataDoc = docSnap.data() {
                
                if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                    newUser.name = name
                    newUser.age = age
                    
                    for data in dataDoc {
                        if data.key.contains("photoImage") {
                            if let urlPhoto = data.value as? String {
                                newUser.urlPhotoArr?.append(urlPhoto)
                            }
                        }
                    }
                    
                }else {
                    print("Ошибка в преобразование имени и возраста у данного пользователя \(newUserID)")
                }
            }
            
        }catch{
            print("Ошибка получения ссылок на фото с сервера FirebaseFirestore - \(error)")
        }
        return (newUser)
    }
  
//MARK: -  Загрузка метаданных о текущем авторизованном пользователе с FireStore
        
    func loadMetadataDataCurrentUser(currentUserID: String) async -> CurrentAuthUser? {
        
        var currentUser = CurrentAuthUser(ID: currentUserID)
        let collection  = db.collection("Users").document(currentUserID)
        
        do {
            let docSnap = try await collection.getDocument()
            if let dataDoc = docSnap.data() {
                
                
                
                if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                    
                    currentUser.name = name
                    currentUser.age = age
                    
                    if let likeArr = dataDoc["LikeArr"] as? [String], let disLikeArr = dataDoc["DisLikeArr"] as? [String], let superLikeArr = dataDoc["SuperLikeArr"] as? [String]  {
                        currentUser.likeArr = likeArr
                        currentUser.disLikeArr = disLikeArr
                        currentUser.superLikeArr = superLikeArr
                    }
                    
                    
                    for data in dataDoc {
                        if data.key.contains("photoImage") {
                            if let urlPhoto = data.value as? String {
                                currentUser.urlPhotoArr.append(urlPhoto)
                            }
                        }
                    }
                    
                }else {
                    print("Ошибка в преобразование данных о текущем пользователе")
                    return nil
                }
            }
            
        }catch{
            print("Ошибка получения ссылок на фото с сервера FirebaseFirestore - \(error)")
            return nil
        }
        return (currentUser)
    }
    
//MARK: - Загрузка определленого количества ID пользователей, кроме текущего пользователя
    
    func loadUsersID(countUser: Int,currentUser:CurrentAuthUser) async -> [String]? {
        var count = 0
        let collection  = db.collection("Users")
        var userIDArr = [String]()
        var i = 0
        
        let viewedUsers = currentUser.likeArr + currentUser.disLikeArr + currentUser.superLikeArr
        print(viewedUsers.count, "количество ограничений")
        do {
            let querySnapshot = try await collection.getDocuments()
            
            for document in querySnapshot.documents {
                print(document.documentID)
                
                if document.documentID == currentUser.ID { /// Если текущий пользователь пропускаем его добавление
                   continue
                }else if viewedUsers.contains(document.documentID) {
                    continue
                }
                userIDArr.append(document.documentID)
                count += 1
                if count == countUser {
                    break
                }
            }
            
            print(querySnapshot.count, "Количество элементов в снапшоте ")
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
