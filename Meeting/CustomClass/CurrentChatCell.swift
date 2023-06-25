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
    @IBOutlet weak var messageLikeButton: UIButton!
    @IBOutlet weak var heartView: UIView!
    
    var loadIndicator = UIActivityIndicatorView(frame: .zero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.width = UIScreen.main.bounds.width ///  Обновляем ширину ячейки в зависимости от ширины экрана
        layoutIfNeeded()
        
        loadIndicator.frame.size = avatar.frame.size
        loadIndicator.backgroundColor = .gray
        loadIndicator.hidesWhenStopped = true
        loadIndicator.startAnimating()
        avatar.addSubview(loadIndicator)
        
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




