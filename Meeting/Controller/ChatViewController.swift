//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatViewController: UIViewController {

    
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var mostViewScrolling: UIView!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var heightMostScrollView: NSLayoutConstraint!
    
    private var userPairs = [User]()
    var chatCellArr = [ChatCellView]()
    var selectedUserID = String()
    
    var potenitalChatCellArr = [PotentialChatCell](){
        didSet {
            if potenitalChatCellArr.count > 4 { /// Если есть хотя бы 4 фото, то убираем пустые ячейки
                potenitalChatCellArr.removeAll(where: {$0.avatar == nil })
            }
        }
    }
    
    private var widthHorizontalScrollview: CGFloat {
        get {
            if userPairs.count > 0 {
                let width = CGFloat(potenitalChatCellArr.count * 115) + 15
                if width < mostViewScrolling.frame.width {
                    return mostViewScrolling.frame.width + 50
                }else {
                    return width
                }
            }else {
                return 115
            }
        }
    }
    
    private var calculateHeightMostScrollView: CGFloat {
        get {
            if chatCellArr.count > 0 {
                return CGFloat(chatCellArr.count * 110) + horizontalScrollView.frame.height + 50 + 35
            }else {
                return 110
            }
        }
    }
    
    private lazy var horizontalScrollView: UIScrollView =  {
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.frame = CGRect(x: 10, y: 60, width: view.frame.width, height: 155)
        scrollView.contentSize = CGSize(width: widthHorizontalScrollview, height: 155)
        scrollView.showsHorizontalScrollIndicator = false
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
        
        verticalScrollView.showsVerticalScrollIndicator = false
        
        LoadUsersPairs()
        createChatViewCell()
        
        heightMostScrollView.constant = calculateHeightMostScrollView /// Обновляем константу вертикального ScrollView  в зависимости от количества чатов
        view.layoutIfNeeded()
        
        mostViewScrolling.addSubview(horizontalScrollView)
        horizontalScrollView.addSubview(contenView)
        contenView.addSubview(stackView)
        
        createContentHorizontalScrollView()
        setupContentViewContstains()
        horizontalScrollView.contentSize.width = widthHorizontalScrollview
    }
}





//MARK: -  Создание ячеек чатов пользователя

extension ChatViewController {
    
    func createChatViewCell()  {
        
        
        
        for user in userPairs {
            
            var indentY = CGFloat()
            
            if user.chatArr.count > 0 { /// Если у текущего пользователя был чат с новым пользователем
                
                if chatCellArr.count > 0 {
                    indentY = chatCellArr.last!.frame.maxY
                }else {
                    indentY = horizontalScrollView.frame.maxY + 50
                }
                
                let chatCell = ChatCellView(frame: CGRect(x: 10, y: indentY, width: view.frame.width - 10, height: 110), ID: user.ID)
                
                chatCell.avatar.image = UIImage(named: "KatyaS")
                chatCell.nameLabel.text = "Алиса"
                chatCell.commentLabel.text = user.chatArr.last?.body /// Последнее сообщение от нее
                chatCell.scrollView = verticalScrollView
                
                chatCell.tapGesture.addTarget(self, action: #selector(handleTap(_:)))
                
                chatCellArr.append(chatCell)
                mostViewScrolling.addSubview(chatCell)
                
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
    
    
//MARK: -  Создание PotentialChatCell
    
    private func createContentHorizontalScrollView(){
        
        for user in userPairs { /// Если чата не было
            
            if user.chatArr.count == 0 {
                let potentialChatCell = PotentialChatCell(frame: CGRect(x: 0, y: 0, width: 105, height: 155), avatar: user.avatar, name: user.name,ID: user.ID)
                potenitalChatCellArr.append(potentialChatCell)
                stackView.addArrangedSubview(potentialChatCell)
            }
        }
        creatEmptyPotentialCell()
    }
}


//MARK: - Загрузка аватаров пользователей

extension ChatViewController {
    
    func LoadUsersPairs(){
        
        for _ in 0...8 {
            
            var newUser = User(ID: "Катя" + String(Int.random(in: 1000...1000000)))
            
         
                newUser.chatArr.append(message(sender: newUser.ID, body: "Привет,все хорошо?"))
            
            newUser.name = newUser.ID
            newUser.avatar = UIImage(named: "KatyaS")!
            newUser.age = Int.random(in: 18...35)
            
            userPairs.append(newUser)
        }
        
        for _ in 0...2 {
            
            var newUser = User(ID: "Катя" + String(Int.random(in: 1000...1000000)))
        
            newUser.name = newUser.ID
            newUser.avatar = UIImage(named: "KatyaS")!
            newUser.age = Int.random(in: 18...35)
            
            userPairs.append(newUser)
        }

    }
    
}


//MARK: -  Создание пустых ячеек если потенциальных пар меньше чем 4

extension ChatViewController {
    
    func creatEmptyPotentialCell(){
        
        if potenitalChatCellArr.count < 4 {
            for _ in 0...4 - potenitalChatCellArr.count - 1 {
                let cell = PotentialChatCell(frame: CGRect(x: 0, y: 0, width: 105, height: 155), avatar: nil, name: nil,ID: nil)
                potenitalChatCellArr.append(cell)
                stackView.addArrangedSubview(cell)
            }
        }
    }
}


//MARK: - Переход в контроллер чата с пользователем

extension ChatViewController {
    
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        
//        if let currentView = sender.view as? ChatCellView {
//            selectedUserID = currentView.ID
//            performSegue(withIdentifier: "goToChat", sender: self)
//        }else if let currentView = sender.view as? PotentialChatCell {
//            guard let id = currentView.ID else {return}
//            selectedUserID = id
//            performSegue(withIdentifier: "goToChat", sender: self)
//        }else {
//            return
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destanationVC = segue.destination as? ChatUserController else  {return}
        destanationVC.userID = selectedUserID
    }
}











