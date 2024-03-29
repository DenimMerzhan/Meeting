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
    
    var avatar: UserPhoto? {
        get {
            return imageArr.first
        }
    }
    
    var imageArr = [UserPhoto]()
    
    private let db = Firestore.firestore()
   
    init(ID:String,currentAuthUserID: String) {
        self.ID = ID
        self.currentAuthUserID = currentAuthUserID
        
        loadChat()
    }
    
//MARK: - Загрузка метаданных о пользователе с сервера
    
    func loadMetaData() async {
        
        let collection  = db.collection("Users").document(ID)
        let photoCollection  = db.collection("Users").document(ID).collection("Photo").order(by: "Position")
        
        do {
            let docSnap = try await collection.getDocument()
            let photoSnap = try await photoCollection.getDocuments()
            if let dataDoc = docSnap.data() {
                
                if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                    self.name = name
                    self.age = age
                    
                    for data in photoSnap.documents { /// Загрузка ссылок на фото в Storage
                        if let urlPhoto = data["URL"] as? String {
                            let image = await UserPhoto(frame: .zero, urlPhotoFromServer: urlPhoto, imageID: data.documentID)
                            self.imageArr.append(image)
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
    
//MARK: -  Загрузка чата
    
    private func loadChat() {
        
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



