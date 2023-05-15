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
    var ID = String()
    
    var likImage = UIImageView()
    var dislikeImage = UIImageView()
    var superLikeImage = UIImageView()
    
    init(frame: CGRect, heartLikeImage: UIImageView = UIImageView(), heartDislikeImage: UIImageView = UIImageView(),imageUser: imageUserView?,imageArr: [UIImage]?,superLike: UIImageView,userID: String) {
        
        self.likImage = heartLikeImage
        self.dislikeImage = heartDislikeImage
        self.imageUserView = imageUser
        self.imageArr = imageArr
        self.superLikeImage = superLike
        self.ID = userID
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//MARK: - Обнуление сердец
    
    func resetCard(){
        likImage.isHidden = true
        dislikeImage.isHidden = true
        superLikeImage.isHidden = true
    }

    
//MARK: - Логика сердец когда пользователь перетаскивает карту

    func changeHeart(xFromCenter:CGFloat, yFromCenter:CGFloat){ /// Функция обработки сердец
        
        
        if xFromCenter > 25 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
            
            likImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
            likImage.isHidden = false
            dislikeImage.isHidden = true
            superLikeImage.isHidden = true
            
        }else if xFromCenter < -25 { /// Если влево красное
            
            dislikeImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter) * 0.005)
            dislikeImage.isHidden = false
            likImage.isHidden = true
            superLikeImage.isHidden = true
            
        }else if yFromCenter < 0 {
            
            superLikeImage.alpha = abs(yFromCenter) * 0.005
            superLikeImage.isHidden = false
            dislikeImage.isHidden = true
            likImage.isHidden = true
            
        }
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
