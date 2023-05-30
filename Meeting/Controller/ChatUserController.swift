//
//  ChatUserController.swift
//  Meeting
//
//  Created by Деним Мержан on 24.05.23.
//

import UIKit

class ChatUserController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var userID = String()
    var chatArr = [message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
//        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        chatArr.append(message(sender: "Vika22", body: "Привет как ты у тебя все хорошо, а то не слышно не видно не страшно не бащно аууууу?"))
        chatArr.append(message(sender: userID, body: "Я ок, а ты как?"))
        chatArr.append(message(sender: "Vika22", body: "Я тоже"))
        chatArr.append(message(sender: "Vika22", body: "Что будем делать?"))
        
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
        
        if chatArr[indexPath.row].sender == userID {
            
            cell.messageLabel.textAlignment = .right
            cell.avatar.image = UIImage()
            cell.messageView.backgroundColor = UIColor(named: "CurrentUserMessageColor")
            cell.messageLabel.textColor = .white
            
            let width = cell.messageLabel.intrinsicContentSize.width
            
            if width < cell.messageLabel.frame.width {
                let newLeftConstant = cell.messageLabel.frame.width - width /// Получаем новую разницу между mesage view и avatar
                cell.leftMessageViewConstrains.constant += newLeftConstant
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
        return cell
    }
    
}


//extension ChatUserController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let widthMessageView = view.frame.size.width - 55
//        let label = UILabel(frame: .zero)
//        let height = label.systemLayoutSizeFitting(CGSize(width: widthMessageView, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height /// Рассчитываем высоту текста, что бы он влезал ровно по ее краям
//        print(height)
//        return 55
//    }
//
//}
