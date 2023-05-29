//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatViewController: UIViewController {

    
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var mostViewScrolling: UIView!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var heightMostScrollView: NSLayoutConstraint!
    
    private var userPairs = [User]()
    var selectedUserID = String()
    
    var chatCellArr = [ChatCellView]() {
        didSet {
            let height = CGFloat(chatCellArr.count * 100) + 260
            
            if height > 0 {
                heightMostScrollView.constant = height /// Обновляем константу вертикального ScrollView  в зависимости от количества чатов
            }else {
                heightMostScrollView.constant = 100 + 260
            }
            view.layoutIfNeeded()
        }
    }
    

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
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadUsersPairs()
        createChatViewCell()
        
        mostViewScrolling.addSubview(horizontalScrollView)
        horizontalScrollView.addSubview(contenView)
        contenView.addSubview(horizontalStackView)
        
        createContentHorizontalScrollView()
        setupContentViewContstains()
        horizontalScrollView.contentSize.width = widthHorizontalScrollview
        
        print(horizontalStackView.frame)
    }
}



//MARK: -  Создание ячеек чатов пользователя

extension ChatViewController {
    
    func createChatViewCell()  {
        
        for user in userPairs {
            
            if user.chatArr.count > 0 { /// Если у текущего пользователя был чат с новым пользователем
                
                let chatCell = ChatCellView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100), ID: user.ID)
                
                chatCell.avatar.image = UIImage(named: "KatyaS")
                chatCell.nameLabel.text = "Алиса"
                chatCell.commentLabel.text = user.chatArr.last?.body /// Последнее сообщение от нее
                chatCell.scrollView = verticalScrollView
                chatCell.tapGesture.addTarget(self, action: #selector(handleTap(_:)))
                
                let action = UIAction { [weak self] UIAction in
                    self?.deleteChat(ID: user.ID)
                }
                
                chatCell.deleteView.button.addAction(action, for: .touchUpInside)
                
                chatCellArr.append(chatCell)
                verticalStackView.addArrangedSubview(chatCell)
            }
        }
    }
}

//MARK: -  Настройка Горизонтального ScrollView

extension ChatViewController {
    
    private func setupContentViewContstains(){
        
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: contenView.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: contenView.bottomAnchor),
            horizontalStackView.leftAnchor.constraint(equalTo: contenView.leftAnchor)
        ])
        
        for view in horizontalStackView.arrangedSubviews {
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
                horizontalStackView.addArrangedSubview(potentialChatCell)
            }
        }
        creatEmptyPotentialCell()
    }
    
    func creatEmptyPotentialCell(){
        
        if potenitalChatCellArr.count < 4 {
            for _ in 0...4 - potenitalChatCellArr.count - 1 {
                let cell = PotentialChatCell(frame: CGRect(x: 0, y: 0, width: 105, height: 155), avatar: nil, name: nil,ID: nil)
                potenitalChatCellArr.append(cell)
                horizontalStackView.addArrangedSubview(cell)
            }
        }
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

//MARK: - Переход в контроллер чата с пользователем

extension ChatViewController {
    
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        
        if let currentView = sender.view as? ChatCellView {
            selectedUserID = currentView.ID
            performSegue(withIdentifier: "goToChat", sender: self)
        }
        
        else if let currentView = sender.view as? PotentialChatCell {
            guard let id = currentView.ID else {return}
            selectedUserID = id
            performSegue(withIdentifier: "goToChat", sender: self)
        }else {
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destanationVC = segue.destination as? ChatUserController else  {return}
        destanationVC.userID = selectedUserID
    }
}


//MARK: -  Удаление чата

extension ChatViewController {
    
    func deleteChat(ID:String){
        guard let index = chatCellArr.firstIndex(where: {$0.ID == ID}) else {return}
        chatCellArr[index].removeFromSuperview()
        chatCellArr.remove(at: index)
    }
    
}








