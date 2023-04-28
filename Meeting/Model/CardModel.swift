//
//  CardModel.swift
//  Meeting
//
//  Created by Деним Мержан on 26.04.23.
//

import Foundation
import UIKit
import AudioToolbox



struct CardModel {
    
    
    var usersArr = [User]()
    
    
    func createCard(textName:String,image: [UIImage],age: Int) -> CardView {
        
        
        let frame =  CGRect(x: 16, y: 118, width: 361, height: 603)
        
        
        let nameLabel = UILabel() /// Имя
        let point = CGPoint(x: 10, y: 480)
        nameLabel.text = textName
        nameLabel.font = .boldSystemFont(ofSize: 48)
        nameLabel.frame = CGRect(origin: point, size: nameLabel.sizeThatFits(CGSize(width: CGFloat.infinity, height: 48))) /// Расширяем рамку в зависимости от размера текста
        nameLabel.textColor = .white
        
        
        let ageLabel = UILabel(frame: CGRect(x: nameLabel.frame.maxX + 10, y: 485, width: 100, height: 48.0)) /// Возраст, ставим по позиции x относительно имени
        ageLabel.text = String(age)
        ageLabel.font = .systemFont(ofSize: 48)
        ageLabel.textColor = .white
        
        
        
        let likeHeart = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79)) /// Картинки сердец
        let dislikeHeart = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
        let superLike = UIImageView(frame: CGRect(x: 117, y: 8, width: 130, height: 100))
        
        likeHeart.image = UIImage(named: "LikeHeart")!
        superLike.image = UIImage(named: "SuperLike")
        dislikeHeart.image = UIImage(named: "DislikeHeart")!
        
        likeHeart.isHidden = true
        dislikeHeart.isHidden = true
        superLike.isHidden = true
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 361, height: 603)) /// Фото
        imageView.image = image[0]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true /// Ограничиваем фото в размерах
    
        
        let gradient = CAGradientLayer() ///  Градиент
        gradient.frame = CGRect(x: 0, y: 400, width: 361, height: 203)
        gradient.locations = [0.0, 1.0]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        imageView.layer.insertSublayer(gradient, at: 0)
        
        
       
        
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,nameUser: nameLabel,imageUser: imageView,imageArr: image,superLike: superLike,age: ageLabel)
        
        
        
        card.addSubview(imageView)
        card.addSubview(likeHeart)
        card.addSubview(dislikeHeart)
        card.addSubview(nameLabel)
        card.addSubview(superLike)
        card.addSubview(ageLabel)
        
        let progressBar = createProgressBar(countPhoto: image.count, card: card)
        card.progressBar = progressBar
        
        
        
        
        return card
        
        
    }
 
 
    
//MARK: - Создание ProgressBar
    
    func createProgressBar(countPhoto: Int,card: CardView) -> [UIView] {
        
        var viewArr = [UIView]()
        let mostWidth = (card.frame.size.width - 5 - CGFloat(countPhoto * 7)) / CGFloat(countPhoto) /// Расчитываем длинну каждой полоски
        
        for i in 0...countPhoto - 1 {
            
            let newView = UIView()
            
            if i == 0 {
                newView.frame = CGRect(x: 5, y: 10, width: mostWidth, height: 4)
                newView.backgroundColor = .white
            }else {
                let xCoor = viewArr[i-1].frame.maxX
                newView.frame = CGRect(x: xCoor + 7, y: 10, width: mostWidth, height: 4)
                newView.backgroundColor = .gray
            }
            
            newView.layer.cornerRadius = 2
            newView.layer.masksToBounds = true
            newView.alpha = 0.6
            viewArr.append(newView)
            card.addSubview(newView)
        }
        
        
        return viewArr
    }
    
//MARK: - Создаение пустой карты
    
    
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
        
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,nameUser: label,imageUser: nil,imageArr: nil,superLike:superLike, age: label)
        
        card.addSubview(label)
        
        return card
    }
    
    
//MARK: - Создание анимации на последней карты
    
    func createAnimate(indexImage:Int,currentCard: CardView){
        
        let transformLayer = CATransformLayer()
       
        var perspective = CATransform3DIdentity
        
        if indexImage == 0 {
            perspective.m14 = 1 / 4000
        }else {
            perspective.m14 = -1 / 4000
        }
        
        transformLayer.transform = perspective
        
        transformLayer.addSublayer(currentCard.imageUser!.layer)
        currentCard.layer.addSublayer(transformLayer)
        currentCard.imageUser!.layer.transform = CATransform3DMakeRotation(-0.2, -1, 0.0, 0)
        currentCard.backgroundColor = .white
    
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            perspective.m14 = 0
            transformLayer.transform = perspective
            currentCard.imageUser!.layer.transform = CATransform3DMakeRotation(0.2, 1, 0.0, 0)
            
        }
        
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {
            
        }
        
        
    }
    
}
