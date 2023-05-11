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
    
    private var currentUserID = String()
    private let db = Firestore.firestore()
    
    init(currentUserID: String) {
        self.currentUserID = currentUserID
    }
    
  
    
//MARK: -  Загрузка URL пользователей
    
    func loadURLUsers(numberRequsetedUsers: Int,currentAuthUser: CurrentAuthUser,nonSwipedUsers: [String] = [String]()) async -> [String]? {
        
        if let arr = await FirebaseStorageModel().loadUsersID(countUser: numberRequsetedUsers,currentUser: currentAuthUser,nonSwipedUsers: nonSwipedUsers) { /// Загружаем определенное количество URL пользователей
            return arr
        }else {
            return nil
        }
    }
    
    
//MARK: -  Загрузка новых пользователей для их показа
    
    func loadUsers(urlUsersArr : [String],completion: @escaping([User]?,Error?) -> Void)
    {
        
        Task {
            
            var usersArr = [User]()
            var countIndex = 0
            
            if urlUsersArr.count == 0 {
                completion(nil,erorrLoadUsers.fewUsers(code: 0))
                return
            }
            
            for i in 0...urlUsersArr.count - 1 {
                
                
                let userMetadata = await FirebaseStorageModel().loadMetaDataNewUser(newUserID: urlUsersArr[i]) /// Загрузка метаданных о пользователе
                
                FirebaseStorageModel().loadUserFromServer(urlArrUser: userMetadata.urlPhotoArr!, userID: userMetadata.ID) { imageArrUser in
                    
                    if let imageArr = imageArrUser {
                        usersArr.append(User(name: userMetadata.name,age:userMetadata.age ,ID: urlUsersArr[i],imageArr: imageArr))
                        
                    }
                    countIndex += 1
                    if countIndex == urlUsersArr.count {
                        completion(usersArr,nil)
                    }
                }
                                                          
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
