//
//  User.swift
//  Meeting
//
//  Created by Деним Мержан on 20.04.23.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

class User {
    
    var ID: String
    var currentAuthUserID: String
    
    var chat: Chat?
    var chatID: String {
        get {
            if currentAuthUserID > ID {
                return currentAuthUserID + "\\" + ID
            }else {
               return ID + "\\" + currentAuthUserID
            }
        }
    }
    
    var name = String()
    var age = Int()
    
    
    var avatar: UIImage {
        get {
            if imageArr.count > 0 {
                return imageArr[0]
            }else {
                return UIImage()
            }
        }
    }
    
    var imageArr = [UIImage]()
    var urlPhotoArr = [String]()
    
    private let db = Firestore.firestore()
    private let fileManager = FileManager.default
    private let storage = Storage.storage()
    
    init(ID:String,currentAuthUserID: String) {
        self.ID = ID
        self.currentAuthUserID = currentAuthUserID
        loadChat()
    }
    
    
    func loadUser(){
        Task {
            await loadMetaData()
            loadChat()
        }
        
    }
//MARK: - Загрузка метаданных о пользователе с сервера
    
    func loadMetaData() async {
        
        let collection  = db.collection("Users").document(ID)
        
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
    
//MARK: -  Удаление фото пользователя с директории
    
    func cleanPhotoUser(){
        
        let userLibary = fileManager.urls(for: .documentDirectory, in: .userDomainMask) /// Стандартная библиотека пользователя
        let currentFolder = userLibary[0].appendingPathComponent("OtherUsersPhoto/\(ID)") /// Добавляем к ней новую папку
        
        do {
            try fileManager.removeItem(at: currentFolder)
        }catch{
            print("Ошибка удаления файла по этому - \(ID) , ошибка - \(error)")
        }
    }
    
//MARK: -  Загрузка чата
    
    func loadChat() {
        
        var chatID = String()
        
        if currentAuthUserID > ID {
            chatID = currentAuthUserID + "\\" + ID
        }else {
            chatID = ID + "\\" + currentAuthUserID
        }
        
        db.collection("Chats").document(chatID).collection("Messages").order(by:"Date").getDocuments { [weak self] querySnap, err in
            if let error = err {print("Ошибка получения чата - \(error)")}
            guard let snapShot = querySnap else {return}
            
            self?.chat = Chat(ID: chatID)
            
            for doc in snapShot.documents {
                let data = doc.data()
                if let sender = data["Sender"] as? String, let body = data["Body"] as? String,let dateMessage = data["Date"] as? Double , let messageRead = data["MessageRead"] as? Bool, let messageSendOnServer = data["MessageSendOnServer"] as? Bool {
                    
                    if sender == self?.ID && messageRead == false {continue} /// Если текущий пользователь не читал сообщение пропускаем его добавление
                    
                    var message = message(sender: sender, body: body,messagePathOnServer: doc.reference, dateMessage: dateMessage)
                    message.messagedWritingOnServer = messageSendOnServer
                    message.messageRead = messageRead
                    self?.chat?.messages.append(message)
                    
                }
            }
            
        }
    }
    
//MARK: -  Удаление пользователя из MatchArr, likeArr и SuperLikeArr
    
    func deleteUserMatchArr(currentAuthUserID: String){ /// Удаляем текущего авторизованного пользователя из архива данного пользователя
        let ID = self.ID
        
        db.collection("Users").document(ID).getDocument { [weak self] docSnap, err in
            
            if let error = err {print("Ошибка получения matchArr PairUser - \(error)")}
            
            if var matchArr = docSnap?.data()?["MatchArr"] as? [String] {
                matchArr.removeAll(where: {$0 == currentAuthUserID})
                self?.db.collection("Users").document(ID).setData(["MatchArr" : matchArr],merge: true) /// Удаляем у другого пользователя
            }
        }
    }
    
    func deleteLikeUser(currentAuthUserID: String){ /// Удаляем из архива лайка или суперлайка текущего авторизованного пользователя
        let ID = self.ID
        
        db.collection("Users").document(ID).getDocument { [weak self] docSnap, err in
            
            if let error = err {print("Ошибка получения matchArr PairUser - \(error)")}
            
            if var likeArr = docSnap?.data()?["LikeArr"] as? [String] {
                likeArr.removeAll(where: {$0 == currentAuthUserID})
                self?.db.collection("Users").document(ID).setData(["LikeArr" : likeArr],merge: true) /// Удаляем у другого пользователя
            }
            
            if var superLikeArr = docSnap?.data()?["SuperLikeArr"] as? [String] {
                superLikeArr.removeAll(where: {$0 == currentAuthUserID})
                self?.db.collection("Users").document(ID).setData(["SuperLikeArr" : superLikeArr],merge: true) /// Удаляем у другого пользователя
            }
        }
    }
}

//MARK: -  Загрузка фото

extension User {
    
    func loadPhoto(avatar:Bool) async {
        
        var urlFileArr = [URL]()
        if urlPhotoArr.count == 0 {return}
        imageArr.removeAll()
        
        let userLibary = fileManager.urls(for: .documentDirectory, in: .userDomainMask) /// Стандартная библиотека пользователя
        
        var newFolder = userLibary[0].appendingPathComponent("OtherUsersPhoto/\(ID)")
        
        if FileManager.default.fileExists(atPath: newFolder.path) == false { /// Если директории нет создаем эту папку
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
                print("Ошибка записи фото в директорию пользователя - \(error)")
            }
            if avatar {break} /// Если мы хотим загрузить только аватар, то выходим
        }
        loadPhotoFromDirectory(urlFileArr: urlFileArr)
    }

    
//MARK: - Загрузка фото пользователя с директории
        
        private func loadPhotoFromDirectory(urlFileArr: [URL] ){
            
            for url in urlFileArr {
                if let newImage = UIImage(contentsOfFile: url.path) {
                    imageArr.append(newImage)
                }
            }
        }
}


