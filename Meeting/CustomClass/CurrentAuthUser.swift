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
    
    private var matchArrID: [String] {
        get {
            var currentMatchArr = [String]()
            for user in matchArr {
                currentMatchArr.append(user.ID)
            }
            return currentMatchArr
        }
    }
    
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
        
        do {
            
            let docSnap = try await collection.getDocument()
            if let dataDoc = docSnap.data() {
                
                if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                    
                    self.name = name
                    self.age = age
                    
                    if let likeArr = dataDoc["LikeArr"] as? [String] {self.likeArr = likeArr}
                    if let disLikeArr = dataDoc["DisLikeArr"] as? [String] {self.disLikeArr = disLikeArr}
                    if let superLikeArr = dataDoc["SuperLikeArr"] as? [String] {self.superLikeArr = superLikeArr}
                    
                    if let matchArr = dataDoc["MatchArr"] as? [String] { /// Загрузка MatchArr и чатов
                        for matchID in matchArr {
                            await loadMatchUser(ID: matchID)
                                                        
                            if let chat = await loadChats(pairUserID: matchID) {
                                chatArr.append(chat)
                            }
                        }
                    }
                    
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
            
            db.collection("Chats").document(ID + "\\" + potetnialPairID).collection("Messages").document("Test").setData(["Test" : 0]) { Error in
                if let err = Error {
                    print("Ошибка создания тестового чата - \(err)")
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
            let snapChat = try await db.collection("Chats").document(chatID).getDocument()
            let dateLastMessageRead = snapChat.data()?[ID + "-DateOfLastMessageRead"] as? Double ?? 0
            
            if snapShot.isEmpty {return nil}
            
            var chat = Chat(ID: chatID)
            for doc in snapShot.documents {
                if let sender = doc.data()["Sender"] as? String, let body = doc.data()["Body"] as? String,let date = doc.data()["Date"] as? Double {
                    if date <= dateLastMessageRead { /// Если пользователь прочитал это сообшение, то добавляем его в архив
                        chat.messages.append(message(sender: sender, body: body))
                    }
                }
            }
            return chat
        }catch {
         print("Ошибка получения чата - \(error)")
            return nil
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

}


//MARK:  - Отправка сообщения

extension CurrentAuthUser {
    
    func sendMessageToServer(pairUserID: String,body:String) -> Error? {
        var chatID = String()
        
        if ID > pairUserID {
            chatID = ID + "\\" + pairUserID
        }else {
            chatID = pairUserID + "\\" + ID
        }
        
        var errorSend: erorrMeeting?
        
        let chatRef = db.collection("Chats").document(chatID).collection("Messages")
        chatRef.addDocument(data: [
            "Sender": ID,
            "Body": body,
            "Date": Date().timeIntervalSince1970
        ]) { err in
            if let error = err {
                return  errorSend = erorrMeeting.messageNotSent(code: error)
            }
        }
        return nil
    }
}
