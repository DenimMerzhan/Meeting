//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cell = createChatViewCell()
        view.addSubview(cell)
        
    }
    

}

extension ChatViewController {
    func createChatViewCell() -> ChatCellView {
        
        let chatCell = ChatCellView(x: 10, y: 200, width: view.frame.width)
        
        chatCell.avatar.image = UIImage(named: "KatyaS")
        chatCell.nameLabel.text = "Алиса"
        chatCell.commentLabel.text = "Привет как дела, все хорошо?"
                                    
      
        return chatCell
    }
}
