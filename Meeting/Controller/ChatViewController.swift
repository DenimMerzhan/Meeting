//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var mostScrollView: UIView!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var heightMostScrollView: NSLayoutConstraint!
    
    private var userPairs = [User]()
    var chatCellArr = [ChatCellView]()
    
    private var widthHorizontalScrollview: CGFloat {
        get {
            if userPairs.count > 0 {
                return CGFloat((userPairs.count - chatCellArr.count ) * 115) + 35
            }else {
                return 115
            }
        }
    }
    
    private var calculateHeightMostScrollView: CGFloat {
        get {
            if chatCellArr.count > 0 {
                return CGFloat(chatCellArr.count * 110) + horizontalScrollView.frame.height + 50 + 25
            }else {
                return 110
            }
        }
    }
    
    private lazy var horizontalScrollView: UIScrollView =  {
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.frame = CGRect(x: 10, y: 50, width: mostScrollView.frame.width, height: 155)
        scrollView.contentSize = CGSize(width: widthHorizontalScrollview, height: 155)
        return scrollView
    }()
    
    private lazy var contenView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        contentView.frame.size = CGSize(width: widthHorizontalScrollview, height: 155)
        return contentView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadUsersPairs()
        print(widthHorizontalScrollview)
        print(view.frame)
        
        mostScrollView.addSubview(horizontalScrollView)
        print(horizontalScrollView.frame.width)
        
        horizontalScrollView.addSubview(contenView)
        contenView.addSubview(stackView)
        
        createContentHorizontalScrollView()
        setupContentViewContstains()
        
        createChatViewCell()
        heightMostScrollView.constant = calculateHeightMostScrollView
        view.layoutIfNeeded()
    }
    

}





//MARK: -  Создание ячеек чатов пользователя

extension ChatViewController {
    
    func createChatViewCell()  {
        
        var chatCell = ChatCellView(x: 0, y: 0, width: 0)
        
        for user in userPairs {
            
            if user.chatArr.count > 0 { /// Если у текущего пользователя был чат с новым пользователем
                
                if chatCellArr.count > 0 {
                    chatCell = ChatCellView(x: 10, y:chatCellArr.last!.frame.maxY + 10 , width: view.frame.width)
                }else {
                    chatCell = ChatCellView(x: 10, y: horizontalScrollView.frame.maxY + 50, width: view.frame.width)
                }
                
                chatCell.avatar.image = UIImage(named: "KatyaS")
                chatCell.nameLabel.text = "Алиса"
                chatCell.commentLabel.text = user.chatArr.last(where: {$0.sender == user.ID})?.body /// Последнее сообщение от нее
                chatCellArr.append(chatCell)
                mostScrollView.addSubview(chatCell)
            }
        }
    }
}

//MARK: -  Настройка ScrollView

extension ChatViewController {
    
    private func setupContentViewContstains(){
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contenView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contenView.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contenView.leftAnchor)
        ])
        
        for view in stackView.arrangedSubviews {
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 105),
                view.heightAnchor.constraint(equalToConstant: 155)
            ])
        }
        
    }
    
//MARK: -  Создание изображений пар которых пользователей не лайкнул в Горизонтальном ScrollView
    
    private func createContentHorizontalScrollView(){
        
        for user in userPairs { /// Если чата не было
            
            if user.chatArr.count == 0 {
                let viewUser = UIView(frame: CGRect(x: 0, y: 0, width: 105, height: 155))
                let imageUser = UIImageView(frame: CGRect(x: 0, y: 0, width: viewUser.frame.width, height: viewUser.frame.height - 25))
                let label = UILabel(frame: CGRect(x: 0, y: viewUser.frame.maxY - 20, width: viewUser.frame.width, height: 20))
                
                
                imageUser.image = user.avatar
                imageUser.contentMode = .scaleAspectFill
                imageUser.layer.cornerRadius = 10
                imageUser.clipsToBounds = true
                
                label.text = user.name
                label.center.x = 50
                label.textAlignment = .center
                label.font = .boldSystemFont(ofSize: 20)
                label.minimumScaleFactor = 0.5
                label.adjustsFontSizeToFitWidth = true
                label.textColor = .black
                
                viewUser.addSubview(imageUser)
                viewUser.addSubview(label)
                
                stackView.addArrangedSubview(viewUser)
            }
        }
        
    }
    
}

//MARK: - Загрузка аватаров пользователей

extension ChatViewController {
    
    func LoadUsersPairs(){
        
        for i in 0...12 {
            
            var newUser = User(ID: "Катя" + String(Int.random(in: 1000...1000000)))
            
            if Bool.random() {
                newUser.chatArr.append(message(sender: newUser.ID, body: "Привет,все хорошо?"))
            }
            newUser.name = newUser.ID
            newUser.avatar = UIImage(named: "KatyaS")!
            newUser.age = Int.random(in: 18...35)
            
            userPairs.append(newUser)
        }
    }
    
}
