//
//  CardViewClass.swift
//  Meeting
//
//  Created by Деним Мержан on 20.04.23.
//

import Foundation
import UIKit


class CardView: UIView {
    
    var imageUserView: UIImageView?
    var imageArr: [UIImage]?
    var userID = String()
    
    var likHeartImage = UIImageView()
    var dislikeHeartImage = UIImageView()
    var superLike = UIImageView()
    
    init(frame: CGRect, heartLikeImage: UIImageView = UIImageView(), heartDislikeImage: UIImageView = UIImageView(),imageUser: imageUserView?,imageArr: [UIImage]?,superLike: UIImageView,userID: String) {
        
        self.likHeartImage = heartLikeImage
        self.dislikeHeartImage = heartDislikeImage
        self.imageUserView = imageUser
        self.imageArr = imageArr
        self.superLike = superLike
        self.userID = userID
        
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("Объект CardView уничтожен")
    }
    
}   




class imageUserView: UIImageView {
    
    var nameUser = UILabel()
    var age = UILabel()
    var progressBar = [UIView]()
    
    
    init(frame:CGRect, nameUser: UILabel = UILabel(), age: UILabel = UILabel(), progressBar: [UIView] = [UIView]()) {
        
        self.nameUser = nameUser
        self.age = age
        self.progressBar = progressBar
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("Объект imageUserView уничтожен")
    }
}
