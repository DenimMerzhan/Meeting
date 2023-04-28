//
//  ViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    
    


    
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var preferencesButton: UIButton!
    
    var usersArr = [User]()
    var indexUser = 0
    var indexCurrentImage = 0
    
    var stopCard = false
    var center = CGPoint()
    var oddCard: CardView?
    
    var honestCard: CardView?
    var cardModel = CardModel()
    var currentCard: CardView?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        preferencesButton.titleLabel?.text = ""
        usersArr = Users().loadUsers()

        oddCard = createCard()
        honestCard = createCard()
        currentCard = oddCard

        
        oddCard!.addGestureRecognizer(panGesture)
        oddCard!.addGestureRecognizer(tapGesture)
        self.view.addSubview(honestCard!)
        self.view.addSubview(oddCard!)
        self.view.bringSubviewToFront(buttonStackView)
    
        
    }
    
    
    
    
//MARK: -  Одна из кнопок лайка была нажата
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        var differenceX = CGFloat()
        var differenceY = CGFloat(-150)
        
        if sender.restorationIdentifier == "Cancel" {
            differenceX = -200
        }else if sender.restorationIdentifier == "SuperLike" {
            differenceY = -600
        }else if sender.restorationIdentifier == "Like" {
            differenceX = 200
        }
        
        changeHeart(xFromCenter: differenceX, currentCard: currentCard!, yFromCenter: differenceY)
        UIView.animate(withDuration: 0.4, delay: 0) {
            
            self.currentCard!.center = CGPoint(x: self.currentCard!.center.x + differenceX , y: self.currentCard!.center.y + differenceY )
            self.currentCard!.transform = CGAffineTransform(rotationAngle: abs(differenceX) * 0.002)
            self.currentCard!.alpha = 0
            self.loadNewPeople(card: self.currentCard!)
        }
        
    }
    
    
    
    
//MARK: - Пользователь тапнул по фото
    
    
    @IBAction func cardTap(_ sender: UITapGestureRecognizer) {


        let coordinates = sender.location(in: currentCard!).x
        let currentImage = currentCard!.imageUser!
        let imageArr = currentCard!.imageArr!
        


        if coordinates > 220 && indexCurrentImage < imageArr.count - 1 {
            indexCurrentImage += 1
            currentCard!.progressBar[indexCurrentImage-1].backgroundColor = .gray
        }else if  coordinates < 180 && indexCurrentImage > 0  {
            indexCurrentImage -= 1
            currentCard!.progressBar[indexCurrentImage+1].backgroundColor = .gray
        }else if indexCurrentImage == 0 || indexCurrentImage == imageArr.count - 1 {
            cardModel.createAnimate(indexImage: indexCurrentImage, currentCard: currentCard!)

        }
        
        currentCard!.progressBar[indexCurrentImage].backgroundColor = .white
        currentImage.image = imageArr[indexCurrentImage]
        
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
                }else if yFromCenter < -250 {
                    
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
                        card.superLike.isHidden = true
                        
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
                currentCard = oddCard!
               
                view.addSubview(honestCard!)
                view.sendSubviewToBack(honestCard!)
                honestCard?.alpha = 1
                
                
            }else {
                
                honestCard!.addGestureRecognizer(panGesture)
                honestCard!.addGestureRecognizer(tapGesture)
                oddCard = createCard()
                currentCard = honestCard!
               
                view.addSubview(oddCard!)
                view.sendSubviewToBack(oddCard!)
                oddCard?.alpha = 1
                
                
            }
            
            indexCurrentImage = 0
            
            
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
            currentCard.superLike.isHidden = true
            
        }else if xFromCenter < -25 { /// Если влево красное
            
            currentCard.dislikeHeartImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter) * 0.005)
            currentCard.dislikeHeartImage.isHidden = false
            currentCard.likHeartImage.isHidden = true
            currentCard.superLike.isHidden = true
            
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
    
    
    func createDataCard() -> (textName: String?, image: [UIImage]?,age: Int?){
        
        
        
        if indexUser < usersArr.count {
            let currentUser = usersArr[indexUser]
            return (currentUser.name, currentUser.imageArr,currentUser.age)
        }else {
            print("Пользователи закончились")
            return (nil,nil,nil)
        }
        
    }
    
    func createCard() -> CardView {
        
        let data = createDataCard()
        if let textName = data.textName, let image = data.image,let age = data.age  {
            
            indexUser += 1
            let card = cardModel.createCard(textName: textName, image: image,age:age)
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
