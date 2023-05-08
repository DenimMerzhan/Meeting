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
        
        var usersArr = [User]()
        var usersIDArr = ["+79213229900","+374788092","+79218909922","+79817550000","+79213229988","+374788021","+79218909943","+79817550082"]
        var countIndex = 0
        

        if countUsers > usersIDArr.count {
            completion(nil,erorrLoadUsers.fewUsers(code: usersIDArr.count))
            return
        }
        
        for i in 0...countUsers - 1 {
            
            FirebaseStorageModel().loadUsersFromServer(currentUserID: usersIDArr[i]) { user in
                print(countIndex)
                if let newUser = user {
                    usersArr.append(User(name: newUser.name,age:newUser.age ,imageArr: newUser.imageArr))
                   print("Yeah")
                    usersIDArr.remove(at: i)
                }
                countIndex += 1
                if countIndex == countUsers {
                    completion(usersArr,nil)
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
