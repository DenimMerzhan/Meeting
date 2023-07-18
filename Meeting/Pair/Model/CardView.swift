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
    
    var imageView =  DefaultLoadPhoto(frame: .zero)
    var imageArr: [UserPhoto]?
    var ID = String()
    var indexCurrentImage = 0
    
    var name = UILabel()
    var age = UILabel()
    var progressBar = [UIView]()
    
    var likeImage = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
    var dislikeImage = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
    var superLikeImage = UIImageView(frame: CGRect(x: 117, y: 8, width: 130, height: 100))
    
    init(userID: String = String(), name: String = String(), age: String = String(), imageArr: [UserPhoto]?, emptyCard: Bool = false, frame: CGRect = CGRect(x: 16, y: 118, width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - 236)) {
        
        self.imageArr = imageArr
        self.ID = userID
        self.name.text = name
        self.age.text = age
        super.init(frame: frame)
        if emptyCard {
            creatEmptyCard()
        }else {
            startSetup()
            createProgressBar()
        }
    }
    
    func startSetup(){
        
        guard let imageArr = self.imageArr else {return}
        imageView = DefaultLoadPhoto(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        for imageView in imageArr {
            imageView.delegate = self
        }
        imageView.image = imageArr.first?.image
    
        likeImage.image = UIImage(named: "LikeButton")!
        dislikeImage.image = UIImage(named: "DislikeHeart")
        superLikeImage.image = UIImage(named: "SuperLikeButton")!
        likeImage.isHidden = true
        dislikeImage.isHidden = true
        superLikeImage.isHidden = true
        
        name.font = .boldSystemFont(ofSize: 40)
        name.frame = CGRect(origin: CGPoint(x: 10, y: frame.height - 130), size: name.sizeThatFits(CGSize(width: CGFloat.infinity, height: 48))) /// Расширяем рамку в зависимости от размера текста
        name.textColor = .white
        
        age.frame = CGRect(x: name.frame.maxX + 10, y: frame.height - 130, width: 100, height: 48.0) /// Возраст, ставим по позиции x относительно имени
        age.font = .systemFont(ofSize: 40)
        age.textColor = .white
        
        let gradient = CAGradientLayer() ///  Градиент
        gradient.frame = CGRect(x: 0, y: frame.height - 203, width: frame.width, height: 203)
        gradient.locations = [0.0, 1.0]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        imageView.layer.insertSublayer(gradient, at: 0)
    
        imageView.addSubview(self.name)
        imageView.addSubview(self.age)
        self.addSubview(imageView)
        self.addSubview(likeImage)
        self.addSubview(dislikeImage)
        self.addSubview(superLikeImage)
        
    }
    
    private func creatEmptyCard(){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        label.text = "Пары закончились :("
        label.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    //MARK: - Обнуление сердец
    
    func resetCard(){
        likeImage.isHidden = true
        dislikeImage.isHidden = true
        superLikeImage.isHidden = true
    }
    
    
    //MARK: - Логика сердец когда пользователь перетаскивает карту
    
    func changeHeart(xFromCenter:CGFloat, yFromCenter:CGFloat){ /// Функция обработки сердец
        
        
        if xFromCenter > 25 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
            
            likeImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
            likeImage.isHidden = false
            dislikeImage.isHidden = true
            superLikeImage.isHidden = true
            
        }else if xFromCenter < -25 { /// Если влево красное
            
            dislikeImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter) * 0.005)
            dislikeImage.isHidden = false
            likeImage.isHidden = true
            superLikeImage.isHidden = true
            
        }else if yFromCenter < 0 {
            
            superLikeImage.alpha = abs(yFromCenter) * 0.005
            superLikeImage.isHidden = false
            dislikeImage.isHidden = true
            likeImage.isHidden = true
            
        }
    }
    
//MARK: - Когда пользователь тапнул по фото обновляет фото и строку прогресса
    
    func refreshPhoto(_ sender: UITapGestureRecognizer){
        
        let coordinates = sender.location(in: self).x
        guard let imageArr = self.imageArr else {return}
        
        if coordinates > 220 && indexCurrentImage < imageArr.count - 1 {
            indexCurrentImage += 1
            self.progressBar[indexCurrentImage-1].backgroundColor = .gray
        }else if  coordinates < 180 && indexCurrentImage > 0  {
            indexCurrentImage -= 1
            self.progressBar[indexCurrentImage+1].backgroundColor = .gray
        }else if indexCurrentImage == 0 || indexCurrentImage == imageArr.count - 1 {
            self.backgroundColor = .white
            CardModel().createAnimate(indexImage: indexCurrentImage, currentCard: self)
            
        }
        
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(1161)) { /// Cоздаем звук при Тапе
        }
        
        self.progressBar[indexCurrentImage].backgroundColor = .white
        imageView.image = imageArr[indexCurrentImage].image
    }
    
}   

extension CardView   {
    
    func createProgressBar() { /// Создаем кучу одинаковых View
        
        guard let countPhoto = imageArr?.count else {return}
        
        let mostWidth = (self.frame.size.width - 5 - CGFloat(countPhoto * 7)) / CGFloat(countPhoto) /// Расчитываем длинну каждой полоски
        
        for i in 0...countPhoto - 1 {
            
            let newView = UIView()
            
            if i == 0 { /// Если первый элемент то задаем начальную позицию
                newView.frame = CGRect(x: 5, y: 10, width: mostWidth, height: 4)
                newView.backgroundColor = .white
            }else {
                let xCoor = progressBar[i-1].frame.maxX /// Узнаем где кончилась предыдущая полоска
                newView.frame = CGRect(x: xCoor + 7, y: 10, width: mostWidth, height: 4) /// Добавляем к ней 7 пунктов и создаем новую
                newView.backgroundColor = .gray
            }
            
            newView.layer.cornerRadius = 2 /// Закругление
            newView.layer.masksToBounds = true /// Обрезание слоев по границам
            newView.alpha = 0.6
            progressBar.append(newView) /// Добавляем в архив полосок
            imageView.addSubview(newView)
        }
    }
}

extension CardView: LoadPhoto {
    func userPhotoLoaded() {
        guard let imageArr = self.imageArr else {return}
        imageView.image = imageArr[indexCurrentImage].image
    }
    
}






