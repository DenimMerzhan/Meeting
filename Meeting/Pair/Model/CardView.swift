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
    var gradient = CAGradientLayer()
    
    private var name = String()
    private var age = String()
    var dataUser = UILabel()
    var progressBar = UIStackView()
    
    var likeImage = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
    var dislikeImage = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
    var superLikeImage = UIImageView(frame: CGRect(x: 117, y: 8, width: 130, height: 100))
    var topAnchorProgressBar = NSLayoutConstraint()
    
    
    init(userID: String = String(), name: String = String(), age: String = String(), imageArr: [UserPhoto]?, emptyCard: Bool = false, frame: CGRect = CGRect(x: 16, y: 118, width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - 236)) {
        
        self.imageArr = imageArr
        self.ID = userID
        self.name = name
        self.age = age
        
        super.init(frame: frame)
        if emptyCard {
            creatEmptyCard()
        }else {
            startSetup()
            setupProgressBar()
        }
    }
    
//MARK: - StartSetup
    
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
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 40), NSAttributedString.Key.foregroundColor : UIColor.white]
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 40), NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedString1 = NSMutableAttributedString(string:name, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string: " " + age, attributes:attrs2)
        attributedString1.append(attributedString2)
        
        dataUser.attributedText = attributedString1
        dataUser.frame = CGRect(x: 10, y: frame.height - 130, width: frame.width - 10, height: 48)
        dataUser.adjustsFontSizeToFitWidth = true
        dataUser.minimumScaleFactor = 0.1
        
        gradient.frame = CGRect(x: 0, y: frame.height - 203, width: frame.width, height: 203)
        gradient.locations = [0.0, 1.0]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        imageView.layer.insertSublayer(gradient, at: 0)
        imageView.addSubview(dataUser)
        imageView.addSubview(progressBar)
        
        self.backgroundColor = .white
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
            progressBar.arrangedSubviews[indexCurrentImage-1].backgroundColor = .gray
            progressBar.arrangedSubviews[indexCurrentImage-1].alpha = 0.6
        }else if  coordinates < 180 && indexCurrentImage > 0  {
            indexCurrentImage -= 1
            progressBar.arrangedSubviews[indexCurrentImage+1].backgroundColor = .gray
            progressBar.arrangedSubviews[indexCurrentImage+1].alpha = 0.6
        }else if indexCurrentImage == 0 || indexCurrentImage == imageArr.count - 1 {
            createAnimate()
        }
        
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(1161)) { /// Cоздаем звук при Тапе
        }
       
        progressBar.arrangedSubviews[indexCurrentImage].backgroundColor = .white
        progressBar.arrangedSubviews[indexCurrentImage].alpha = 1
        imageView.image = imageArr[indexCurrentImage].image
    }
    
}


//MARK: - SetupProgessBar

extension CardView   {
    
    func setupProgressBar() {
        
        guard imageArr != nil else {return}
        
        progressBar.distribution = .fillEqually
        progressBar.spacing = 5
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        topAnchorProgressBar = progressBar.topAnchor.constraint(equalTo: imageView.topAnchor,constant: 8)
        topAnchorProgressBar.isActive = true
        progressBar.leadingAnchor.constraint(equalTo: imageView.leadingAnchor,constant: 5).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: imageView.trailingAnchor,constant: -5).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        
        imageArr?.forEach({ userPhoto in
            
            let progressView = UIView()
            
            progressBar.addArrangedSubview(progressView)
            if userPhoto == imageArr!.first! {
                progressView.backgroundColor = .white
                
            }else {
                progressView.backgroundColor = .gray
                progressView.alpha = 0.6
            }
            progressView.layer.cornerRadius = 2
            progressView.layer.masksToBounds = true
            progressView.layer.borderWidth = 0.5
            progressView.layer.borderColor = UIColor.white.cgColor
        })
        
    }
}

extension CardView: LoadPhoto {
    func userPhotoLoaded() {
        guard let imageArr = self.imageArr else {return}
        imageView.image = imageArr[indexCurrentImage].image
    }
    
}

//MARK: - Animate

extension CardView {
    
    func createAnimate(){
        
        var firstCornerY = CGFloat()
        var secondCornerY = CGFloat()
        
        if indexCurrentImage == 0 { /// Если фото первое то поворачиваем в лево
            firstCornerY = -1 * 0.2
            secondCornerY = 1 * 0.2
        }else {
            firstCornerY = 1 * 0.2
            secondCornerY = -1 * 0.2
        }
        
        
        let layer = imageView.layer /// Создаем ссылку на слой imageUser
        
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






