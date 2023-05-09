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
    
    
    func loadUsers(currentAuthUser: CurrentAuthUser ,countUsers: Int, completion: @escaping([User]?,Error?) -> Void) {
        
        Task {
            
            var usersArr = [User]()
            var usersIDArr = [String]()
            var countIndex = 0
            
            if let arr = await FirebaseStorageModel().loadUsersID(countUser: countUsers,currentUser: currentAuthUser) { /// Загружаем определенное количество URL пользователей
                usersIDArr = arr
                print(usersIDArr.count, "Count ")
            }
            
            if countUsers > usersIDArr.count { /// Если URL меньше чем счетчик значит они заканчиваются
                completion(nil,erorrLoadUsers.fewUsers(code: usersIDArr.count))
                return
            }
            
            
            
            for i in 0...countUsers - 1 {
                
                
                let userMetadata = await FirebaseStorageModel().loadMetaDataNewUser(newUserID: usersIDArr[i])
                
                FirebaseStorageModel().loadUsersFromServer(newUser:userMetadata) { imageArrUser in
                
                    if let imageArr = imageArrUser {
                        usersArr.append(User(name: userMetadata.name,age:userMetadata.age ,ID: usersIDArr[i],imageArr: imageArr))
                        
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
