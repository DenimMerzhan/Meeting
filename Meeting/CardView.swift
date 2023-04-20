//
//  CardViewClass.swift
//  Meeting
//
//  Created by Деним Мержан on 20.04.23.
//

import Foundation
import UIKit

class CardView: UIView {
    
    var imageUser = UIImageView()
    var nameUser = UILabel()
    var likHeartImage = UIImageView()
    var dislikeHeartImage = UIImageView()
    var label = UILabel()
    
    init(frame: CGRect, heartLikeImage: UIImageView = UIImageView(), heartDislikeImage: UIImageView = UIImageView(),label: UILabel) {
        
        self.likHeartImage = heartLikeImage
        self.dislikeHeartImage = heartDislikeImage
        self.label = label
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
