//
//  User.swift
//  Meeting
//
//  Created by Деним Мержан on 20.04.23.
//

import Foundation
import UIKit


struct User {
    
    var name = String()
    var age = Int()
    var ID = String()
    var imageArr = [UIImage()]
    var urlPhotoArr: [String]?
    
}


struct CurrentAuthUser {
    
    var name = String()
    var age = Int()
    var ID  = String()
    
    var likeArr = [String]()
    var disLikeArr = [String]()
    var superLikeArr = [String]()
}



struct CurrentUserFile {
    
    var nameFile = String()
    var image = UIImage()
    
}
