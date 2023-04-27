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
    var nameUser = UILabel()
    var likHeartImage = UIImageView()
    var dislikeHeartImage = UIImageView()
    var label = UILabel()
    var superLike = UIImageView()
    var age = UILabel()
    var progressBar = [UIView]()
    
    init(frame: CGRect, heartLikeImage: UIImageView = UIImageView(), heartDislikeImage: UIImageView = UIImageView(),label: UILabel,imageUser: UIImageView?,imageArr: [UIImage]?,superLike: UIImageView,age:UILabel) {
        
        self.likHeartImage = heartLikeImage
        self.dislikeHeartImage = heartDislikeImage
        self.label = label
        self.imageUser = imageUser
        self.imageArr = imageArr
        self.superLike = superLike
        self.age = age
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
