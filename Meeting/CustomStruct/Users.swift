//
//  LoadUsers.swift
//  Meeting
//
//  Created by Деним Мержан on 26.04.23.
//

import Foundation
import UIKit


struct Users {
    
    func loadFirtsUsers(countUsers: Int, completion: @escaping([User]?,Error?) -> Void) {
        

        Task {
            
            var usersArr = [User]()
            var usersIDArr = [String]()
            var countIndex = 0
            
            if let arr = await FirebaseStorageModel().loadUsersID(countUser: countUsers) {
                usersIDArr = arr
                print(usersIDArr.count, "Count ")
            }
            
            if countUsers > usersIDArr.count {
                completion(nil,erorrLoadUsers.fewUsers(code: usersIDArr.count))
                return
            }
            
            for i in 0...countUsers - 1 {
                
                FirebaseStorageModel().loadUsersFromServer(currentUserID: usersIDArr[i]) { user in
                
                    if let newUser = user {
                        usersArr.append(User(name: newUser.name,age:newUser.age ,imageArr: newUser.imageArr))
//                        usersIDArr.remove(at: i)
                    }
                    countIndex += 1
                    if countIndex == countUsers {
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
