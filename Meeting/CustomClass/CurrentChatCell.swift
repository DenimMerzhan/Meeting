//
//  CurrentChatCell.swift
//  Meeting
//
//  Created by Деним Мержан on 29.05.23.
//

import UIKit

class CurrentChatCell: UITableViewCell {


    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        messageView.layer.cornerRadius = messageView.frame.height /  5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
