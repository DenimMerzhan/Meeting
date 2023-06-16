//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit
import FirebaseFirestore

class ChatViewController: UIViewController {

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var mostViewScrolling: UIView!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var heightMostScrollView: NSLayoutConstraint!
    
    
    var selectedUser: User?
    var currentAuthUser: CurrentAuthUser?
    var listenersArr =  [ListenerRegistration]()
    
    var potentialChatArr: [User] {
        get {
            var potentialArr = [User]()
            guard let authUser = currentAuthUser else {return [User]()}
            
            for user in authUser.matchArr {
                if  authUser.chatArr.first(where: {$0.ID.contains(user.ID)}) == nil {
                    potentialArr.append(user)
                }
            }
            return potentialArr
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSetings()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("Appear")
        
        if let vc = self.tabBarController?.viewControllers![0] as? PairsViewController {
            currentAuthUser = vc.currentAuthUser
        }
        collectionView.reloadData()
        addListeners()
    }
}


//MARK: - TableViewDataSource and Delegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let autUser = currentAuthUser else {return 0 }
        let height = CGFloat(autUser.chatArr.count * 100) + 330
        heightMostScrollView.constant = height /// Обновляем константу вертикального ScrollView  в зависимости от количества чатов
        view.layoutIfNeeded()
        return autUser.chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        
        guard let authUser = currentAuthUser else {return cell}
        let chat = authUser.chatArr[indexPath.row]
        guard let pairUser = authUser.matchArr.first(where: {chat.ID.contains($0.ID)}) else {return cell}
       
        cell.chatID = chat.ID
        if let lastUnreadMessage = chat.lastUnreadMessage {
            cell.countUnreadMessageView.isHidden = false
            cell.countUnreadMessageLabel.text = String(chat.numberUnreadMessges)
            cell.commentLabel.text = lastUnreadMessage
        }else {
            cell.commentLabel.text = chat.messages.last?.body /// Последнее сообщение в чате
        }
        
        cell.avatar.image = pairUser.avatar
        cell.nameLabel.text = pairUser.name
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let authUser = currentAuthUser else {return}
        let id = authUser.chatArr[indexPath.row].ID
        guard let matchUser = authUser.matchArr.first(where: {id.contains($0.ID)}) else {return}
        
        selectedUser = matchUser
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatCell else {return nil}
        guard let authUser = currentAuthUser else {return nil}
        
        let deleteAction = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            authUser.deleteChat(chatID: cell.chatID) {
                tableView.reloadData()
                self.addListeners()
                completion(true)
            }
        }

        let banAction = UIContextualAction(style: .normal, title: "") { action, view, completion in
            print("Yeah")
            completion(true)
            
        }
        
        banAction.backgroundColor = UIColor(named: "BanUserColor")
        banAction.image = cell.banImage

        deleteAction.backgroundColor = UIColor(named: "DeleteChatColor")
        deleteAction.image = cell.deleteImage
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction,banAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }
    
}

//MARK: - UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if potentialChatArr.count < 4 {
            return 4
        }else {
            return potentialChatArr.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "potentialChatCell", for: indexPath) as! PotentialChatCell
        
        if indexPath.row < potentialChatArr.count {
            cell.avatar.image = potentialChatArr[indexPath.row].avatar
            cell.name.text = potentialChatArr[indexPath.row].name
        }else {
            cell.avatar.image = nil
            cell.avatar.backgroundColor = UIColor(named: "GrayColor")
            cell.name.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { /// Делаем отступы
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PotentialChatCell else {return}
        if cell.avatar.image != nil { /// Если ячейка не пустая
            selectedUser = potentialChatArr[indexPath.row]
            performSegue(withIdentifier: "goToChat", sender: self)
        }
    }
}

//MARK: - Переход в контроллер чата с пользователем

extension ChatViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destanationVC = segue.destination as? ChatUserController else  {return}
        guard let user = selectedUser else {return}
        guard let authUser = currentAuthUser else {return}
        destanationVC.selectedUser = user
        destanationVC.currentAuthUser = authUser
        
        if let indexChat = authUser.chatArr.firstIndex(where: {$0.ID.contains(user.ID)})  {
            destanationVC.indexChat = indexChat
            destanationVC.messageArr = authUser.chatArr[indexChat].messages
            destanationVC.structMessagesArr = authUser.chatArr[indexChat].structuredMessagesByDates
        }
    }
}


//MARK: -  Переход с MatchController в ChatUserController

extension ChatViewController: passDataDelegate {
    func goToMatchVC( matchController: UIViewController?, matchUser: User) {
        selectedUser = matchUser
        performSegue(withIdentifier: "goToChat", sender: self)
    }
}


//MARK: -  Добавление прослушивателей

extension ChatViewController {
    
    func addListeners(){
        let db = Firestore.firestore()
        guard let authUser = currentAuthUser else {return}
        
        removeListeners()
        
        for user in authUser.matchArr {
            
            var chatID = String()
            if authUser.ID > user.ID {
                chatID = authUser.ID + "\\" + user.ID
            }else {
                chatID = user.ID + "\\" + authUser.ID
            }
            
            let listener = db.collection("Chats").document(chatID).collection("Messages").order(by:"Date").addSnapshotListener { querySnapshot, Error in
                
                print("StatrListen")
                
                if let err = Error { print("Ошибка прослушивания снимков чата - \(err)"); return}
                
                guard let documents = querySnapshot?.documents else {return}
                print("CountDocuments", documents.count)
                guard let lastDoc = documents.last else { /// Если документ пустой значит чата еще было
                    print("NotLastDoc")
                    return}
                
                if authUser.chatArr.first(where: {$0.ID == chatID}) == nil { /// Если документ не пустой, но такого чата еще нету у текущего пользователя то создаем чат
                    print("Новый чат создан")
                    let chat = Chat(ID: chatID)
                    authUser.chatArr.append(chat)
                }
                
                guard let indexChat = authUser.chatArr.firstIndex(where: {$0.ID == chatID}) else {return}
                
                if documents.count > authUser.chatArr[indexChat].messages.count {
                    if let body = lastDoc["Body"] as? String {
                        authUser.chatArr[indexChat].lastUnreadMessage = body
                        authUser.chatArr[indexChat].numberUnreadMessges = documents.count - authUser.chatArr[indexChat].messages.count
                    }
                }else {
                    authUser.chatArr[indexChat].lastUnreadMessage = nil
                }
                                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            }
            listenersArr.append(listener)
        }
    }
    
    func removeListeners(){
        for listener in listenersArr {
            listener.remove()
        }
        listenersArr.removeAll()
    }
}


//MARK: -  Стартовые настройки

extension ChatViewController {
    
    func setupSetings(){
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PotentialChatCell", bundle: nil), forCellWithReuseIdentifier: "potentialChatCell")
        
    }
}


