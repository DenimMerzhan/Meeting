//
//  CardViewClass.swift
//  Meeting
//
//  Created by Деним Мержан on 20.04.23.
//

import Foundation
import UIKit


class CardView: UIView {
    
    var imageUser: UIImageView?
    var imageArr: [UIImage]?
    
    var likHeartImage = UIImageView()
    var dislikeHeartImage = UIImageView()
    var superLike = UIImageView()
    
    init(frame: CGRect, heartLikeImage: UIImageView = UIImageView(), heartDislikeImage: UIImageView = UIImageView(),imageUser: imageUserView?,imageArr: [UIImage]?,superLike: UIImageView) {
        
        self.likHeartImage = heartLikeImage
        self.dislikeHeartImage = heartDislikeImage
        self.imageUser = imageUser
        self.imageArr = imageArr
        self.superLike = superLike
        
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
