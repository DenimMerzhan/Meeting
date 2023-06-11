//
//  CurrentChatCell.swift
//  Meeting
//
//  Created by Деним Мержан on 29.05.23.
//

import UIKit

class CurrentChatCell: UITableViewCell {


    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leftMessageViewConstrains: NSLayoutConstraint!
    @IBOutlet weak var rightMessageViewConstrains: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIImageView!
    @IBOutlet weak var bottomMessageViewConstrains: NSLayoutConstraint!
    
    @IBOutlet weak var heartLikeView: UIView!
    @IBOutlet weak var statusMessage: UIImageView!
    
    @IBOutlet weak var rightConstrainsToSuperView: NSLayoutConstraint!
    @IBOutlet weak var labelRightConstrains: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = UIScreen.main.bounds.width ///  Обновляем ширину ячейки в зависимости от ширины экрана
        layoutIfNeeded()
        
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        messageView.layer.cornerRadius = messageView.frame.height /  5
        likeButton.alpha = 0.2
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() { /// Подготовка перед повторным использованием
        
        heartLikeView.isHidden = false
        rightConstrainsToSuperView.isActive = false
        
        rightMessageViewConstrains.constant = 5
        rightConstrainsToSuperView.constant = 5
        leftMessageViewConstrains.constant = 5
       
        statusMessage.image = UIImage(named: "SendMessageTimer")
        
        labelRightConstrains.constant = 22
        
//        bottomMessageViewConstrains.constant = 5
        
        rightMessageViewConstrains.isActive = true
    }
    
}
