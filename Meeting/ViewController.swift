//
//  ViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit

class ViewController: UIViewController {
    
    
    


    
    @IBOutlet weak var oddImageView: UIImageView!
    @IBOutlet weak var honestImageView: UIImageView!
    
    @IBOutlet weak var oddDislikeImage: UIImageView!
    @IBOutlet weak var oddHeartImage: UIImageView!
    
    @IBOutlet weak var oddCardView: CardView!
    @IBOutlet weak var honestCardView: CardView!
    
    
    @IBOutlet weak var oddNamePeople: UILabel!
    @IBOutlet weak var honestNamePeople: UILabel!
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    
    let nameArr = ["Настя","Лиза","Женя","Света","Хуй моржовый"]
    let colorArr = [UIColor.red,UIColor.blue,UIColor.orange,UIColor.green,UIColor.yellow]
    var i = 0
    
    var scale = CGFloat(1)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oddView.imageUser =
        likeHeartImage.isHidden = true
        dislikeHeartImage.isHidden = true
    }
    
    
    
    
    
    
//MARK: -  Карта была нажата пальцем

    @IBAction func cardsDrags(_ sender: UIPanGestureRecognizer) {
        
        
        if let card = sender.view { /// Представление, к которому привязан распознаватель жестов.
            
            let point = sender.translation(in: card) /// Отклонение от начального положения по x и y  в зависимости от того куда перетащил палец пользователь
            
            let xFromCenter = card.center.x - view.center.x
            print("X - ", xFromCenter)
            
            if xFromCenter > 0 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
                likeHeartImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
                likeHeartImage.isHidden = false
                dislikeHeartImage.isHidden = true
            }else if xFromCenter < 0 { /// Если влево красное
                dislikeHeartImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter)   * 0.005)
                likeHeartImage.isHidden = true
                dislikeHeartImage.isHidden = false
            }
            
            if abs(xFromCenter) > 50 { /// Уменьшаем параметр что бы уменьшить View
                scale = scale - 0.003
            }
            
            card.center = CGPoint(x: view.center.x + point.x , y: view.center.y + point.y ) /// Перемящем View взависимости от движения пальца
            card.transform = CGAffineTransform(rotationAngle: abs(xFromCenter) * 0.002).scaledBy(x: scale, y: scale) /// Поворачиваем View, внутри  rotationAngle радианты а не градусы
   
         
            
//MARK:-  Когда пользователь отпустил палец
            
            
            if sender.state == UIGestureRecognizer.State.ended { ///  Когда пользователь отпустил палец
                
                if xFromCenter > 215 { /// Если карта ушла за пределы 215 пунктов то лайкаем пользователя
                    UIView.animate(withDuration: 0.3, delay: 0) {
                        card.center = CGPoint(x: card.center.x + 200 , y: card.center.y + 200 )
                        card.alpha = 0
                        self.loadNewPeople(currentCard: card)
                        
                    }
                    
                }else if abs(xFromCenter) > 215 { /// Дизлайк пользователя
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
                        self.likeHeartImage.isHidden = true
                        self.dislikeHeartImage.isHidden = true
                    }
                }
            }
        }
    }
    
    
}






extension ViewController {
    
    func loadNewPeople(currentCard: UIView){
        
        likeHeartImage.isHidden = true /// Обнуляем сердца
        dislikeHeartImage.isHidden = true
        
        currentCard.removeGestureRecognizer(self.panGesture) /// Удаляем из текущего View распознователь жестов
        twoCardView.addGestureRecognizer(self.panGesture)
        
        if i < nameArr.count {
            namePeople.text = nameArr[i]
            cardView.backgroundColor = colorArr[i]
            i += 1
        }
    }
    
}

