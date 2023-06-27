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
    
    
//MARK: - Создание новой карты
    
    
    func createCard(newUser: User) -> CardView {

        let imageView = CardImageView(name: newUser.name, age: String(newUser.age),countPhoto: newUser.imageArr.count)
        let card = CardView(imageUser: imageView, imageArr: newUser.imageArr, userID: newUser.ID)
        return card
    }
 

//MARK: -  Создание карты оповещения что идет загрузка пользователей
    
    func createLoadingUsersCard() -> CardView {
        
        let imageView = CardImageView(name: "Идет заугрзка новых пар для тебя...", age: "",countPhoto: 0)
        let card = CardView(imageUser: imageView, imageArr: nil, userID: "")
        
        return card
        
    }
    
    
//MARK: - Создаение пустой карты
    
    
    func createEmptyCard() -> CardView {
        
        let imageView = CardImageView(name: "Пары закончились", age: "",countPhoto: 0)
        let card = CardView(imageUser: imageView, imageArr: nil, userID: "")
        
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
        
        
        let layer = currentCard.imageView!.layer /// Создаем ссылку на слой imageUser
        
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
