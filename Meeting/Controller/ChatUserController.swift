//
//  ChatUserController.swift
//  Meeting
//
//  Created by Деним Мержан on 24.05.23.
//

import UIKit

class ChatUserController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topElementView: UIView!
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var currentUserID = String()
    var selectedUser = User(ID: "+79817550000")
    var chatArr = [message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
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
        
        
        chatArr.append(message(sender: selectedUser.ID, body: "Привет как ты у тебя все хорошо, а то не слышно не видно не страшно не бащно аууууу?"))
        chatArr.append(message(sender: currentUserID, body: "Я ок, а ты как?"))
        chatArr.append(message(sender: selectedUser.ID, body: "Я тоже"))
        chatArr.append(message(sender: selectedUser.ID, body: "Что будем делать?"))
        chatArr.append(message(sender: currentUserID, body: "Привет как ты у тебя все хорошо, а то не слышно не видно не страшно не бащно аууууу?"))
        chatArr.append(message(sender: currentUserID, body: "Я ок, а ты как?"))
        chatArr.append(message(sender: currentUserID, body: "Я тоже"))
        chatArr.append(message(sender: selectedUser.ID, body: "Что будем делать?"))
        
        tableView.register(UINib(nibName: "CurrentChatCell", bundle: nil), forCellReuseIdentifier: "currentChatCell")
     
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

}


extension ChatUserController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentChatCell", for: indexPath) as! CurrentChatCell
        
        cell.messageLabel.text = chatArr[indexPath.row].body
        let id = chatArr[indexPath.row].sender
        
        if id == currentUserID {
            
            cell.heartLikeView.removeFromSuperview()
            cell.rightConstrainsToSuperView.isActive = true /// Дополнительная константа которая говорит что MessageView будт на расстояние от SuperView на 5 пунктов
            
            cell.messageLabel.textAlignment = .right
            cell.avatar.image = UIImage()
            cell.messageView.backgroundColor = UIColor(named: "CurrentUserMessageColor")
            cell.messageLabel.textColor = .white
            
            let width = cell.messageLabel.intrinsicContentSize.width
            print(width)
            print(cell.messageLabel.frame.width)
            
            if width < cell.messageLabel.frame.width {
                let newLeftConstant = cell.messageLabel.frame.width - width/// Получаем новую разницу между mesage view и avatar
                cell.leftMessageViewConstrains.constant += newLeftConstant + 30
            }
            
            
        }else {
            
            cell.messageLabel.textAlignment = .left
            cell.messageView.backgroundColor = UIColor(named: "GrayColor")
            
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
