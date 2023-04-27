//
//  CardModel.swift
//  Meeting
//
//  Created by Деним Мержан on 26.04.23.
//

import Foundation
import UIKit


struct CardModel {
    
    
    var usersArr = [User]()
    
    
    func createCard(textName:String,image: [UIImage]) -> CardView {
        
        
        let frame =  CGRect(x: 16, y: 118, width: 361, height: 603)
        
        let label = UILabel(frame: CGRect(x: 10, y: 480, width: 331, height: 48.0))
        label.text = textName
        label.font = .boldSystemFont(ofSize: 48)
        label.textColor = .white
        
        let likeHeart = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
        let dislikeHeart = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
        let superLike = UIImageView(frame: CGRect(x: 117, y: 8, width: 130, height: 100))
        
        likeHeart.image = UIImage(named: "LikeHeart")!
        superLike.image = UIImage(named: "SuperLike")
        dislikeHeart.image = UIImage(named: "DislikeHeart")!
        
        likeHeart.isHidden = true
        dislikeHeart.isHidden = true
        superLike.isHidden = true
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 361, height: 603))
        imageView.image = image[0]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true /// Ограничиваем фото в размерах
    
        
        let gradient = CAGradientLayer() /// Создаем градиент
        gradient.frame = CGRect(x: 0, y: 400, width: 361, height: 203)
        gradient.locations = [0.0, 1.0]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        imageView.layer.insertSublayer(gradient, at: 0)
                    
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,label: label,imageUser: imageView,imageArr: image,superLike: superLike)
        
        card.addSubview(imageView)
        card.addSubview(likeHeart)
        card.addSubview(dislikeHeart)
        card.addSubview(label)
        card.addSubview(superLike)
      
        
        
        
        
        return card
        
        
    }
    
    
    func createEmptyCard() -> CardView {
        
        let frame =  CGRect(x: 16, y: 118, width: 361, height: 603)
        
        let label = UILabel(frame: CGRect(x: 32, y: 170, width: 300, height: 200.0))
        label.text = "Пары закончились :("
        label.font = .boldSystemFont(ofSize: 30)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 4
        
        
        let likeHeart = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
        let dislikeHeart = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
        let superLike = UIImageView(frame: CGRect(x: 117, y: 8, width: 150, height: 100))
        
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,label: label,imageUser: nil,imageArr: nil,superLike:superLike)
        
        card.addSubview(label)
        
        return card
    }
    
}
