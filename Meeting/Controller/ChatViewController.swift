//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatViewController: UIViewController {

    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var mostViewScrolling: UIView!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var heightMostScrollView: NSLayoutConstraint!
    
    
    var selectedUser: User?
    var currentAuthUser: CurrentAuthUser?

    var potenitalChatCellArr = [PotentialChatCell](){
        didSet {
            if potenitalChatCellArr.count > 4 { /// Если есть хотя бы 4 фото, то убираем пустые ячейки
                potenitalChatCellArr.removeAll(where: {$0.avatar == nil })
            }
            contenView.frame.size.width = widthHorizontalScrollview()
            horizontalScrollView.contentSize.width = widthHorizontalScrollview()
        }
    }
    
    private lazy var horizontalScrollView: UIScrollView =  {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.frame = CGRect(x: 10, y: 60, width: view.frame.width, height: 155)
        scrollView.contentSize = CGSize(width: widthHorizontalScrollview(), height: 155)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contenView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        contentView.frame.size = CGSize(width: widthHorizontalScrollview(), height: 155)
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
        
        if let vc = self.tabBarController?.viewControllers![0] as? PairsViewController {
            currentAuthUser = vc.currentAuthUser
        }
        mostViewScrolling.addSubview(horizontalScrollView)
        horizontalScrollView.addSubview(contenView)
        contenView.addSubview(horizontalStackView)
        
        tableView.register(UINib(nibName: "Main", bundle: nil), forCellReuseIdentifier: "ChatCell")
        tableView.dataSource = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        createChatViewCell()
        setupContentViewContstains()
        
        
    }
}



//MARK: -  Создание ячеек чатов пользователя и потенциальных чатов

extension ChatViewController {
    
    func createChatViewCell()  {
        
        guard let authUser = currentAuthUser else {return}
        
        if authUser.matchArr.count == 0 {
            creatEmptyPotentialCell()
            return
        }
    
//        for chat in authUser.chatArr {
//
//            guard let user = authUser.matchArr.first(where: {$0.ID == chat.ID}) else {return}
//
//            if chat.messages.count > 0 { /// Если у текущего пользователя был чат с новым пользователем
//
//                let chatCell = ChatCellView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100), ID: chat.ID)
//
//                chatCell.avatar.image = user.avatar
//                chatCell.nameLabel.text = user.name
//                chatCell.commentLabel.text = chat.messages.last?.body /// Последнее сообщение от нее
//                chatCell.scrollView = verticalScrollView
//
//                chatCell.tapGesture.addTarget(self, action: #selector(handleTap(_:)))
//
//                let action = UIAction { [weak self] UIAction in
//                    self?.deleteChat(ID: chat.ID)
//                }
//
//                chatCell.deleteView.button.addAction(action, for: .touchUpInside)
//
//                chatCellArr.append(chatCell)
//                verticalStackView.addArrangedSubview(chatCell)
//            }
//        }
        
        createPotentialChatt()
        creatEmptyPotentialCell()
    }
    
//MARK: -  Создание EmptyChatCell
    
    func createPotentialChatt(){
        
        guard let authUser = currentAuthUser else {return}
        print(authUser.matchArr.count, " -  Count")
        for user in authUser.matchArr {
            
            guard let chatUser = currentAuthUser?.chatArr.first(where: {$0.ID == user.ID }) else {return}
            
            if chatUser.messages.count == 0 {
                let potentialChatCell = PotentialChatCell(frame: CGRect(x: 0, y: 0, width: 105, height: 155), avatar: user.avatar, name: user.name,ID: user.ID)
                
                potentialChatCell.tapGesture.addTarget(self, action: #selector(handleTap(_:)))
                potenitalChatCellArr.append(potentialChatCell)
                horizontalStackView.addArrangedSubview(potentialChatCell)
            }
            
        }
    }
    
    //MARK: -  Создание EmptyChatCell
        
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
}



extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let height = CGFloat(100 * 100) + 260
        
        if height > 0 {
            heightMostScrollView.constant = height /// Обновляем константу вертикального ScrollView  в зависимости от количества чатов
        }else {
            heightMostScrollView.constant = 100 + 260
        }
        view.layoutIfNeeded()
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        return cell
    }
    
    
}

//MARK: - Переход в контроллер чата с пользователем

extension ChatViewController {
    
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        print("HandleTap")
        guard let authUser = currentAuthUser else {return}
        
        if let currentView = sender.view as? ChatCellView {
            let user = authUser.matchArr.first(where: {$0.ID == currentView.ID})
            selectedUser = user
            performSegue(withIdentifier: "goToChat", sender: self)
        }
        
        else if let currentView = sender.view as? PotentialChatCell {
            guard let id = currentView.ID else {return}
            let user = authUser.matchArr.first(where: {$0.ID == id})
            selectedUser = user
            performSegue(withIdentifier: "goToChat", sender: self)
        }else {
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destanationVC = segue.destination as? ChatUserController else  {return}
        guard let user = selectedUser else {return}
        destanationVC.selectedUser = user
    }
}


//MARK: -  Удаление чата

extension ChatViewController {
    
//    func deleteChat(ID:String){
//        guard let index = chatCellArr.firstIndex(where: {$0.ID == ID}) else {return}
//        chatCellArr[index].removeFromSuperview()
//        chatCellArr.remove(at: index)
//    }
    
}

//MARK: -  Переход с MatchController в ChatUserController

extension ChatViewController: passDataDelegate {
    func goToMatchVC( matchController: UIViewController?, matchUser: User) {
        selectedUser = matchUser
        performSegue(withIdentifier: "goToChat", sender: self)
    }
}

extension ChatViewController {
    
    func widthHorizontalScrollview() -> CGFloat {
        
        if potenitalChatCellArr.count > 0 {
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




