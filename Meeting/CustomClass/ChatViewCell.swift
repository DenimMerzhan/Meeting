import Foundation
import UIKit

class ChatCellView: UIView {
    
    let ID: String
    
    let chatView = UIView(frame: .zero)
    let avatar = UIImageView(frame: CGRect(x: 10, y: 15, width: 80, height: 80))
    let nameLabel =  UILabel()
    let commentLabel =  UILabel()
    

    var deleteView = changeView(frame: .zero, buttonImage: UIImage(named: "DeleteChatUser")!, text: "УДАЛИТЬ ИЗ ПАР", color: UIColor(named: "DeleteChatColor")!)
    
    var banView = changeView(frame: .zero, buttonImage: UIImage(named: "BanImage")!, text: "Пожаловаться", color: UIColor(named: "BanUserColor")!)
    
    
    var widthChangeView = CGFloat (){
        didSet {
            banView.frame.origin.x = chatView.frame.maxX
            banView.width = widthChangeView / 2
            
            deleteView.frame.origin.x = banView.frame.maxX
            deleteView.width = widthChangeView / 2
        
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
            
            if sender.state == .ended && abs(point.x) > 30 {
                
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.chatView.center.x = self.center.x - 180
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
            
            if point.x > 0 || point.x == 0 {
                
                
                chatView.center.x = chatView.center.x + (point.x / 20)
                loweringCoefficient += 3
                
                if sender.state == .ended {
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.chatView.center.x = self.frame.width / 2
                    self.widthChangeView = self.frame.width - self.chatView.frame.maxX
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
       
        deleteView.frame.size.height = frame.height
        deleteView.setupView()
        banView.frame.size.height = frame.height
        banView.setupView()
        
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(viewDrags(_:)))
        
        avatar.frame.size.height = frame.height - 30
        avatar.frame.size.width = avatar.frame.height
        
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        
        nameLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 25, width: frame.width, height: 30)
        commentLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 60, width: frame.width, height: 20)
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
        self.addSubview(deleteView)
        self.addSubview(banView)
        
    }
    
}



//MARK: -  Разрешаем совместное использование Pangesture и ScrollView

extension ChatCellView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { /// Спрашивает должен ли PanGesture распозновать жесты вместе с другими распознователями
        return true
    }
}




//MARK: -  Класс СhangeView - боковое меню для удаления пары, либо для того что бы на нее пожаловаться

class changeView: UIView {
    
    let button = UIButton()
    let label = UILabel()
    
    var width = CGFloat() {
        didSet {
            
            self.frame.size.width = width
            
            button.center.x = width / 2
            label.center.x = width / 2
            
            button.isHidden = false
            label.isHidden = false
        }
    }

    
    init(frame: CGRect,buttonImage: UIImage,text: String,color:UIColor) {
        
        super.init(frame: frame)
        
        self.label.text = text
        self.button.setImage(buttonImage, for: .normal)
        self.backgroundColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.tintColor = .white
        button.frame = CGRect(x: 0, y: 10, width: Int(frame.height / 2 - 10), height: Int(frame.height / 2 - 10))
    
        
        label.frame = CGRect(x: 0, y: 50, width: 60, height: 0)
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.font = .boldSystemFont(ofSize: 10)
        label.textAlignment = .center
       
        let height = label.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height /// Рассчитываем высоту текста, что бы он влезал ровно по ее краям
        
        label.frame.size.height = height * 2 /// Т.к у нас 2 строки значит высота в 2 раза больше
  
        label.isHidden = true
        button.isHidden = true
        
        self.addSubview(label)
        self.addSubview(button)
        
    }
    
}
