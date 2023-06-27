//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit
import FirebaseFirestore

protocol MatchArrHasBennUpdate {
    func updateDataWheTheMatchArrUpdate()
    func updateDataWhenUserDelete()
}

extension MatchArrHasBennUpdate {
    func updateDataWheTheMatchArrUpdate() {}
    func updateDataWhenUserDelete(){}
}

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
    
    var shouldPerfomSegue: Bool {
        get {
            if selectedUser == nil {return false}
            if currentAuthUser == nil {return false}
            if currentAuthUser?.matchArr.contains(where: {$0.ID == selectedUser?.ID }) == false {return false}
            if selectedUser?.chat == nil {return false}
            return true
        }
    }
    
    var arr = [Int]()
    var potentialChatArr: [User] {
        get {
            var potentialArr = [User]()
            guard let authUser = currentAuthUser else {return [User]()}
            
            for user in authUser.matchArr {
                guard let chat = user.chat else {continue}
                if  chat.messages.count == 0 {
                    potentialArr.append(user)
                }
            }
            return potentialArr
        }
    }
    
    var chatArr: [Chat] {
        get {
            var chatArr = [Chat]()
            guard let authUser = currentAuthUser else {return chatArr}
            
            for user in authUser.matchArr {
                guard let chat = user.chat else {continue}
                if chat.messages.count > 0 {
                    chatArr.append(chat)
                }
            }
            return chatArr
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSetings()
    }
    override func viewWillAppear(_ animated: Bool) {

        if let vc = self.tabBarController?.viewControllers![0] as? PairsViewController {
            currentAuthUser = vc.currentAuthUser
            currentAuthUser?.delegate = self
        }
        addListeners()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeListeners() /// Удаляем прослушивателей что бы они не нагружали ChatUserController
    }
}


//MARK: - TableViewDataSource and Delegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let height = CGFloat(chatArr.count * 100) + 330
        heightMostScrollView.constant = height /// Обновляем константу вертикального ScrollView  в зависимости от количества чатов
        view.layoutIfNeeded()
        return chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        
        guard let authUser = currentAuthUser else {return cell}
        let chat = chatArr[indexPath.row]
        guard let pairUser = authUser.matchArr.first(where: {chat.ID.contains($0.ID)}) else {return cell}
       
        cell.userID = pairUser.ID
        pairUser.avatar?.delegate = self
        
        cell.avatar.image = pairUser.avatar?.image
        if chat.numberUnreadMessges(pairID: pairUser.ID) > 0 {
            cell.countUnreadMessageView.isHidden = false
            cell.countUnreadMessageLabel.text = String(chat.numberUnreadMessges(pairID: pairUser.ID))
        }
        
        cell.commentLabel.text = chat.messages.last?.body
        cell.nameLabel.text = pairUser.name
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatCell else {return}
        guard let matchUser = currentAuthUser?.matchArr.first(where: {$0.ID == cell.userID}) else {return}
        
        selectedUser = matchUser
        tableView.deselectRow(at: indexPath, animated: true)
        if shouldPerfomSegue { performSegue(withIdentifier: "goToChat", sender: self)}
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatCell else {return nil}
        guard let matchUser = currentAuthUser?.matchArr.first(where: {$0.ID == cell.userID}) else {return nil}
        guard let authUser = currentAuthUser else {return nil}
        
        let deleteAction = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            authUser.deletePair(user: matchUser)
            completion(true)
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
            
            let user = potentialChatArr[indexPath.row]
            guard let chatID = user.chat?.ID else {return cell}
            cell.chatID = chatID
            user.avatar?.delegate = self
            
            cell.avatar.image = user.avatar?.image
            cell.name.text = potentialChatArr[indexPath.row].name
        }else {
            cell.avatar.image = UIImage(color: UIColor(named: "GrayColor")!)
            cell.name.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { /// Делаем отступы
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PotentialChatCell else {return}
        guard let matchUser = currentAuthUser?.matchArr.first(where: {cell.chatID.contains($0.ID)}) else {return} /// Ищем пользователя в архиве матчАрр если его нет значит его удалили из пар
        selectedUser = matchUser
        if shouldPerfomSegue {performSegue(withIdentifier: "goToChat", sender: self)}
        
    }
}

//MARK: - Переход в контроллер чата с пользователем

extension ChatViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destanationVC = segue.destination as? ChatUserController else  {return}
        guard let user = selectedUser else {return}
        guard let authUser = currentAuthUser else {return}
        guard let chat = user.chat else {return}
        destanationVC.chat = chat
        destanationVC.selectedUser = user
        destanationVC.currentAuthUser = authUser
    }
}


//MARK: -  Переход с MatchController в ChatUserController

extension ChatViewController: passDataDelegate, MatchArrHasBennUpdate, LoadPhoto {
    
    func userPhotoLoaded() {
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func updateDataWheTheMatchArrUpdate() { /// Каждый раз когда обновился MatchArr обновляем данные
        DispatchQueue.main.async {
            self.addListeners()
        }
    }
    
    func goToMatchVC( matchController: UIViewController?, matchUser: User, currentAuthUser: CurrentAuthUser) {
        selectedUser = matchUser
        self.currentAuthUser = currentAuthUser
        if shouldPerfomSegue {
            performSegue(withIdentifier: "goToChat", sender: self)
        }
    }
}


//MARK: -  Добавление прослушивателей

extension ChatViewController {
    
    func addListeners(){
        let db = Firestore.firestore()
        guard let authUser = currentAuthUser else {return}
        
        removeListeners()

        if authUser.matchArr.count == 0 {
            tableView.reloadData()
            collectionView.reloadData()
        }
        
        for user in authUser.matchArr {
            
            let listener = db.collection("Chats").document(user.chatID).collection("Messages").order(by:"Date").addSnapshotListener { querySnapshot, Error in
                
                print("ListenMessageChatController")
                
                if let err = Error { print("Ошибка прослушивания снимков чата - \(err)"); return}
                
                guard let documents = querySnapshot?.documents else {return}
                if documents.isEmpty {return}
                
                user.chat?.messages.removeAll()
                
                for data in documents {
                    
                    if let body = data["Body"] as? String, let sender = data["Sender"] as? String, let date = data["Date"] as? Double, let messageRed = data["MessageRead"] as? Bool, let messageSendOnServer = data["MessageSendOnServer"] as? Bool {
                        let message = message(sender: sender, body: body, messagePathOnServer: data.reference, messagedWritingOnServer: messageSendOnServer, messageRead: messageRed, dateMessage: date)
                        
                        user.chat?.messages.append(message)
                    }
                    
                }
                                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            }
            listenersArr.append(listener)
        }
    }
    
    func removeListeners(){ /// Удаление всех прослушивателей
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


