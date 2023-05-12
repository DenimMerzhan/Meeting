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
    
    
    
////MARK: -  Загрузка фото на сервер
//    
//    func uploadImageToStorage(image: UIImage) async -> (succes:Bool,fileName:String)  {
//        
//        let imageID = "photoImage" + randomString(length: 15)
//        
//        let imagesRef = storage.reference().child("UsersPhoto").child(currentUserID).child(imageID) /// Создаем ссылку на файл
//        guard let imageData = image.jpegData(compressionQuality: 0.4) else { /// Преобразуем в Jpeg c сжатием
//            return (false,"")
//        }
//        
//        
//        let metaData = StorageMetadata()
//        metaData.contentType = "image/jpeg" /// Указываем явный тип данных в FireBase
//        
//        do {
//            try await imagesRef.putDataAsync(imageData)
//            let url = try await imagesRef.downloadURL()
//            let status = await uploadDataToFirestore(url: url, imageID: imageID)
//            if status {
//                return (status,imageID)
//            }
//        }catch {
//            print(error)
//            return (false,"")
//        }
//        return(false,"")
//    }
//    
//    
//    private func uploadDataToFirestore(url:URL,imageID: String) async -> Bool {
//     
//        let colletcion = db.collection("Users").document(currentUserID) /// Добавляем в FiresStore ссылку на фото\
//        
//        do {
//           try await colletcion.setData([imageID : url.absoluteString], merge: true)
//            return true
//        }catch{
//            print("Ошибка загрузки данных фото на сервер Firebase Firestore \(error)")
//            return false
//        }
//    }
    

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
    
    
//MARK: - Загрузка определленого количества ID пользователей
    
    func loadUsersID(countUser: Int,currentUser:CurrentAuthUser,nonSwipedUsers: [String] = [String]()) async -> [String]? {
        var count = 0
        let collection  = db.collection("Users")
        var userIDArr = [String]()
        
        let viewedUsers = currentUser.likeArr + currentUser.disLikeArr + currentUser.superLikeArr + nonSwipedUsers
        print(viewedUsers.count, "количество ограничений")
        do {
            let querySnapshot = try await collection.getDocuments()
            
            for document in querySnapshot.documents {
                
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
            print("Общее количество пользователей - \(querySnapshot.count)")
        }catch{
            print("Ошибка загрузки ID пользователей - \(error)")
            return nil
        }
        
        return userIDArr
    }
    
    
//    //MARK: - Удаление фото с сервера
//
//    func removePhotoFromServer(userID:String,imageID:String){
//
//        var newImageServerID = imageID /// Создаем новое имя файла для сервера
//        if let dotRange = newImageServerID.range(of: ".") {
//          newImageServerID.removeSubrange(dotRange.lowerBound..<newImageServerID.endIndex) /// Удаляем расширение
//        }
//
//        let imagesRef = storage.reference().child("UsersPhoto2").child(userID).child(newImageServerID)
//        imagesRef.delete { error in
//            if let err = error {
//                print("Ошибка удаления фото с сервера FirebaseStorage \(err)")
//            }else {
//                deletePhotoFromFirebase(imageId: newImageServerID)
//            }
//        }
//    }
//
//    func deletePhotoFromFirebase(imageId: String){
//        let fieldID = "photoImage" + imageId
//        db.collection("Users").document(currentUserID).updateData([fieldID : FieldValue.delete()]) { err in
//            if let error = err {print( "Ошибка удаления фото с сервера FirebaseFirestore \(error)")}
//        }
//    }
}






//MARK: -  Расширение для формирования рандомного ID для фото - Надо исправить т.к есть шанс получить одинаковый ID

private extension FirebaseStorageModel {
    
    func checkDirectoryExist(directory: URL) -> Bool { /// Проверка существует ли директория по указаному пути
        let exists = FileManager.default.fileExists(atPath: directory.path)
        return exists
    }
}

extension String {
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
