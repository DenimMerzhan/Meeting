//
//  ViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit

class ViewController: UIViewController {
    
    
    


    @IBOutlet weak var honestDislikeImage: UIImageView!
    @IBOutlet weak var honestHeartLikeImage: UIImageView!
    
    @IBOutlet weak var oddImageView: UIImageView!
    @IBOutlet weak var honestImageView: UIImageView!
    
    @IBOutlet weak var oddDislikeImage: UIImageView!
    @IBOutlet weak var oddHeartLikeImage: UIImageView!
    
    @IBOutlet weak var oddCardView: CardView!
    @IBOutlet weak var honestCardView: CardView!
    
    
    @IBOutlet weak var oddNamePeople: UILabel!
    @IBOutlet weak var honestNamePeople: UILabel!
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    var usersArr = [User]()
    var indexUser = 1
    var indexCurrentImage = 0
    
    var honest: Bool = false {
        
        didSet {
            
            if honest {
                
            }else {
              
                
            }
            
        }
    }
    
    var scale = CGFloat(1)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        usersArr.append(User(name: "Настя",imageArr: [UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!,UIImage(named: "4")!]))
        usersArr.append(User(name: "Света",imageArr: [UIImage(named: "S1")!,UIImage(named: "S2")!,UIImage(named: "S3")!,UIImage(named: "S4")!,UIImage(named: "S5")!]))
        usersArr.append(User(name: "Екатерина",imageArr: [UIImage(named: "K1")!,UIImage(named: "K2")!,UIImage(named: "K3")!]))
        
        oddImageView.image = usersArr[0].imageArr[0]
        oddNamePeople.text = usersArr[0].name
        honestImageView.image = usersArr[1].imageArr[0]
        honestNamePeople.text = usersArr[1].name
        
        resetHeart()
        
    }
    
    
    
    
    
    
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
   
         
            
//MARK:-  Когда пользователь отпустил палец
            
            
            if sender.state == UIGestureRecognizer.State.ended { ///  Когда пользователь отпустил палец
                
                if xFromCenter > 190 { /// Если карта ушла за пределы 215 пунктов то лайкаем пользователя
                    UIView.animate(withDuration: 0.3, delay: 0) {
                        card.center = CGPoint(x: card.center.x + 200 , y: card.center.y + 200 )
                        card.alpha = 0
                        self.loadNewPeople(currentCard: card)
                        
                    }
                    
                }else if abs(xFromCenter) > 190 { /// Дизлайк пользователя
                    UIView.animate(withDuration: 0.3, delay: 0) {
                        card.center = CGPoint(x: card.center.x - 200 , y: card.center.y - 200 )
                        card.alpha = 0
                        self.loadNewPeople(currentCard: card)
                        
                    }
                }else { /// Если не ушла то возвращаем в центр
                    
                    UIView.animate(withDuration: 0.2, delay: 0) { /// Вызывает анимацию длительностью 0.3 секунды после анимации мы выставляем card view  на первоначальную позицию
                        
                        self.scale = 1
                        card.center = self.view.center
                        card.transform = CGAffineTransform(rotationAngle: 0)
                        self.resetHeart()
                    }
                }
            }
        }
    }
    
    
}





//MARK: - Загрузка нового пользователя


extension ViewController {
    
    func loadNewPeople(currentCard: UIView){
        
        var indexUser = self.indexUser
        
        currentCard.removeGestureRecognizer(panGesture)
        view.sendSubviewToBack(currentCard)
        
        resetHeart()
        
        if honest {
            oddCardView.addGestureRecognizer(panGesture)
            
        }else {
            honestCardView.addGestureRecognizer(panGesture)
        }
        
        if indexUser + 1 > usersArr.count - 1 {
            print("Ваши пары закончились(")
            currentCard.isHidden = true
            return
        }else{
            indexUser += 1
            self.indexUser += 1
        }

        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            
            currentCard.center = self.view.center
            currentCard.transform = CGAffineTransform(rotationAngle: 0)
            
            if self.honest {
                self.honestImageView.image = self.usersArr[indexUser].imageArr[0]
                self.honestNamePeople.text  = self.usersArr[indexUser].name
            }else {
                self.oddImageView.image = self.usersArr[indexUser].imageArr[0]
                self.oddNamePeople.text = self.usersArr[indexUser].name
            }
            currentCard.alpha = 1
            self.honest = !self.honest
        }
        
    }
    
}
    
    



    
//MARK: - Логика сердец


extension ViewController {
    
    func changeHeart(xFromCenter:CGFloat){ /// Функция обработки сердец
        
        if honest { /// Если четный View
            
            if xFromCenter > 0 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
                honestHeartLikeImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
                honestHeartLikeImage.isHidden = false
                honestDislikeImage.isHidden = true
            }else if xFromCenter < 0 { /// Если влево красное
                honestDislikeImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter)   * 0.005)
                honestDislikeImage.isHidden = false
                honestHeartLikeImage.isHidden = true
            }
        }else {
            if xFromCenter > 0 {
                oddHeartLikeImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
                oddHeartLikeImage.isHidden = false
                oddDislikeImage.isHidden = true
            }else if xFromCenter < 0 { /// Если влево красное
                oddDislikeImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter)   * 0.005)
                oddDislikeImage.isHidden = false
                oddHeartLikeImage.isHidden = true
            }
        }
        
        
    }
    
   func resetHeart(){
       
       honestHeartLikeImage.isHidden = true
       honestDislikeImage.isHidden = true
       oddHeartLikeImage.isHidden = true
       oddDislikeImage.isHidden = true
    }
    
}

