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
    
    var delegate: UserRemoveFromPair?
    
    var avatar: UIImage {
        get {
            if imageArr.count > 1 {
                return imageArr[0].image
            }else {
                return UIImage()
            }
        }
    }
    
    var urlPhotoArr = [String]()
    var imageArr = [CurrentUserImage]()
    
    //    private var matchArrID = [String]()
    private var listenerMatchArrID: ListenerRegistration?
    
    var matchArr = [User]()
    var chatArr = [Chat]()
    
    var likeArr = [String]()
    var disLikeArr = [String]()
    var superLikeArr = [String]()
    
    var numberPotenialPairsOnServer = Int()
    var currentUserLoaded = Bool()
    
    var newUsersLoading = Bool()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init(ID: String){
        self.ID = ID
    }
    
    //MARK: -  Загрузка метаданных о текущем авторизованном пользователе с FireStore
    
    func loadMetadata() async -> Bool {
        
        let collection  = db.collection("Users").document(ID)
        listenMatchUserID()
        
        do {
            
            let docSnap = try await collection.getDocument()
            if let dataDoc = docSnap.data() {
                
                if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                    
                    self.name = name
                    self.age = age
                    
                    if let likeArr = dataDoc["LikeArr"] as? [String] {self.likeArr = likeArr}
                    if let disLikeArr = dataDoc["DisLikeArr"] as? [String] {self.disLikeArr = disLikeArr}
                    if let superLikeArr = dataDoc["SuperLikeArr"] as? [String] {self.superLikeArr = superLikeArr} /// Суперлайков может и не быть, поэтому не ставим guard
                    
                    for data in dataDoc { /// Загрузка ссылок на фото в Storage
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
            currentUserLoaded = true /// Если фото у пользователя нету, то указываем что он загрузился
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
    
    //MARK: -  Загрузка потеницальных пар для текущего пользователя
    
    func loadNewPotenialPairs(countUser: Int,usersArr: [User]) async -> [String]? {
        var count = 0
        let collection  = db.collection("Users")
        var newUsersID = [String]()
        
        
        var nonSwipedArr = [String]()
        
        for user in usersArr {
            nonSwipedArr.append(user.ID)
        }
        
        let viewedUsers = likeArr + disLikeArr + superLikeArr + nonSwipedArr
        
        print(viewedUsers.count, "количество ограничений")
        do {
            let querySnapshot = try await collection.getDocuments()
            
            for document in querySnapshot.documents {
                
                if document.documentID == ID { /// Если текущий пользователь пропускаем его добавление
                    continue
                }else if viewedUsers.contains(document.documentID) { /// Если кто то есть в архиве viewedUsers тоже пропускаем егго
                    continue
                }
                
                newUsersID.append(document.documentID)
                count += 1
                if count == countUser {
                    break
                }
            }
            numberPotenialPairsOnServer = querySnapshot.count - newUsersID.count - viewedUsers.count - 1
            print("Количество потенциальных пар на сервере - \(numberPotenialPairsOnServer)")
        }catch{
            print("Ошибка загрузки ID пользователей - \(error)")
            return nil
        }
        return newUsersID
    }
    
    
    
    //MARK: -  Загрузка фото с директории
    
    func loadPhotoFromDirectory(urlFileArr: [URL]){
        
        for url in urlFileArr {
            
            if let newImage = UIImage(contentsOfFile: url.path) {
                let imageID = url.lastPathComponent
                imageArr.append(CurrentUserImage(imageID: imageID,image: newImage))
            }
            currentUserLoaded = true
        }
    }
    
    
    //MARK: -  Загрузка фото на сервер
    
    func uploadImageToStorage(image: UIImage) async -> Bool  {
        
        let imageID = "photoImage" + "".randomString(length: 5)
        
        let imagesRef = storage.reference().child("UsersPhoto").child(ID).child(imageID) /// Создаем ссылку на файл
        guard let imageData = image.jpegData(compressionQuality: 0.0) else { /// Преобразуем в Jpeg c сжатием
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
    
    
    //MARK: - Удаление фото с сервера Storage и Firestore
    
    func removePhotoFromServer(imageID:String){
        
        let imagesRef = storage.reference().child("UsersPhoto").child(ID).child(imageID)
        imagesRef.delete { [weak self] error in
            if let err = error {
                print("Ошибка удаления фото с хранилища Firebase \(err)")
            }else {
                self?.deletePhotoFromFirebase(imageId: imageID)
            }
        }
    }
    
    func deletePhotoFromFirebase(imageId: String){
        db.collection("Users").document(ID).updateData([imageId : FieldValue.delete()]) { err in
            if let error = err {print( "Ошибка удаления фото с Firestore \(error)")}
        }
    }
}


//MARK: -  Поиск пар для пользователя

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


//MARK: -  Загрузка чатов

extension CurrentAuthUser {
    
    func loadChats(pairUserID: String) async -> Chat? {
        
        var chatID = String()
        
        if ID > pairUserID {
            chatID = ID + "\\" + pairUserID
        }else {
            chatID = pairUserID + "\\" + ID
        }
        
        let messagesRef = db.collection("Chats").document(chatID).collection("Messages").order(by:"Date")
        
        do {
            let snapShot = try await messagesRef.getDocuments()
            var chat = Chat(ID: chatID)
            
            if snapShot.isEmpty {return chat}
            
            for doc in snapShot.documents {
                let data = doc.data()
                if let sender = data["Sender"] as? String, let body = data["Body"] as? String,let dateMessage = data["Date"] as? Double , let messageRead = data["MessageRead"] as? Bool, let messageSendOnServer = data["MessageSendOnServer"] as? Bool {
                    
                    if sender == pairUserID && messageRead == false {continue} /// Если текущий пользователь не читал сообщение пропускаем его добавление
                    
                    var message = message(sender: sender, body: body,dateMessage: dateMessage)
                    message.messagedWritingOnServer = messageSendOnServer
                    message.messageRead = messageRead
                    chat.messages.append(message)
                    
                }
            }
            return chat
        }catch {
            print("Ошибка получения чата - \(error)")
            return nil
        }
    }
    
    //MARK: -  Удаление чата
    
    func deleteChat(chatID:String, completion: @escaping() -> Void){
        guard let indexChat = chatArr.firstIndex(where: {$0.ID == chatID}) else {return}
        print(chatID)
        db.collection("Chats").document(chatID).collection("Messages").getDocuments { querySnapshot, err in
            if err != nil {
                print("Ошибка удаления чата - \(err!)")
                completion()
            }
            guard let documents = querySnapshot?.documents else {return}
            for document in documents {
                let ref = document.reference
                ref.delete { err in
                    if let error = err {
                        print("Ошибка удаления чата - \(error)")
                        completion()
                    }
                }
            }
            self.chatArr.remove(at: indexChat)
            print("Успешное удаления чата")
            completion()
        }
    }
    
    
    //MARK: -  Загрузка MatchUser
    
    func loadMatchUser(ID:String) async {
        
        var matchUser = User(ID: ID)
        await matchUser.loadMetaData()
        guard let avatarUrl = matchUser.urlPhotoArr.last else {return}
        if let fileAvatar = await FirebaseStorageModel().loadPhotoToFile(urlPhotoArr: [avatarUrl], userID: matchUser.ID, currentUser: false) {
            matchUser.loadPhotoFromDirectory(urlFileArr: fileAvatar)
        }else {
            return
        }
        self.matchArr.append(matchUser)
    }
    
    
    //MARK:  - Прослушивание MatchUserID
    
    func listenMatchUserID(){
        
        listenerMatchArrID?.remove()
        
        let listener = db.collection("Users").document(ID).addSnapshotListener { docSnap, err in
            if let error = err {print("Ошибка загрузки пользователей Match - \(error)")}
            guard let document = docSnap else {return}
            print("Прослушка MatchUserID")
            if document.metadata.hasPendingWrites {
                print("MatchArr From Cache")
                return} /// Если сообщения взято из кеша выходим
            
            if let matchArrID = document["MatchArr"] as? [String] {
                
                Task {
                    
                    for ID in matchArrID {
                        
                        if self.matchArr.contains(where: {$0.ID == ID}) {continue}
                        
                        if let chat = await self.loadChats(pairUserID: ID) {
                            self.chatArr.append(chat)
                            print("Добавлен чат")
                            print(self.chatArr.count, "ChatArr - Count")
                        }
                        await self.loadMatchUser(ID: ID)
                    }
                    self.checkIsDeleteUser(matchArrIdOnServer: matchArrID)
                }
            }
            
        }
        listenerMatchArrID = listener
    }
    
    func checkIsDeleteUser(matchArrIdOnServer: [String]){
        
        for i in 0...matchArr.count - 1 {
            let userID = matchArr[i].ID
            guard let chatIndex = chatArr.firstIndex(where: {$0.ID.contains(userID)}) else {continue}
            if matchArrIdOnServer.contains(where: {$0 == userID}) == false { /// Если такого ID нету на сервере то значит пользователя удалили из пар
                matchArr.remove(at: i)
                chatArr.remove(at: chatIndex)
                delegate?.ShouldUpdateDataWhenTheUserDelete()
            }
        }
        
    }
}


//MARK:  - Отправка сообщения

extension CurrentAuthUser {
    
    func sendMessageToServer(pairUserID: String,body:String) {
        var chatID = String()
        print("StartSend")
        if ID > pairUserID {
            chatID = ID + "\\" + pairUserID
        }else {
            chatID = pairUserID + "\\" + ID
        }
        
        var chatRef: DocumentReference? = nil
        
        chatRef = db.collection("Chats").document(chatID).collection("Messages").addDocument(data: [
            "Sender": ID,
            "Body": body,
            "Date": Date().timeIntervalSince1970,
            "MessageRead": false,
            "MessageSendOnServer": false
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


