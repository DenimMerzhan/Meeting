//
//  CurrentChatCell.swift
//  Meeting
//
//  Created by Деним Мержан on 29.05.23.
//

import UIKit

class CurrentChatCell: UITableViewCell {



    @IBOutlet weak var avatar: DefaultLoadPhoto!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusMessage: UIImageView!
    @IBOutlet weak var messageLikeButton: UIButton!
    @IBOutlet weak var heartView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = UIScreen.main.bounds.width ///  Обновляем ширину ячейки в зависимости от ширины экрана
        layoutIfNeeded()
        
        avatar.loadIndicator.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        messageLikeButton.alpha = 0.2
  
    }
    
    override func prepareForReuse() { /// Подготовка перед повторным использованием
        
        messageBubble.setNeedsDisplay()
        
        messageLikeButton.removeTarget(nil, action: nil, for: .allEvents)
        statusMessage.image = UIImage(named: "SendMessageTimer")
        messageLikeButton.setImage(UIImage(named: "likeMessageBlack"), for: .normal)
        messageLikeButton.alpha = 0.2
        messageLikeButton.tintColor = .gray
        
//       bottomMessageViewConstrains.constant = 5
        
    }
    
}




