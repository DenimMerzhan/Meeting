//
//  ViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit

class ViewController: UIViewController {
    
    
    


    
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var usersArr = [User]()
    var indexUser = 0
    var indexCurrentImage = 0
    
    var currentCard: CardView?
    var nextCard: CardView?
    
    var scale = CGFloat(1)
    override func viewDidLoad() {
        super.viewDidLoad()
    
        usersArr.append(User(name: "Настя",imageArr: [UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!,UIImage(named: "4")!]))
        usersArr.append(User(name: "Света",imageArr: [UIImage(named: "S1")!,UIImage(named: "S2")!,UIImage(named: "S3")!,UIImage(named: "S4")!,UIImage(named: "S5")!]))
        usersArr.append(User(name: "Екатерина",imageArr: [UIImage(named: "K1")!,UIImage(named: "K2")!,UIImage(named: "K3")!]))
        
        if let currentCard = createCard(), let nextCard = createCard() {
            self.currentCard = currentCard
            self.nextCard = nextCard
            
            currentCard.addGestureRecognizer(panGesture)
            currentCard.addGestureRecognizer(tapGesture)
            self.view.addSubview(nextCard)
            self.view.addSubview(currentCard)
        }else {
            print("Пользователи закончелись")
        }
        
        

    
        
    }
    
    
    
    
    
//    @IBAction func cardTap(_ sender: UITapGestureRecognizer) {
//
//
//        var coordinates = CGFloat()
//        var currentImage = UIImageView()
//        let imageArr = usersArr[indexUser - 1].imageArr
//
//        if honest {
//            coordinates = sender.location(in: honestCardView).x
//            currentImage = honestImageView
//        }else {
//            coordinates = sender.location(in: oddCardView).x
//            currentImage = oddImageView
//        }
//
//
//
//        if coordinates > 220 && indexCurrentImage < imageArr.count - 1 {
//            indexCurrentImage += 1
//            currentImage.image = imageArr[indexCurrentImage]
//        }else if  coordinates < 180 && indexCurrentImage > 0  {
//            indexCurrentImage -= 1
//            currentImage.image = imageArr[indexCurrentImage]
//        }
//    }
    
    
    
    
    
    
    
//MARK: -  Карта была нажата пальцем

    @IBAction func cardsDrags(_ sender: UIPanGestureRecognizer) {
        
        
        if let card = sender.view { /// Представление, к которому привязан распознаватель жестов.
            
            let point = sender.translation(in: card) /// Отклонение от начального положения по x и y  в зависимости от того куда перетащил палец пользователь
            
            let xFromCenter = card.center.x - view.center.x
            
            changeHeart(xFromCenter: xFromCenter)
            
            if abs(xFromCenter) > 50 { /// Уменьшаем параметр что бы уменьшить View
                scale = scale - 0.003
            }
            
            card.center = CGPoint(x: view.center.x + point.x , y: view.center.y + point.y ) /// Перемящем View взависимости от движения пальца
            card.transform = CGAffineTransform(rotationAngle: abs(xFromCenter) * 0.002) /// Поворачиваем View, внутри  rotationAngle радианты а не градусы
   
         
    
            
            
//MARK: -   Когда пользователь отпустил палец
            
            
            if sender.state == UIGestureRecognizer.State.ended { ///  Когда пользователь отпустил палец
                
                if xFromCenter > 150 { /// Если карта ушла за пределы 215 пунктов то лайкаем пользователя
                    UIView.animate(withDuration: 0.5, delay: 0) {
                        card.center = CGPoint(x: card.center.x + 200 , y: card.center.y + 200 )
                        card.alpha = 0
                        
                        
                    }
                    
                }else if abs(xFromCenter) > 150 { /// Дизлайк пользователя
                    UIView.animate(withDuration: 0.5, delay: 0) {
                        card.center = CGPoint(x: card.center.x - 200 , y: card.center.y - 200 )
                        card.alpha = 0
                        
                        
                    }
                }else { /// Если не ушла то возвращаем в центр
                    
                    UIView.animate(withDuration: 0.2, delay: 0) { /// Вызывает анимацию длительностью 0.3 секунды после анимации мы выставляем card view  на первоначальную позицию
                        
                        self.scale = 1
                        card.center = self.view.center
                        card.transform = CGAffineTransform(rotationAngle: 0)
                        self.currentCard?.likHeartImage.isHidden = true
                        self.currentCard?.dislikeHeartImage.isHidden = true
                        
//                        if card.frame.origin != self.mostCoordinates{ /// Если каты не иделаьно ложиться друг на друга, кладем их идеально
//                            card.frame.origin = self.mostCoordinates
//                        }
                    }
                }
            }
        }
    }
    
    
}







//MARK: - Загрузка нового пользователя


extension ViewController {
    
//    func loadNewPeople(currentCard: UIView){
//
//        self.indexUser += 1
//        var indexUser = self.indexUser
//
//
//        currentCard.removeGestureRecognizer(panGesture)
//        currentCard.removeGestureRecognizer(tapGesture)
//        view.sendSubviewToBack(currentCard)
//
//        resetHeart()
//
//        if honest {
//            oddCardView.addGestureRecognizer(panGesture)
//            oddCardView.addGestureRecognizer(tapGesture)
//
//        }else {
//            honestCardView.addGestureRecognizer(panGesture)
//            honestCardView.addGestureRecognizer(tapGesture)
//        }
//
//        if indexUser > usersArr.count - 1 {
//            print("Ваши пары закончились(")
//            return
//        }
//
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
//
//            currentCard.center = self.view.center
//            currentCard.transform = CGAffineTransform(rotationAngle: 0)
//
//            if self.honest {
//                self.honestImageView.image = self.usersArr[indexUser].imageArr[0]
//                self.honestNamePeople.text  = self.usersArr[indexUser].name
//            }else {
//                self.oddImageView.image = self.usersArr[indexUser].imageArr[0]
//                self.oddNamePeople.text = self.usersArr[indexUser].name
//            }
//            currentCard.alpha = 1
//
////            if currentCard.frame.origin != self.mostCoordinates{
////                currentCard.frame.origin = self.mostCoordinates
////            }
//            self.indexCurrentImage = 0
//            self.honest = !self.honest
//
//            if indexUser > self.usersArr.count - 1 {
//                currentCard.isHidden = true
//            }
//        }
//
//    }
    
}
    
    



    
//MARK: - Логика сердец


extension ViewController {
    
    func changeHeart(xFromCenter:CGFloat){ /// Функция обработки сердец
        
        if xFromCenter > 0 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
            currentCard!.likHeartImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
            currentCard!.likHeartImage.isHidden = false
            currentCard!.dislikeHeartImage.isHidden = true
        }else if xFromCenter < 0 { /// Если влево красное
            
            currentCard!.dislikeHeartImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter) * 0.005)
            currentCard!.dislikeHeartImage.isHidden = false
            currentCard!.likHeartImage.isHidden = true
        }
                
        
    }
    
}


extension ViewController {
    
    
    func createDataCard() -> (textName: String?, image: [UIImage]?){
        
        if indexUser < usersArr.count - 1 {
            return (usersArr[indexUser].name, usersArr[indexUser].imageArr)
        }else {
            print("Пользователи закончились")
            return (nil,nil)
        }
        
    }
    
    func createCard() -> CardView? {
        
        
        if let textName = createDataCard().textName, let image = createDataCard().image {
            
            indexUser += 1
            
            let frame =  CGRect(x: 16, y: 118, width: 361, height: 603)
            
            let label = UILabel(frame: CGRect(x: 8.0, y: 494, width: 331, height: 48.0))
            label.text = textName
            
            let likeHeart = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
            let dislikeHeart = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
            
            likeHeart.image = UIImage(named: "LikeHeart")!
            dislikeHeart.image = UIImage(named: "DislikeHeart")!
            
            likeHeart.isHidden = true
            dislikeHeart.isHidden = true
            print("yeah")
            

            let imageView = UIImageView(frame: frame)
            imageView.image = image[0]
            
            print(imageView.frame.origin)
            
            let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,label: label)
            
            
            card.backgroundColor = .yellow
            card.addSubview(imageView)
            card.addSubview(likeHeart)
            card.addSubview(dislikeHeart)
            card.addSubview(label)
            
            
            
            
            return card
        }else {
            return nil
        }
        
    }
    
}
