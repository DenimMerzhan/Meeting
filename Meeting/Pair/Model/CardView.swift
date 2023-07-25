//
//  CardViewClass.swift
//  Meeting
//
//  Created by Деним Мержан on 20.04.23.
//

import Foundation
import UIKit
import AudioToolbox
import CoreLocation


protocol CardViewDelegate {
    
    func swipeEndend(card:CardView)
}

class CardView: UIView {
    
    var imageView =  DefaultLoadPhoto(frame: .zero)
    var imageArr: [UserPhoto]?
    var userID = String()
    var gradient = CAGradientLayer()
    var delegate: CardViewDelegate?
    var distanceToUser: UIView?
    
    private var startCenterCard = CGPoint()
    private var name = String()
    private var age = String()
    
    var dataUser = UILabel()
    var progressBar = UIStackView()
    var indexCurrentImage = 0 {
        didSet {
            
        }
    }
    
    lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(cardsDrags(_:)))
    lazy var likeImage: UIImageView = {
        let like = UIImageView(frame: CGRect(x: 25, y: 20.0, width: 150, height: 90))
        like.image = UIImage(named: "LikeImage")?.withRenderingMode(.alwaysOriginal)
        like.contentMode = .scaleAspectFill
        like.isHidden = true
        return like
    }()
    lazy var nopeImage: UIImageView = {
        let nope = UIImageView(frame: CGRect(x: frame.width - 175, y: 20.0, width: 150, height: 90))
        nope.image = UIImage(named: "Nope")?.withRenderingMode(.alwaysOriginal)
        nope.contentMode = .scaleAspectFill
        nope.isHidden = true
        return nope
    }()
    lazy var superLikeImage: UIImageView = {
        let superLike = UIImageView(frame: CGRect(x: 0, y: frame.height - 300, width: 180, height:120))
        superLike.center.x = self.center.x
        superLike.image = UIImage(named: "SuperLike")?.withRenderingMode(.alwaysOriginal)
        superLike.contentMode = .scaleAspectFill
        superLike.isHidden = true
        return superLike
    }()
    
    var topAnchorProgressBar = NSLayoutConstraint()
    
    
    init(user: User?,frame: CGRect = CGRect(x: 16, y: 118, width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - 236)) {
        
        super.init(frame: frame)
        
        if let newUser = user {
            self.startCenterCard = self.center
            self.userID = newUser.ID
            self.name = newUser.name
            self.age = String(newUser.age)
            self.imageArr = newUser.imageArr
            
            startSetup()
            setupProgressBar()
            
            if let lastGeoCurrent = CurrentAuthUser.shared.lastGeopostition, let lastGeoNewUser = newUser.lastGeopostition {
                setupDistanceToUser(lastGeoCurrent: lastGeoCurrent, lastGeoNewUser:lastGeoNewUser)
            }
            
        }else {
            creatEmptyCard()
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
       
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 40), NSAttributedString.Key.foregroundColor : UIColor.white]
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 40), NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedString1 = NSMutableAttributedString(string:name, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string: " " + age, attributes:attrs2)
        attributedString1.append(attributedString2)
        dataUser.attributedText = attributedString1
        dataUser.adjustsFontSizeToFitWidth = true
        dataUser.minimumScaleFactor = 0.1
        dataUser.frame = CGRect(x: 10, y: frame.height - 130, width: frame.width - 100, height: 50)
        imageView.addSubview(dataUser)
        
        gradient.frame = CGRect(x: 0, y: frame.height - 203, width: frame.width, height: 203)
        gradient.locations = [0.0, 1.0]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        imageView.layer.insertSublayer(gradient, at: 0)
        imageView.addSubview(dataUser)
        imageView.addSubview(progressBar)
        
        self.addSubview(imageView)
        self.addSubview(likeImage)
        self.addSubview(nopeImage)
        self.addSubview(superLikeImage)
        self.addGestureRecognizer(panGesture)
        
        
        
        
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
        nopeImage.isHidden = true
        superLikeImage.isHidden = true
    }
    
    
    //MARK: - Логика сердец когда пользователь перетаскивает карту
    
    func changeHeart(xFromCenter:CGFloat, yFromCenter:CGFloat){ /// Функция обработки сердец
        
        if xFromCenter > 25 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
            
            likeImage.alpha = xFromCenter * 0.01
            likeImage.isHidden = false
            nopeImage.isHidden = true
            superLikeImage.isHidden = true
            
        }else if xFromCenter < -25 { /// Если влево красное
            
            nopeImage.alpha = abs(xFromCenter) * 0.01
            nopeImage.isHidden = false
            likeImage.isHidden = true
            superLikeImage.isHidden = true
            
        }else if yFromCenter < 0 {
            
            superLikeImage.alpha = abs(yFromCenter) * 0.005
            superLikeImage.isHidden = false
            nopeImage.isHidden = true
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


//MARK: -  Когда пользователь начал перетаскивать карту

extension CardView {
    
    @objc func cardsDrags(_ sender: UIPanGestureRecognizer) {
        
        let point = sender.translation(in: self) /// Отклонение от начального положения по x и y  в зависимости от того куда перетащил палец пользователь
        let xFromCenter = self.center.x - startCenterCard.x
        let yFromCenter = self.center.y - startCenterCard.y
        changeHeart(xFromCenter: xFromCenter, yFromCenter: yFromCenter)
        self.center = CGPoint(x: startCenterCard.x + point.x , y: startCenterCard.y + point.y ) /// Перемящем View взависимости от движения пальца
        self.transform = CGAffineTransform(rotationAngle: abs(xFromCenter) * 0.002) /// Поворачиваем View, внутри  rotationAngle радианты а не градусы
        
        if sender.state == UIGestureRecognizer.State.ended { ///  Когда пользователь отпустил палец
            handleEnded(xFromCenter: xFromCenter,yFromCenter: yFromCenter)
        }
    }
    
    func handleEnded(xFromCenter: CGFloat,yFromCenter:CGFloat){
        
        let card = self
        
        if xFromCenter > 120 { /// Если карта ушла за пределы 215 пунктов то лайкаем пользователя
            
            UIView.animate(withDuration: 0.32, delay: 0) {
                card.center = CGPoint(x: card.center.x + 150 , y: card.center.y + 100 )
                card.alpha = 0
            }
            CurrentAuthUser.shared.likeArr.append(card.userID)
            delegate?.swipeEndend(card: self)
            
        }else if abs(xFromCenter) > 120 { /// Дизлайк пользователя
            UIView.animate(withDuration: 0.32, delay: 0) {
                card.center = CGPoint(x: card.center.x - 150 , y: card.center.y + 100 )
                card.alpha = 0
            }
            CurrentAuthUser.shared.disLikeArr.append(card.userID)
            delegate?.swipeEndend(card: self)
            
        }else if yFromCenter < -250 { /// Супер Лайк
            
            UIView.animate(withDuration: 0.32, delay: 0) {
                card.center = CGPoint(x: card.center.x , y: card.center.y - 600 )
                card.alpha = 0
            }
            CurrentAuthUser.shared.superLikeArr.append(card.userID)
            delegate?.swipeEndend(card: self)
        }
        
        else { /// Если не ушла то возвращаем в центр
            
            UIView.animate(withDuration: 0.2, delay: 0) { /// Вызывает анимацию длительностью 0.3 секунды после анимации мы выставляем card view  на первоначальную позицию
                card.center = card.startCenterCard
                card.transform = CGAffineTransform(rotationAngle: 0)
                card.resetCard()
            }
        }
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
        
            progressView.backgroundColor = .gray
            progressView.alpha = 0.6
            progressView.layer.cornerRadius = 2
            progressView.layer.masksToBounds = true
            progressView.layer.borderWidth = 0.5
            progressView.layer.borderColor = UIColor.white.cgColor
            progressBar.addArrangedSubview(progressView)
        })
        progressBar.arrangedSubviews.first?.backgroundColor = .white
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
        
        self.backgroundColor = .white
        
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
            self.backgroundColor = .clear
        }
    }
    
}


//MARK: -  SetuoDistanceView

extension CardView {
    
    func setupDistanceToUser(lastGeoCurrent:CLLocation,lastGeoNewUser:CLLocation){
        
        let distance = CGFloat(lastGeoCurrent.distance(from: lastGeoNewUser) / 1000 )
        distanceToUser = UIView(frame: CGRect(x: 10, y: frame.height - 120, width: frame.width - 20, height: 40))
        imageView.addSubview(distanceToUser!)
        
        let label = UILabel(frame: CGRect(x: 25, y: 0, width: distanceToUser!.frame.width - 20, height: distanceToUser!.frame.height))
        label.textColor = .white
        label.text = String(format: "%0.f" , distance ) + " км от тебя"
        if distance < 1 {label.text = "< 1 км от тебя"}
        
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        image.center.y = label.center.y
        image.image = UIImage(named: "DistanceToUser")?.withTintColor(.white)
        
        dataUser.translatesAutoresizingMaskIntoConstraints = false
        dataUser.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -100).isActive = true
        dataUser.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10).isActive = true
        dataUser.bottomAnchor.constraint(equalTo: distanceToUser!.topAnchor).isActive = true
        
        distanceToUser?.addSubview(label)
        distanceToUser?.addSubview(image)
    }
    
}

