//
//  ChatCellTableViewCell.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatCell: UITableViewCell {

    
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        avatarUser.layer.cornerRadius = 10
//        avatarUser.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
