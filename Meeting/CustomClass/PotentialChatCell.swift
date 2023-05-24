//
//  PotentialChatCell.swift
//  Meeting
//
//  Created by Деним Мержан on 23.05.23.
//

import Foundation
import UIKit

class PotentialChatCell: UIView {
    
    var avatar: UIImage?
    var name: String?
    
    init(frame:CGRect,avatar:UIImage?,name:String?) {
        self.avatar = avatar
        self.name = name
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        self.backgroundColor = .clear
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - 25))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        if let avatarUser = avatar, let nameUser = name { /// Если не переданы имя или фото то делаем пустую ячейку
            
            let label = UILabel(frame: CGRect(x: 0, y: self.frame.maxY - 20, width: self.frame.width, height: 20))
            imageView.image = avatarUser
            
            label.text = nameUser
            label.center.x = 50
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 20)
            label.minimumScaleFactor = 0.5
            label.adjustsFontSizeToFitWidth = true
            label.textColor = .black
            
            
            self.addSubview(label)
        }else {
            imageView.backgroundColor = .gray.withAlphaComponent(0.1)
            imageView.layer.cornerRadius = 5
            imageView.clipsToBounds = true
        }
        
        self.addSubview(imageView)
        
    }
    
}
