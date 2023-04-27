//
//  LoadUsers.swift
//  Meeting
//
//  Created by Деним Мержан on 26.04.23.
//

import Foundation
import UIKit


struct Users {
    
    func loadUsers() -> [User]{
        
        var usersArr = [User]()
        
        usersArr.append(User(name: "Карина",age: 22, imageArr: [UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!,UIImage(named: "4")!]))
        usersArr.append(User(name: "Света",age: 21, imageArr: [UIImage(named: "S1")!,UIImage(named: "S2")!,UIImage(named: "S3")!,UIImage(named: "S4")!,UIImage(named: "S5")!]))
        usersArr.append(User(name: "Екатерина",age: 27, imageArr: [UIImage(named: "K1")!,UIImage(named: "K2")!,UIImage(named: "K3")!]))
        usersArr.append(User(name: "Ольга",age: 32, imageArr: [UIImage(named: "O1")!,UIImage(named: "O2")!]))
        usersArr.append(User(name: "Викуся",age: 23, imageArr: [UIImage(named: "V1")!,UIImage(named: "V2")!,UIImage(named: "V3")!]))
        usersArr.append(User(name: "Таня",age: 26, imageArr: [UIImage(named: "T1")!,UIImage(named: "T2")!,UIImage(named: "T3")!]))
        
        return usersArr
    }
    
}
