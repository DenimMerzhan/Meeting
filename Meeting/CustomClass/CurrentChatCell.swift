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
    
    
    @IBOutlet weak var rightConstrainsToSuperView: NSLayoutConstraint!
    
    //    var maskedCornes = CACornerMask() {
//        didSet {
//
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = UIScreen.main.bounds.width ///  Обновляем ширину ячейки в зависимости от ширины экрана
        layoutIfNeeded()
        
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        messageView.layer.cornerRadius = messageView.frame.height /  5
        likeButton.alpha = 0.4
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
