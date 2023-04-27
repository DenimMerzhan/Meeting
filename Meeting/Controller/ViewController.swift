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
    @IBOutlet weak var buttonStackView: UIStackView!
    
    
    var usersArr = [User]()
    var indexUser = 0
    var indexCurrentImage = 0
    var stopCard = false
    
    var center = CGPoint()
    var oddCard: CardView?
    var honestCard: CardView?
    var cardModel = CardModel()
    var users = Users()
    
    var honest = false
    
    var scale = CGFloat(1)
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        usersArr = users.loadUsers()
        
//        buttonStackView.backgroundColor = .clear

        self.oddCard = createCard()
        self.honestCard = createCard()

        oddCard!.addGestureRecognizer(panGesture)
        oddCard!.addGestureRecognizer(tapGesture)
        self.view.addSubview(honestCard!)
        self.view.addSubview(oddCard!)
        self.view.bringSubviewToFront(buttonStackView)
        
        
            

        

    
        
    }
    
    
    
    
//MARK: - Пользователь тапнул по фото
    
    
    @IBAction func cardTap(_ sender: UITapGestureRecognizer) {


        var coordinates = CGFloat()
        var currentImage = UIImageView()
        var imageArr = [UIImage]()

        if sender.view == honestCard {
          
            coordinates = sender.location(in: honestCard!).x
            currentImage = honestCard!.imageUser!
            imageArr = honestCard!.imageArr!
        }else {
           
            coordinates = sender.location(in: oddCard!).x
            currentImage = oddCard!.imageUser!
            imageArr = oddCard!.imageArr!
        }
        

        if coordinates > 220 && indexCurrentImage < imageArr.count - 1 {
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
            let yFromCenter = card.center.y - view.center.y
            
            changeHeart(xFromCenter: xFromCenter, currentCard: card,yFromCenter: yFromCenter)
            
            
            card.center = CGPoint(x: view.center.x + point.x , y: view.center.y + point.y ) /// Перемящем View взависимости от движения пальца
            card.transform = CGAffineTransform(rotationAngle: abs(xFromCenter) * 0.002) /// Поворачиваем View, внутри  rotationAngle радианты а не градусы
   
         
    
            
            
//MARK: -   Когда пользователь отпустил палец
            
            
            if sender.state == UIGestureRecognizer.State.ended { ///  Когда пользователь отпустил палец
                
                if xFromCenter > 150 { /// Если карта ушла за пределы 215 пунктов то лайкаем пользователя
                    
                    UIView.animate(withDuration: 0.2, delay: 0) {
                        card.center = CGPoint(x: card.center.x + 150 , y: card.center.y + 100 )
                        card.alpha = 0
                        self.loadNewPeople(card: card)
                        
                    }
                    
                }else if abs(xFromCenter) > 150 { /// Дизлайк пользователя
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x - 150 , y: card.center.y + 100 )
                        card.alpha = 0
                        self.loadNewPeople(card: card)
                        
                    }
                }else if yFromCenter < -300 {
                    
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x , y: card.center.y - 600 )
                        card.alpha = 0
                        self.loadNewPeople(card: card)
                    }
                }
                
                
                else { /// Если не ушла то возвращаем в центр
                    
                    UIView.animate(withDuration: 0.2, delay: 0) { /// Вызывает анимацию длительностью 0.3 секунды после анимации мы выставляем card view  на первоначальную позицию
                        
                        card.center = self.center
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
                
               
                view.addSubview(honestCard!)
                view.sendSubviewToBack(honestCard!)
                honestCard?.alpha = 1
                
                
            }else {
                
                honestCard!.addGestureRecognizer(panGesture)
                honestCard!.addGestureRecognizer(tapGesture)
                oddCard = createCard()
                
               
                view.addSubview(oddCard!)
                view.sendSubviewToBack(oddCard!)
                oddCard?.alpha = 1
                
                
            }
            
            indexCurrentImage = 0
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                card.removeFromSuperview()
//            }
            
            
        }
        
        else {
            buttonStackView.isHidden = true
        }
    }
    
}
    
    



    
//MARK: - Логика сердец


extension ViewController {
    
    func changeHeart(xFromCenter:CGFloat,currentCard: CardView,yFromCenter:CGFloat){ /// Функция обработки сердец
        
        
        if xFromCenter > 25 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
            currentCard.likHeartImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
            currentCard.likHeartImage.isHidden = false
            currentCard.dislikeHeartImage.isHidden = true
        }else if xFromCenter < -25 { /// Если влево красное
            
            currentCard.dislikeHeartImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter) * 0.005)
            currentCard.dislikeHeartImage.isHidden = false
            currentCard.likHeartImage.isHidden = true
        }else if yFromCenter < 0 {
            currentCard.superLike.alpha = abs(yFromCenter) * 0.005
            currentCard.superLike.isHidden = false
            currentCard.dislikeHeartImage.isHidden = true
            currentCard.likHeartImage.isHidden = true
            
        }
                
        
    }
    
}




//MARK: - Создание нового CardView


extension ViewController {
    
    
    func createDataCard() -> (textName: String?, image: [UIImage]?){
        
        if indexUser < usersArr.count {
            return (usersArr[indexUser].name, usersArr[indexUser].imageArr)
        }else {
            print("Пользователи закончились")
            return (nil,nil)
        }
        
    }
    
    func createCard() -> CardView {
        
        
        if let textName = createDataCard().textName, let image = createDataCard().image {
            
            indexUser += 1
            let card = cardModel.createCard(textName: textName, image: image)
            center = card.center
            
            return card
        }else {
            stopCard = true
            return createEmptyCard()
        }
        
    }
    
    
    func createEmptyCard() -> CardView {
        
        let card = cardModel.createEmptyCard()
        
        return card
    }
    
}
