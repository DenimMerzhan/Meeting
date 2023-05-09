//
//  LoadUsers.swift
//  Meeting
//
//  Created by Деним Мержан on 26.04.23.
//

import Foundation
import UIKit
import FirebaseFirestore


struct UsersModel {
    
    var currentUserID = String()
    private let db = Firestore.firestore()
    
    
    func loadUsers(countUsers: Int, completion: @escaping([User]?,Error?) -> Void) {
        

        Task {
            
            var usersArr = [User]()
            var usersIDArr = [String]()
            var countIndex = 0
            print(currentUserID)
            if let arr = await FirebaseStorageModel().loadUsersID(countUser: countUsers,currentUserID: currentUserID) { /// Загружаем определенное количество URL пользователей
                usersIDArr = arr
                print(usersIDArr.count, "Count ")
            }
            
            if countUsers > usersIDArr.count {
                completion(nil,erorrLoadUsers.fewUsers(code: usersIDArr.count))
                return
            }
            
            for i in 0...countUsers - 1 {
                
                FirebaseStorageModel().loadUsersFromServer(newUserID: usersIDArr[i]) { user in
                
                    if let newUser = user {
                        usersArr.append(User(name: newUser.name,age:newUser.age ,ID: usersIDArr[i],imageArr: newUser.imageArr))
                        
                    }
                    countIndex += 1
                    if countIndex == countUsers {
                        completion(usersArr,nil)
                    }
                }
            }
        }
    }
    
    
    //MARK: -  Запись архива лайка, дизлайка или супер лайка на сервер
        
    
    func writingPairsInfrormation(likeArr:[String],disLikeArr: [String],superLikeArr: [String]){
        let documenRef = db.collection("Users").document(currentUserID)
        
        documenRef.setData([
            "LikeArr" : likeArr,
            "DisLikeArr" : disLikeArr,
            "SuperLikeArr": superLikeArr
        ],merge: true) { err in
            if let error = err {
                print("Ошибка записи данных о парах пользователя - \(error)")
            }
            
        }
    }
    
//MARK: -  Получение данных о парах пользователя
    
    func getUserInformationAboutPairs() -> (likeArr: [String],disLikeArr: [String],superLikeArr: [String]){
        
        let documentRef = db.collection("Users").document(currentUserID)
        var likeArr = [String]()
        var disLikeArr = [String]()
        var superLikeArr = [String]()
        
        documentRef.getDocument { Snapshot, err in
            
            if let error = err {
                print("Ошибка получения архива статиситики пар пользователя \(error)")
                return
            }
            
            if let dataArr = Snapshot?.data() as? [String:Any]{
                if let userLikeArr = dataArr["LikeArr"] as? [String] {
                    likeArr = userLikeArr
                }else if let disArr = dataArr["DislikeArr"] as? [String]{
                    disLikeArr = disArr
                }else if let superArr = dataArr["SuperLikeArr"] as? [String]{
                    superLikeArr = superArr
                }
            }
        }
        
        return (likeArr,superLikeArr,disLikeArr)
        
    }
    
}


enum erorrLoadUsers: Error {
  
    case fewUsers(code:Int)
}

extension erorrLoadUsers: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .fewUsers(let code):
            return "Оставщихся пользователей меньше чем запрошенных. Оставшихся пользователей - " + String(code)
        }
    }
}
