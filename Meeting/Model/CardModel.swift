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
    
    
    
    
//MARK: - Создание новой карты
    
    
    func createCard(newUser: User) -> CardView {
        
        
        let frame =  CGRect(x: 16, y: 118, width: 361, height: 603)
        
        
        let nameLabel = UILabel() /// Имя
        let point = CGPoint(x: 10, y: 480)
        nameLabel.text = newUser.name
        nameLabel.font = .boldSystemFont(ofSize: 48)
        nameLabel.frame = CGRect(origin: point, size: nameLabel.sizeThatFits(CGSize(width: CGFloat.infinity, height: 48))) /// Расширяем рамку в зависимости от размера текста
        nameLabel.textColor = .white
        
        
        let ageLabel = UILabel(frame: CGRect(x: nameLabel.frame.maxX + 10, y: 485, width: 100, height: 48.0)) /// Возраст, ставим по позиции x относительно имени
        ageLabel.text = String(newUser.age)
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
        
        
        let imageView = imageUserView(frame: CGRect(x: 0, y: 0, width: 361, height: 603),nameUser: nameLabel,age: ageLabel)
        imageView.image = newUser.imageArr[0]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true /// Ограничиваем фото в размерах
    
        
        let gradient = CAGradientLayer() ///  Градиент
        gradient.frame = CGRect(x: 0, y: 400, width: 361, height: 203)
        gradient.locations = [0.0, 1.0]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        imageView.layer.insertSublayer(gradient, at: 0)
        
        
       
        
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,imageUser: imageView,imageArr: newUser.imageArr,superLike: superLike, userID: newUser.iD)
        
        
        
        card.addSubview(imageView)
        imageView.addSubview(nameLabel)
        imageView.addSubview(ageLabel)
        card.addSubview(likeHeart)
        card.addSubview(dislikeHeart)
        card.addSubview(superLike)
        
        let progressBar = createProgressBar(countPhoto: newUser.imageArr.count, image: imageView)
        imageView.progressBar = progressBar
        
        
        
        
        return card
        
        
    }
 
 
    
//MARK: - Создание ProgressBar
    
    func createProgressBar(countPhoto: Int,image: imageUserView) -> [UIView] { /// Создаем кучу одинаковых View
        
        var viewArr = [UIView]()
        let mostWidth = (image.frame.size.width - 5 - CGFloat(countPhoto * 7)) / CGFloat(countPhoto) /// Расчитываем длинну каждой полоски
        
        for i in 0...countPhoto - 1 {
            
            let newView = UIView()
            
            if i == 0 { /// Если первый элемент то задаем начальную позицию
                newView.frame = CGRect(x: 5, y: 10, width: mostWidth, height: 4)
                newView.backgroundColor = .white
            }else {
                let xCoor = viewArr[i-1].frame.maxX /// Узнаем где кончилась предыдущая полоска
                newView.frame = CGRect(x: xCoor + 7, y: 10, width: mostWidth, height: 4) /// Добавляем к ней 7 пунктов и создаем новую
                newView.backgroundColor = .gray
            }
            
            newView.layer.cornerRadius = 2 /// Закругление
            newView.layer.masksToBounds = true /// Обрезание слоев по границам
            newView.alpha = 0.6
            viewArr.append(newView) /// Добавляем в архи полосок
            image.addSubview(newView)
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
        
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,imageUser: nil,imageArr: nil,superLike:superLike, userID: "")
        
        card.addSubview(label)
        
        return card
    }
    
    
    
    
    
    
//MARK: - Создание 3D анимации на последней карты
    
    func createAnimate(indexImage:Int,currentCard: CardView){
        
        
        var firstCornerY = CGFloat()
        var secondCornerY = CGFloat()
        
        if indexImage == 0 { /// Если фото первое то поворачиваем в лево
            firstCornerY = -1 * 0.2
            secondCornerY = 1 * 0.2
        }else {
            firstCornerY = 1 * 0.2
            secondCornerY = -1 * 0.2
        }
        
        
        let layer = currentCard.imageUserView!.layer /// Создаем ссылку на слой imageUser
        
        var rotationAndPerspectiveTransform : CATransform3D = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / -1000
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.15, 0.0,firstCornerY, 0.0) /// Поворачиваем t на угол в радиантах вокруг осей x y z
        layer.transform = rotationAndPerspectiveTransform
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { /// Через некоторое время возвращаем изображение в прежнюю форму

            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.15, 0.0, secondCornerY, 0.0)
            layer.transform = rotationAndPerspectiveTransform
        }

        
        
    }
    
}
