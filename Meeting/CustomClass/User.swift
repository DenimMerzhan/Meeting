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
    
    init(ID:String,currentAuthUserID: String) {
        self.ID = ID
        self.currentAuthUserID = currentAuthUserID
        loadChat()
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
    
    
    //MARK: - Загрузка фото пользователя с директории
    
    func loadPhotoFromDirectory(urlFileArr: [URL] ){
        
        for url in urlFileArr {
            if let newImage = UIImage(contentsOfFile: url.path) {
                imageArr.append(newImage)
            }
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
                    
                    var message = message(sender: sender, body: body,dateMessage: dateMessage)
                    message.messagedWritingOnServer = messageSendOnServer
                    message.messageRead = messageRead
                    self?.chat?.messages.append(message)
                    
                }
            }
            
        }
    }
    
}





