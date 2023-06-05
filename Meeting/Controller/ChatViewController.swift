//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatViewController: UIViewController {

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var mostViewScrolling: UIView!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var heightMostScrollView: NSLayoutConstraint!
    
    
    var selectedUser: User?
    var currentAuthUser: CurrentAuthUser?
    
    var potentialChatArr: [User] {
        get {
            var potentialArr = [User]()
            guard let authUser = currentAuthUser else {return [User]()}
            for chat in authUser.chatArr {
                if chat.messages.count == 0 {
                    guard let user = authUser.matchArr.first(where: {$0.ID == chat.ID }) else {continue}
                    potentialArr.append(user)
                }
            }
            return potentialArr
        }
    }
    
    var chatArr: [chat] {
        get {
            var chatArr = [chat]()
            guard let authUser = currentAuthUser else {return [chat]()}
            for chat in authUser.chatArr {
                if chat.messages.count > 0 {
                    chatArr.append(chat)
                }
            }
            return chatArr
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.tabBarController?.viewControllers![0] as? PairsViewController {
            currentAuthUser = vc.currentAuthUser
        }
        
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
        
        let chat = chatArr[indexPath.row]
        guard let authUser = currentAuthUser else {return cell}
        guard let pairUser = authUser.matchArr.first(where: {$0.ID == chat.ID}) else {return cell}
        
        cell.scrollView = verticalScrollView
        cell.avatar.image = pairUser.avatar
        cell.nameLabel.text = pairUser.name
        cell.commentLabel.text = chat.messages.last?.body /// Последнее сообщение в чате
        
        let action = UIAction { [weak self] UIAction in
            guard let indexChat = authUser.chatArr.firstIndex(where: {$0.ID == chat.ID}) else {return}
            guard let indexUser = authUser.matchArr.firstIndex(where: {$0.ID == chat.ID}) else {return}
            
            authUser.chatArr.remove(at: indexChat)
            authUser.matchArr.remove(at: indexUser)
            self?.tableView.reloadData()
        }
        
        cell.deleteView.button.addAction(action, for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = chatArr[indexPath.row].ID
        guard let authUser = currentAuthUser else {return}
        guard let matchUser = authUser.matchArr.first(where: {$0.ID == id}) else {return}
        selectedUser = matchUser
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToChat", sender: self)
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
        
    }
}


//MARK: -  Переход с MatchController в ChatUserController

extension ChatViewController: passDataDelegate {
    func goToMatchVC( matchController: UIViewController?, matchUser: User) {
        selectedUser = matchUser
        performSegue(withIdentifier: "goToChat", sender: self)
    }
}




