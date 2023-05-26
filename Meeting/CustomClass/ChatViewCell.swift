import Foundation
import UIKit

class ChatCellView: UIView {
    
    let ID: String
    
    let chatView = UIView(frame: .zero)
    let avatar = UIImageView(frame: CGRect(x: 10, y: 20, width: 80, height: 80))
    let nameLabel =  UILabel()
    let commentLabel =  UILabel()
    

    var changeView = UIView()
    
    var widthChangeView = CGFloat (){
        didSet {
            changeView.frame.origin.x = chatView.frame.maxX
            changeView.frame.size.width = widthChangeView
        }
    }
    
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
    
    init(frame:CGRect, ID: String) {
        self.ID = ID
        super.init(frame:frame)
        setupView(viewFrame: frame)
    }

    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    
    @objc func viewDrags(_ sender: UIPanGestureRecognizer){
        
        let point = sender.translation(in: chatView)
        
        if sender.state == .began { /// Если это первое касание
           
            let startX = sender.location(in: chatView) /// Позиация первого касания
            if startX.x < frame.maxX * 0.75  { /// Если далеко от левого края то завершаем отрабатывать жест
                sender.state = .ended
            }else {
                scrollView?.isScrollEnabled = false /// Если пользователь решил удалить чат, то останавливаем прокрутку
            }
        }
        
        
        if point.x < 0 && prepareDeleteUser == false {
            
            chatView.center.x = chatView.center.x + (point.x / loweringCoefficient)
            loweringCoefficient += 3
            
            if sender.state == .ended && abs(point.x) > 20 {
                
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.chatView.center.x = self.center.x - 70
                    self.widthChangeView = self.frame.width - self.chatView.frame.maxX
                    print(self.widthChangeView)
                    self.prepareDeleteUser = true
                    self.loweringCoefficient = 0
                }
            }
            
            else if sender.state == .ended {
                self.chatView.center.x = frame.width / 2
                self.loweringCoefficient = 0
            }
            
        }else if prepareDeleteUser {
            
            if point.x > 0 {
                
                
                chatView.center.x = chatView.center.x + (point.x / 20)
                loweringCoefficient += 3
                
                if sender.state == .ended {
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.chatView.center.x = self.frame.width / 2
                    self.prepareDeleteUser = false
                    self.loweringCoefficient = 1
                }
                    
                    
            }
        }
    }
        widthChangeView = frame.width - chatView.frame.maxX
        
        if sender.state == .ended { /// Каждый раз когда действие закончилось включаем прокрутку
            scrollView?.isScrollEnabled = true
        }
}
    
}



//MARK: -  Стартовая настройка при загрузке View

extension ChatCellView {
    
    private func setupView(viewFrame:CGRect){
       
        chatView.frame.size.width = frame.width
        chatView.frame.size.height = frame.height
       
        changeView = createChangeView()

        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(viewDrags(_:)))
        
        avatar.frame.size.height = 70
        avatar.frame.size.width = 70
        
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        
        nameLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 30, width: frame.width, height: 30)
        commentLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 65, width: frame.width, height: 20)
        nameLabel.font = .boldSystemFont(ofSize: 25)
        commentLabel.font = .systemFont(ofSize: 12)
        commentLabel.textColor = .gray
        
        
        bottomLine.frame = CGRect(x: avatar.frame.maxX, y: frame.height - 1, width: frame.width, height: 1)
        bottomLine.backgroundColor = .gray
        bottomLine.layer.cornerRadius = 10
        bottomLine.clipsToBounds = true
        bottomLine.alpha = 0.3
        
        
        chatView.addSubview(avatar)
        chatView.addSubview(nameLabel)
        chatView.addSubview(commentLabel)
        chatView.addGestureRecognizer(panGesture)
        chatView.addGestureRecognizer(tapGesture)
        chatView.addSubview(bottomLine)
        
        self.addSubview(chatView)
        self.addSubview(changeView)
        
    }
    
}







//MARK: -  Разрешаем совместное использование Pangesture и ScrollView

extension ChatCellView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { /// Спрашивает должен ли PanGesture распозновать жесты вместе с другими распознователями
        return true
    }
}




//MARK: - Создание кнопок удаления и пожаловаться

extension ChatCellView {
    
    private func createChangeView() -> UIView {
        
        let view = UIView(frame: CGRect(x: chatView.frame.maxX, y: 0, width: 0, height: frame.height))
        view.backgroundColor = .red
        
        return view
    }
    
}
