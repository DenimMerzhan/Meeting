//
//  CardViewClass.swift
//  Meeting
//
//  Created by Деним Мержан on 20.04.23.
//

import Foundation
import UIKit
import AudioToolbox


class CardView: UIView {
    
    var imageView: CardImageView?
    var imageArr: [UserPhoto]?
    var ID = String()
    var nameUser = UILabel()
    var age = UILabel()
    
    
    var likImage = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
    var dislikeImage = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
    var superLikeImage = UIImageView(frame: CGRect(x: 117, y: 8, width: 130, height: 100))
    
    init(imageUser: CardImageView?,imageArr: [UserPhoto]?,userID: String) {
        
        self.imageView = imageUser
        self.imageArr = imageArr
        self.ID = userID
        super.init(frame: CGRect(x: 16, y: 118, width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - 236))
        startSetup()
    }
    
    func startSetup(){
        
        guard let imageArr = self.imageArr else {return}
        guard let imageView = self.imageView else {return}
        for imageView in imageArr {
            imageView.delegate = self
        }
        
        likImage.image = UIImage(named: "LikeHeart")!
        dislikeImage.image = UIImage(named: "SuperLike")
        superLikeImage.image = UIImage(named: "DislikeHeart")!
        likImage.isHidden = true
        dislikeImage.isHidden = true
        superLikeImage.isHidden = true
        
        self.addSubview(imageView)
        self.addSubview(likImage)
        self.addSubview(dislikeImage)
        self.addSubview(superLikeImage)
        
        

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
    
//MARK: - Когда пользователь тапнул по фото обновляет фото и строку прогресса
    
    func refreshPhoto(_ sender: UITapGestureRecognizer,indexCurrentImage: Int) -> Int? {

        let coordinates = sender.location(in: self).x
        guard let imageArr = self.imageArr else {return nil}
        var index = indexCurrentImage
        
        if coordinates > 220 && indexCurrentImage < imageArr.count - 1 {
            index += 1
            self.imageView?.progressBar[index-1].backgroundColor = .gray
        }else if  coordinates < 180 && indexCurrentImage > 0  {
            index -= 1
            self.imageView?.progressBar[index+1].backgroundColor = .gray
        }else if indexCurrentImage == 0 || indexCurrentImage == imageArr.count - 1 {
            self.backgroundColor = .white
            CardModel().createAnimate(indexImage: index, currentCard: self)
           
        }
        
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(1161)) { /// Cоздаем звук при Тапе
        }
        
        self.imageView?.progressBar[index].backgroundColor = .white
        if imageArr[index].image == nil {
            imageView?.startAnimating()
            imageView?.image = UIImage(color: UIColor(named: "GrayColor")!)
        }else {
            imageView?.image = imageArr[index].image
            imageView?.stopAnimating()
        }
        return index
}
    
//    deinit {
//        print("Объект CardView \(ID) уничтожен")
//    }
    
}   

extension CardView: LoadPhoto {
    func userPhotoLoaded() {
        
    }
    
}






