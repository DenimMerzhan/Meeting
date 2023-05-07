//
//  LoadUsers.swift
//  Meeting
//
//  Created by Деним Мержан on 26.04.23.
//

import Foundation
import UIKit


struct Users {
    
    func loadFirtsUsers(completion: @escaping([User]?) -> Void ) {
        
        var usersArr = [User]()
        let usersIDArr = ["+79213229900","+374788092","+79218909922","+79817550000"]
        var countIndex = 0
        
        for userID in usersIDArr {
            
            FirebaseStorageModel().loadImageFromServer(currentUserID: userID, completion: { imageUser in
                
                if imageUser != nil {
                    usersArr.append(User(name: "Джозефина",age:48 ,imageArr: imageUser!))
                }
                countIndex += 1
                if countIndex == usersIDArr.count {
                    completion(usersArr)
                }
                
            })
        }
    }
    
    func backgroundDowload30Users(){
        
    }
    
}
