import Foundation
import UIKit

class ChatCellView: UIView {
    
    let avatar = UIImageView(frame: CGRect(x: 10, y: 15, width: 80, height: 80))
    let ID: String
    
    var mostCenterX = CGFloat()
    let nameLabel =  UILabel()
    let commentLabel =  UILabel()
    
    private var loweringCoefficient: CGFloat = 1 {
        didSet {
            if loweringCoefficient == 0 {
                loweringCoefficient = 1
            }
        }
    }
    
    private var prepareDeleteUser = Bool()
    private let bottomLine = UIView()
    private var scrollEnd = true
    
    weak var scrollView = UIScrollView()
    
    
    let tapGesture = UITapGestureRecognizer()
    let panGesture = UIPanGestureRecognizer()
    
    init(x: CGFloat,y: CGFloat,width: CGFloat,ID: String) {
        self.ID = ID
        super.init(frame: CGRect(x: x, y: y, width: width, height: 100))
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        scrollView?.delegate = self
        
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(panGesture)
        
        panGesture.delegate = self
        
        panGesture.addTarget(self, action: #selector(viewDrags(_:)))
        
        avatar.frame.size.height = 70
        avatar.frame.size.width = 70
        
        nameLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 25, width: 200, height: 30)
        
        commentLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 60, width: self.frame.width, height: 20)
        
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        
        nameLabel.font = .boldSystemFont(ofSize: 25)
        commentLabel.font = .systemFont(ofSize: 12)
        commentLabel.textColor = .gray
        
        
        bottomLine.frame = CGRect(x: avatar.frame.maxX, y: 99, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = .gray
        bottomLine.layer.cornerRadius = 10
        bottomLine.clipsToBounds = true
        bottomLine.alpha = 0.3
        
        self.backgroundColor = .clear
        
        self.addSubview(avatar)
        self.addSubview(nameLabel)
        self.addSubview(commentLabel)
        self.addSubview(bottomLine)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    
    @objc func viewDrags(_ sender: UIPanGestureRecognizer){
        
        let point = sender.translation(in: self)
        
        if sender.state == .began { /// Если это первое касание
           
            let startX = sender.location(in: self) /// Позиация первого касания
            if startX.x < frame.maxX * 0.75  { /// Если далеко от левого края то завершаем отрабатывать жест
                sender.state = .ended
            }else {
                scrollView?.isScrollEnabled = false /// Если пользователь решил удалить чат, то останавливаем прокрутку
            }
        }
        
        
        if point.x < 0 && prepareDeleteUser == false {
            
            self.center.x = self.center.x + (point.x / loweringCoefficient)
            loweringCoefficient += 3
            
            if sender.state == .ended && abs(point.x) > 20 {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.center.x = self.mostCenterX - 70
                    self.prepareDeleteUser = true
                    self.loweringCoefficient = 0
                }
            }else if sender.state == .ended {
                self.center.x = self.mostCenterX
                self.loweringCoefficient = 0
            }
            
        }else if prepareDeleteUser {
            
            if point.x > 0 {
                
                
                self.center.x = self.center.x + (point.x / 20)
                loweringCoefficient += 3
                
                if sender.state == .ended {
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.center.x = self.mostCenterX
                    self.prepareDeleteUser = false
                    self.loweringCoefficient = 1
                }
                    
                    
            }
        }
    }
        
        if sender.state == .ended { /// Каждый раз когда действие закончилось включаем прокрутку
            scrollView?.isScrollEnabled = true
        }
}
    
}



//MARK: -  Разрешаем совместное использование Pangesture и ScrollView

extension ChatCellView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { /// Спрашивает должен ли PanGesture распозновать жесты вместе с другими распознователями
        return true
    }
}

//MARK: -  Отслеживание началось ли прокрутка ScrollView

extension ChatCellView: UIScrollViewDelegate {

//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        scrollEnd = false
//        print("False")
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        scrollEnd = true
//        print("True")
//    }


}
