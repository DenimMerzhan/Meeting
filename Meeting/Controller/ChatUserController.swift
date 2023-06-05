//
//  ChatUserController.swift
//  Meeting
//
//  Created by Деним Мержан on 24.05.23.
//

import UIKit
import FirebaseFirestore

class ChatUserController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topElementView: UIView!
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var currentAuthUser = CurrentAuthUser(ID: "")
    var selectedUser = User(ID: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CurrentChatCell", bundle: nil), forCellReuseIdentifier: "currentChatCell")
        
        
        avatarUser.layer.cornerRadius = avatarUser.frame.width / 2
        avatarUser.clipsToBounds = true
        topElementView.layer.shadowColor = UIColor.black.cgColor
        topElementView.layer.shadowOpacity = 0.1
        topElementView.layer.shadowOffset = CGSize(width: 0, height: 1)
        topElementView.layer.shadowRadius = 1
        
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.backgroundColor = UIColor(named: "PlaceHolderChatColor")
        textField.layer.borderWidth = 0.2
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.masksToBounds = true
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Сообщение",attributes: attributes)
     
        avatarUser.image = selectedUser.avatar
        nameUser.text = selectedUser.name
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        guard let body = textField.text else {return}
    
        textField.text = ""
        
        if let error = currentAuthUser.sendMessageToServer(pairUserID: selectedUser.ID, body: body) {
            print("Ошибка отправки сообщения - \(error)")
        }else {
            tableView.reloadData()
            
        }
        
    }
    
}

//MARK: - UITableViewDataSource

extension ChatUserController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let chatArr = currentAuthUser.chatArr.first(where: {$0.ID == selectedUser.ID })?.messages else {return 0}
        return chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentChatCell", for: indexPath) as! CurrentChatCell
        
        guard let chatArr = currentAuthUser.chatArr.first(where: {$0.ID == selectedUser.ID })?.messages else {return cell}
        
        cell.messageLabel.text = chatArr[indexPath.row].body
        let id = chatArr[indexPath.row].sender
        
        if id == currentAuthUser.ID {
            
            cell.heartLikeView.removeFromSuperview()
            cell.rightConstrainsToSuperView.isActive = true /// Дополнительная константа которая говорит что MessageView будт на расстояние от SuperView на 5 пунктов
            
            cell.messageLabel.textAlignment = .right
            cell.avatar.image = currentAuthUser.avatar
            cell.messageView.backgroundColor = UIColor(named: "CurrentUserMessageColor")
            cell.messageLabel.textColor = .white
            
            let width = cell.messageLabel.intrinsicContentSize.width
            
            if width < cell.messageLabel.frame.width {
                let newLeftConstant = cell.messageLabel.frame.width - width/// Получаем новую разницу между mesage view и avatar
                cell.leftMessageViewConstrains.constant += newLeftConstant + 30
            }
            
            
        }else {
            
            cell.messageLabel.textAlignment = .left
            cell.messageView.backgroundColor = UIColor(named: "GrayColor")
            cell.avatar.image = selectedUser.avatar
            
            let width = cell.messageLabel.intrinsicContentSize.width
            
            if width < cell.messageLabel.frame.width {
                let newLeftConstant = cell.messageLabel.frame.width - width
                cell.rightMessageViewConstrains.constant += newLeftConstant
            }
        }
        
        
        if indexPath.row + 1 < chatArr.count && chatArr[indexPath.row + 1].sender == id {
            cell.avatar.image = UIImage()
            cell.bottomMessageViewConstrains.constant = 0
        }
        
   
        return cell
    }
    
}

////MARK: -  Отслеживание изменений на сервере
//
//extension ChatUserController {
//
//    func loadMessage(){
//        print("Shet")
//
//        guard let indexChat = currentAuthUser.chatArr.firstIndex(where: {$0.ID == selectedUser.ID}) else {return}
//
//        let db = Firestore.firestore()
//        let refChat = db.collection("Users").document(currentAuthUser.ID).collection("Chats").document(selectedUser.ID).collection("Messages")
//        refChat.order(by: "Date").addSnapshotListener { [weak self] QuerySnapshot, err in
//
//            if let error = err {print("Ошибка считывания сообщения с сервера - \(error)")}
//
//            guard let document = QuerySnapshot else {return}
//            self?.currentAuthUser.chatArr[indexChat].messages.removeAll()
//
//            for data in document.documents {
//                if let body = data["Body"] as? String, let sender = data["Sender"] as? String {
//                    self?.currentAuthUser.chatArr[indexChat].messages.append(message(sender: sender, body: body))
//                }
//            }
//
//            self?.tableView.reloadData()
//            let count = self?.currentAuthUser.chatArr[indexChat].messages.count ?? 1
//            let indexPath = IndexPath(row: count - 1, section: 0)
//            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
//        }
//    }
//
//}
