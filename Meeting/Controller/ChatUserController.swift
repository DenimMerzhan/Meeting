//
//  ChatUserController.swift
//  Meeting
//
//  Created by Деним Мержан on 24.05.23.
//

import UIKit

class ChatUserController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentUserID = String()
    var selectedUser = User(ID: "+79817550000")
    var chatArr = [message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
//        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
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
