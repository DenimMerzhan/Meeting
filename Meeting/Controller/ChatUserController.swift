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
    
    var currentAuthUser: CurrentAuthUser?
    var selectedUser: User?
    
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
     
        
        if let avatar = selectedUser?.avatar, let name = selectedUser?.name {
            avatarUser.image = avatar
            nameUser.text = name
        }
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

}




//MARK: - UITableViewDataSource

extension ChatUserController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let authUser = currentAuthUser else {return 0}
        return authUser.chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentChatCell", for: indexPath) as! CurrentChatCell
        
        guard let authUser = currentAuthUser else {return cell}
        guard let chatUser = selectedUser else  {return cell}
        guard let indexMessages = authUser.chatArr.firstIndex(where: {$0.ID == chatUser.ID}) else {return cell}
        let chatArr = authUser.chatArr[indexMessages].messages
        
        cell.messageLabel.text = chatArr[indexPath.row].body
        let id = chatArr[indexPath.row].sender
        
        if id == authUser.ID {
            
            cell.heartLikeView.removeFromSuperview()
            cell.rightConstrainsToSuperView.isActive = true /// Дополнительная константа которая говорит что MessageView будт на расстояние от SuperView на 5 пунктов
            
            cell.messageLabel.textAlignment = .right
            cell.avatar.image = authUser.avatar
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
            cell.avatar.image = chatUser.avatar
            
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
