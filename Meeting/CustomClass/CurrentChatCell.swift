//
//  CurrentChatCell.swift
//  Meeting
//
//  Created by Деним Мержан on 29.05.23.
//

import UIKit

class CurrentChatCell: UITableViewCell {


    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusMessage: UIImageView!
    
    @IBOutlet weak var heartLikeImageView: UIImageView!
    @IBOutlet weak var heartView: UIView!
    
    var currentUser = Bool()
    
    var perfectWidthLabel = CGFloat()
    var pruningMessageBuble: CGFloat {
        get {
            if messageBubble.frame.height > 55 {return 0}
            if currentUser {
                return messageBubble.frame.width - perfectWidthLabel - 37
            }else {
                return messageBubble.frame.width - perfectWidthLabel - 20
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = UIScreen.main.bounds.width ///  Обновляем ширину ячейки в зависимости от ширины экрана
        layoutIfNeeded()
        
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        heartLikeImageView.alpha = 0.2
  
    }
    
    override func prepareForReuse() { /// Подготовка перед повторным использованием
        
        currentUser = false
        statusMessage.image = UIImage(named: "SendMessageTimer")
//       bottomMessageViewConstrains.constant = 5
        
    }

    override func layoutSubviews() {
                
        if currentUser {
            var leftRadius = messageBubble.frame.height / 2
            if messageBubble.frame.height > 55 {
                leftRadius = messageBubble.frame.height / 3
            }
            messageBubble.roundCorners(topLeft: leftRadius, topRight: 23, bottomLeft: leftRadius, bottomRight: 10,indentFromLeft: pruningMessageBuble,indentFromRight: 0)
        }else {
            var rightRadius = messageBubble.frame.height / 2
            if messageBubble.frame.height > 55 {
                rightRadius = messageBubble.frame.height / 3
            }
            messageBubble.roundCorners(topLeft: 23, topRight: rightRadius, bottomLeft: 10, bottomRight: rightRadius,indentFromLeft: 0,indentFromRight: -pruningMessageBuble)
        }
    }
}




