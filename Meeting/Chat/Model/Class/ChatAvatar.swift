//
//  DefaultChatCell.swift
//  Meeting
//
//  Created by Деним Мержан on 25.06.23.
//

import UIKit

class ChatAvatar: UIImageView {

    let loadIndicator = UIActivityIndicatorView(frame: .zero)
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadIndicator.frame.size = self.frame.size
        loadIndicator.center.x = self.frame.width / 2
        loadIndicator.center.y = self.frame.height / 2
        loadIndicator.style = UIActivityIndicatorView.Style.large
        loadIndicator.startAnimating()
        loadIndicator.hidesWhenStopped = true
        
        self.image = UIImage(color: UIColor(named: "GrayColor")!)
        self.addSubview(loadIndicator)
    }
    
}
