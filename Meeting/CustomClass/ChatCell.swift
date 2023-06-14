//
//  TableViewCell.swift
//  Meeting
//
//  Created by Деним Мержан on 04.06.23.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var chatView: UIView!
    
    
    @IBOutlet weak var countUnreadMessageView: UIView!
    @IBOutlet weak var countUnreadMessageLabel: UILabel!
    
    
    var deleteView = changeView(frame: .zero, buttonImage: UIImage(named: "DeleteChatUser")!, text: "УДАЛИТЬ ИЗ ПАР", color: UIColor(named: "DeleteChatColor")!)
    
    var banView = changeView(frame: .zero, buttonImage: UIImage(named: "BanImage")!, text: "Пожаловаться", color: UIColor(named: "BanUserColor")!)
    
    private var prepareDeleteUser = Bool()
    private var scrollEnd = true
    
    let panGesture = UIPanGestureRecognizer()
    var scrollView = UIScrollView()
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countUnreadMessageView.layer.cornerRadius = countUnreadMessageView.frame.width / 2
        countUnreadMessageView.clipsToBounds = true
        countUnreadMessageView.alpha = 0.6
        
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        commentLabel.textColor = .gray
        
        deleteView.frame.size.height = 100
        deleteView.setupView()
        banView.frame.size.height = 100
        banView.setupView()
        
//        panGesture.delegate = self
//        panGesture.addTarget(self, action: #selector(viewDrags(_:)))
        
//        self.addSubview(deleteView)
//        self.addSubview(banView)
//        chatView.addGestureRecognizer(panGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    override func prepareForReuse() {
        countUnreadMessageView.isHidden = true
    }
    
//    override func layoutSubviews() {
//        cellActionButtonLabel?.numberOfLines = 2
//        cellActionButtonLabel?.font = .systemFont(ofSize: 10)
//        cellActionButtonLabel?.frame = CGRect(x: 0, y: 25, width: 60, height: 100)
//    }
    
//MARK: - ViewDrags
    
    @objc func viewDrags(_ sender: UIPanGestureRecognizer){
        
        let point = sender.translation(in: chatView)
        
        if sender.state == .began { /// Если это первое касание
           
            let startX = sender.location(in: self) /// Позиация первого касания
            
            if startX.x < frame.maxX * 0.75  { /// Если далеко от левого края то завершаем отрабатывать жест
                sender.state = .ended
            }else {
                scrollView.isScrollEnabled = false /// Если пользователь решил удалить чат, то останавливаем прокрутку
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
            scrollView.isScrollEnabled = true
        }
}
    
    
//MARK: - TapGestureDelegate
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { /// Спрашивает должен ли PanGesture распозновать жесты вместе с другими распознователями
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



extension ChatCell {

    /// Returns label of cell action button.
    ///
    /// Use this property to set cell action button label color.
    var cellActionButtonLabel: UILabel? {
        for subview in self.superview?.subviews ?? [] {
            if String(describing: subview).range(of: "UISwipeActionPullView") != nil {
                for view in subview.subviews {
                    if String(describing: view).range(of: "UISwipeActionStandardButton") != nil {
                        for sub in view.subviews {
                            if let label = sub as? UILabel {
                                return label
                            }
                        }
                    }
                }
            }
        }
        return nil
    }

}
