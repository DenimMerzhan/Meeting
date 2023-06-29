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
    
    static let shared = CurrentAuthUser()
    
    var ID  = String()
    var name = String()
    var age = Int()
    
    var delegate: MatchArrHasBennUpdate?
    
    var avatar: UserPhoto? {
        get {
            return imageArr.first
        }
    }
    
    var imageArr = [UserPhoto]()
    
    private var listenerMatchArrID: ListenerRegistration?
    
    var matchArr = [User]()
    
    var likeArr = [String]()
    var disLikeArr = [String]()
    var superLikeArr = [String]()
    
    var potentialPairID = [String]()
    
    var newUsersLoading = Bool()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let fileManager = FileManager.default
    
    private init() {
    }
    
//MARK: -  Загрузка метаданных о текущем авторизованном пользователе с FireStore
    
    func loadMetadata() async {
        
        let collection  = db.collection("Users").document(ID)
        let photoCollection = db.collection("Users").document(ID).collection("Photo").order(by: "Position")
        listenMatchUserID()
        
            do {
                
                let docSnap = try await collection.getDocument()
                let photoSnap = try await photoCollection.getDocuments()
                
                if let dataDoc = docSnap.data()  {
                    
                    if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                        
                        self.name = name
                        self.age = age
                        
                        if let likeArr = dataDoc["LikeArr"] as? [String] {self.likeArr = likeArr}
                        if let disLikeArr = dataDoc["DisLikeArr"] as? [String] {self.disLikeArr = disLikeArr}
                        if let superLikeArr = dataDoc["SuperLikeArr"] as? [String] {self.superLikeArr = superLikeArr} /// Суперлайков может и не быть, поэтому не ставим guard
                        await loadNewPotenialPairs()
                        
                        for data in photoSnap.documents { /// Загрузка ссылок на фото в Storage
                            if let urlPhoto = data["URL"] as? String {
                                if data == photoSnap.documents.first {
                                    let image = await UserPhoto(frame: .zero, urlPhotoFromServer: urlPhoto, imageID: data.documentID,isAvatarCurrentUser: true)
                                    self.imageArr.append(image)
                                }else {
                                    let image = await UserPhoto(frame: .zero, urlPhotoFromServer: urlPhoto, imageID: data.documentID)
                                    self.imageArr.append(image)
                                }
                            }
                        }
                    }else {
                        print("Ошибка в преобразование данных о текущем пользователе")}
                }
                
            }catch{
                print("Ошибка получения ссылок на фото с сервера FirebaseFirestore - \(error)")}
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
    
//MARK: -  Загрузка потеницальных пар для текущего пользователя
    
    func loadNewPotenialPairs() async {
        
        let collection  = db.collection("Users")
        let viewedUsers = likeArr + disLikeArr + superLikeArr + [ID]
        print(viewedUsers.count, "количество ограничений")
        
        do {
            let documents = try await collection.getDocuments()
            for document in documents.documents {
                if viewedUsers.contains(document.documentID)  {continue}
                self.potentialPairID.append(document.documentID)
            }
        }catch{
            
        }
    }

    //MARK: -  Загрузка фото на сервер
    
    func uploadImageToStorage(image: UIImage) async -> Bool  {
        
        let imageID = "photoImage" + "".randomString(length:10)
        let photoColletcion = db.collection("Users").document(ID).collection("Photo").document(imageID)
        let imagesRef = storage.reference().child("UsersPhoto").child(ID).child(imageID) /// Создаем ссылку на файл
        
        guard let imageData = image.jpegData(compressionQuality: 0.0) else { /// Преобразуем в Jpeg c сжатием
            return false
        }
        
        do {
            try await imagesRef.putDataAsync(imageData)
            let url = try await imagesRef.downloadURL()
            
            try await photoColletcion.setData(["URL" : url.absoluteString],merge: true)
            try await photoColletcion.setData(["Position" : imageArr.count],merge: true)
            
            await imageArr.append(UserPhoto(frame: .zero, urlPhotoFromServer: url.absoluteString, imageID: imageID))
            return true
        }catch {
            print(error)
            return false
        }
    }
    
    
//MARK: - Удаление фото с сервера Storage и Firestore
    
    func removePhotoFromServer(imageID:String){
        
        let imagesRef = storage.reference().child("UsersPhoto").child(ID).child(imageID)
        let imageFirebaseRef = db.collection("Users").document(ID).collection("Photo").document(imageID)
        imagesRef.delete { error in
            if let err = error {
                print("Ошибка удаления фото с хранилища Firebase \(err)")
            }else {
                imageFirebaseRef.delete()
                self.shufflePhotoOnServer()
            }
        }
    }
    
    func shufflePhotoOnServer(){
        
        let photoRef = db.collection("Users").document(ID).collection("Photo").order(by: "Position")
        let imageArr = self.imageArr
        print("dwwd")
        photoRef.getDocuments { QuerySnapshot, err in
            if let error = err {print("Ошибка перетасовки фото - \(error)")}
            guard let documents = QuerySnapshot?.documents else {return}
            
            for i in 0...imageArr.count - 1 {
                let documentID = documents[i].documentID
                let refImage = documents[i].reference
                guard let postionPhotoOnServer = documents[i].data()["Position"] as? Int else {return}
                
                if imageArr[i].imageID == documentID && i != postionPhotoOnServer {
                    refImage.setData(["Position" : i],merge: true)
                    self.shufflePhotoOnServer()
                    return
                    }
            }
        }
        
    }
    
}


//MARK: -  Проверка на матч пользователя

extension CurrentAuthUser {
    
    func checkMatch(potetnialPairID:String) async -> Bool {
        
        let documenRef = db.collection("Users").document(potetnialPairID)
        
        do {
            
            guard let document = try await documenRef.getDocument().data() else {return false}
            
            if let likeArr = document["LikeArr"] as? [String], let superLikeArr = document["SuperLikeArr"] as? [String] {
                
                if likeArr.contains(ID) || superLikeArr.contains(ID) {
                    writeMatch(potetnialPairID: potetnialPairID)
                    return true
                }
            }
        }
        
        catch {
            print("Ошибка поиска пары для пользователя - \(error)")
        }
        return false
    }
    
    
    //MARK: - Запись в архив Match
    
    private func writeMatch(potetnialPairID:String){
        
        Task {
            var matchArrPairUser = [String]()
            let currentUserRef = db.collection("Users").document(ID)
            let matchUserRef = db.collection("Users").document(potetnialPairID)
            
            var matchArrID = [String]() /// Cоздаем новый МатчАрр что бы в последтвии записать его на сервер
            for user in matchArr {
                matchArrID.append(user.ID)
            }
            matchArrID.append(potetnialPairID)
            
            var chatID = String()
            
            if ID > potetnialPairID {
                chatID = ID + "\\" + potetnialPairID
            }else {
                chatID = potetnialPairID + "\\" + ID
            }
            
            try await db.collection("Chats").document(chatID).setData(["DateMatch" : Date().timeIntervalSince1970], merge: true) /// Создаем чат с датой матча
            
            do {
                guard let pairData = try await matchUserRef.getDocument().data() else {return}
                if let arrPair = pairData["MatchArr"] as? [String] {
                    matchArrPairUser = arrPair
                }
                matchArrPairUser.append(ID)
                
                matchUserRef.setData(["MatchArr" : matchArrPairUser],merge: true) { Error in
                    if let err = Error {
                        print("Ошибка записи в MatchArr - \(err)")
                    }
                }
            }catch {
                print("Ошибка загрузки MatchArr другого пользователя")
            }
            
            currentUserRef.setData(["MatchArr" : matchArrID],merge: true) { Error in
                if let err = Error {
                    print("Ошибка записи в MatchArr - \(err)")
                }
            }
        }
    }
    
}

//MARK: -  Удаление пары

extension CurrentAuthUser {

    func deletePair(user:User){
        
        let chatID = user.chatID
        var matchArrID = [String]()
        
        for user in matchArr {
            matchArrID.append(user.ID)
        }
        
        db.collection("Chats").document(chatID).collection("Messages").getDocuments { [self] querySnapshot, err in
            if err != nil {
                print("Ошибка получения чата для удаления - \(err!)")}
            
            matchArrID.removeAll(where: {$0 == user.ID})
            self.likeArr.removeAll(where: {$0 == user.ID})
            self.superLikeArr.removeAll(where: {$0 == user.ID})
            
            self.db.collection("Users").document(self.ID).setData(["LikeArr" : self.likeArr],merge: true)
            self.db.collection("Users").document(self.ID).setData(["SuperLikeArr" : self.superLikeArr],merge: true)
            
            user.deleteUserMatchArr(currentAuthUserID: self.ID) /// Удаляем из архива МатчАрр текущего пользователя
//            user.deleteLikeUser(currentAuthUserID: self.ID) /// Удаляем из архива лайков текущего пользователя
            
            self.db.collection("Users").document(self.ID).setData(["MatchArr" : matchArrID],merge: true) /// Удаляем пользователя из матч арр у текущего пользователя
            
            guard let documents = querySnapshot?.documents else {return}
            
            for document in documents { /// Удаляем чат
                let ref = document.reference
                ref.delete { err in
                    if let error = err {
                        print("Ошибка удаления чата - \(error)")}
                }
            }
            db.collection("Chats").document(chatID).delete() /// Удаляем документ
            print("Успешное удаления чата")
        }
    }
    
    //MARK:  - Прослушивание MatchUserID
    
    func listenMatchUserID(){
        
        listenerMatchArrID?.remove()
        
        let listener = db.collection("Users").document(ID).addSnapshotListener { docSnap, err in
            if let error = err {print("Ошибка загрузки пользователей Match - \(error)")}
            guard let document = docSnap else {return}
            print("Прослушка MatchUserID")
            
            if let matchArrID = document["MatchArr"] as? [String] {
                Task {
                    for ID in matchArrID {
                        if self.matchArr.contains(where: {$0.ID == ID}) {continue}
                        let matchUser = User(ID: ID,currentAuthUserID: self.ID)
                        await matchUser.loadMetaData()
                        self.matchArr.append(matchUser)
                    }
                    self.checkIsDeleteUser(matchArrIdOnServer: matchArrID)
                }
            }
        }
        listenerMatchArrID = listener
    }
    
//MARK: -  Проверка удалили ли пользователей
    
    func checkIsDeleteUser(matchArrIdOnServer: [String]){ /// Проверка есть удалили ли какого то пользователя с сервера
        
        if matchArr.count == 0 {return}
        
        for i in 0...matchArr.count - 1 {
            let user = matchArr[i]
            if matchArrIdOnServer.contains(where: {$0 == user.ID}) == false { /// Если такого ID нету на сервере то значит пользователя удалили из пар
                user.chat = nil
                matchArr.remove(at: i)
                delegate?.updateDataWhenUserDelete()
            }
        }
        delegate?.updateDataWheTheMatchArrUpdate() /// Обновляем данные
    }
}


//MARK:  - Отправка сообщения

extension CurrentAuthUser {
    
    func sendMessageToServer(user: User,body:String) {
        
        var chatRef: DocumentReference? = nil
        
        chatRef = db.collection("Chats").document(user.chatID).collection("Messages").addDocument(data: [
            "Sender": ID,
            "Body": body,
            "Date": Date().timeIntervalSince1970,
            "MessageRead": false,
            "MessageSendOnServer": false,
            "MessageLike": false
        ]) { err in
            if let error = err {
                print("Ошибка отправки сообщения - \(error)")
            }else {
                print("Успешная отправка сообщения")
                
                if let ref = chatRef {
                    ref.setData([
                        "Date": Date().timeIntervalSince1970,
                        "MessageSendOnServer": true
                    ],merge: true)
                }
            }
        }
    }
}


