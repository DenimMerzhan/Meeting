//
//  LoadUsers.swift
//  Meeting
//
//  Created by Деним Мержан on 26.04.23.
//

import Foundation
import UIKit


struct Users {
    
    func loadUsers(completion: @escaping([User]?) -> Void ) {
        
        var usersArr = [User]()
        let usersIDArr = ["+79213229900","+374788092","+79218909922","+79817550000"]
        
        for userID in usersIDArr {
            
            FirebaseStorageModel().loadImageFromServer(currentUserID: userID, completion: { imageUser in
                if imageUser != nil {
                    usersArr.append(User(name: "Джозефина",age:48 ,imageArr: imageUser!))
                }
                if userID == usersIDArr.last {
                    completion(usersArr)
                }else {
                    completion(nil)
                }
            })
        }
        
        
    }
    
}
