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
    var stopCard = false
    
    
    var oddCard: CardView?
    var honestCard: CardView?
    
    var center = CGPoint()
    var honest = false
    
    var scale = CGFloat(1)
    override func viewDidLoad() {
        super.viewDidLoad()
    
        usersArr.append(User(name: "Настя",imageArr: [UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!,UIImage(named: "4")!]))
        usersArr.append(User(name: "Света",imageArr: [UIImage(named: "S1")!,UIImage(named: "S2")!,UIImage(named: "S3")!,UIImage(named: "S4")!,UIImage(named: "S5")!]))
        usersArr.append(User(name: "Екатерина",imageArr: [UIImage(named: "K1")!,UIImage(named: "K2")!,UIImage(named: "K3")!]))
        

            self.oddCard = createCard()
            self.honestCard = createCard()
            
            oddCard!.addGestureRecognizer(panGesture)
            oddCard!.addGestureRecognizer(tapGesture)
            self.view.addSubview(honestCard!)
            self.view.addSubview(oddCard!)
            

        

    
        
    }
    
    
    
    
    
    @IBAction func cardTap(_ sender: UITapGestureRecognizer) {


        var coordinates = CGFloat()
        var currentImage = UIImageView()
        let imageArr = usersArr[indexUser].imageArr

        if honest {
          
            coordinates = sender.location(in: honestCard!).x
            currentImage = honestCard!.imageUser
        }else {
           
            coordinates = sender.location(in: oddCard!).x
            currentImage = oddCard!.imageUser
        }
        print(coordinates)

        if coordinates > 220 && indexCurrentImage < imageArr.count - 1 {
            print("Yeah")
            indexCurrentImage += 1
            currentImage.image = imageArr[indexCurrentImage]
        }else if  coordinates < 180 && indexCurrentImage > 0  {
            indexCurrentImage -= 1
            currentImage.image = imageArr[indexCurrentImage]
        }
    }
    
    
    
    
    
    
    
//MARK: -  Карта была нажата пальцем

    @IBAction func cardsDrags(_ sender: UIPanGestureRecognizer) {
        
        
        if let card = sender.view  as? CardView { /// Представление, к которому привязан распознаватель жестов.
            
            let point = sender.translation(in: card) /// Отклонение от начального положения по x и y  в зависимости от того куда перетащил палец пользователь
            
            let xFromCenter = card.center.x - view.center.x
            
            changeHeart(xFromCenter: xFromCenter, currentCard: card)
            
            if abs(xFromCenter) > 50 { /// Уменьшаем параметр что бы уменьшить View
                scale = scale - 0.003
            }
            
            card.center = CGPoint(x: view.center.x + point.x , y: view.center.y + point.y ) /// Перемящем View взависимости от движения пальца
            card.transform = CGAffineTransform(rotationAngle: abs(xFromCenter) * 0.002) /// Поворачиваем View, внутри  rotationAngle радианты а не градусы
   
         
    
            
            
//MARK: -   Когда пользователь отпустил палец
            
            
            if sender.state == UIGestureRecognizer.State.ended { ///  Когда пользователь отпустил палец
                
                if xFromCenter > 150 { /// Если карта ушла за пределы 215 пунктов то лайкаем пользователя
                    UIView.animate(withDuration: 0.2, delay: 0) {
                        card.center = CGPoint(x: card.center.x + 150 , y: card.center.y + 150 )
                        card.alpha = 0
                        self.loadNewPeople(card: card)
                        
                    }
                    
                }else if abs(xFromCenter) > 150 { /// Дизлайк пользователя
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x - 150 , y: card.center.y - 150 )
                        card.alpha = 0
                        self.loadNewPeople(card: card)
                        
                    }
                }else { /// Если не ушла то возвращаем в центр
                    
                    UIView.animate(withDuration: 0.2, delay: 0) { /// Вызывает анимацию длительностью 0.3 секунды после анимации мы выставляем card view  на первоначальную позицию
                        
                        card.center = self.center
                        print(card.center)
                        card.transform = CGAffineTransform(rotationAngle: 0)
                        card.likHeartImage.isHidden = true
                        card.dislikeHeartImage.isHidden = true
                        
                    }
                }
            }
        }
    }
    
    
}







//MARK: - Загрузка нового пользователя


extension ViewController {
    
    func loadNewPeople(card:CardView){
        
        if stopCard == false {
            
            card.removeGestureRecognizer(panGesture)
            card.removeGestureRecognizer(tapGesture)
            
            
            
            if card == honestCard {
                
                oddCard!.addGestureRecognizer(panGesture)
                oddCard!.addGestureRecognizer(tapGesture)
                honestCard = createCard()
                
                if honestCard != nil {
                    view.addSubview(honestCard!)
                    view.sendSubviewToBack(honestCard!)
                    honestCard?.alpha = 1
                }
                
            }else {
                
                honestCard!.addGestureRecognizer(panGesture)
                honestCard!.addGestureRecognizer(tapGesture)
                oddCard = createCard()
                
                if oddCard != nil {
                    view.addSubview(oddCard!)
                    view.sendSubviewToBack(oddCard!)
                    oddCard?.alpha = 1
                }
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                card.removeFromSuperview()
            }
            
            indexCurrentImage = 0
            
        }
    }
    
}
    
    



    
//MARK: - Логика сердец


extension ViewController {
    
    func changeHeart(xFromCenter:CGFloat,currentCard: CardView){ /// Функция обработки сердец
        
        
        if xFromCenter > 0 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
            currentCard.likHeartImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
            currentCard.likHeartImage.isHidden = false
            currentCard.dislikeHeartImage.isHidden = true
        }else if xFromCenter < 0 { /// Если влево красное
            
            currentCard.dislikeHeartImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter) * 0.005)
            currentCard.dislikeHeartImage.isHidden = false
            currentCard.likHeartImage.isHidden = true
        }
                
        
    }
    
}


extension ViewController {
    
    
    func createDataCard() -> (textName: String?, image: [UIImage]?){
        
        if indexUser < usersArr.count {
            return (usersArr[indexUser].name, usersArr[indexUser].imageArr)
        }else {
            print("Пользователи закончились")
            stopCard = true
            return (nil,nil)
        }
        
    }
    
    func createCard() -> CardView {
        
        
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
            
            

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 361, height: 603))
            imageView.image = image[0]
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true /// Ограничиваем фото в размерах
        
            
            let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,label: label)
            
            card.backgroundColor = .yellow
            card.addSubview(imageView)
            card.addSubview(likeHeart)
            card.addSubview(dislikeHeart)
            card.addSubview(label)
            center = card.center
            print("Первый центр", card.center)
            
            
            
            
            return card
        }else {
            return createEmptyCard()
        }
        
    }
    
    func createEmptyCard() -> CardView {
        let frame =  CGRect(x: 16, y: 118, width: 361, height: 603)
        
        let label = UILabel(frame: CGRect(x: 8.0, y: 494, width: 331, height: 48.0))
        label.text = "Пары закончились("
        
        let likeHeart = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
        let dislikeHeart = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
       
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,label: label)
        
        card.backgroundColor = .white
        card.addSubview(label)
        
        return card
    }
    
}
