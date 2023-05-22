import Foundation
import UIKit

class ChatCellView: UIView {
    
    let avatar = UIImageView(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
    let nameLabel =  UILabel()
    let commentLabel =  UILabel()
    
    init(frame: CGRect,name: String,comment:String,avatar: UIImage) {
        
        self.nameLabel.text = name
        self.commentLabel.text = comment
        self.avatar.image = avatar
        super.init(frame: frame)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.frame.size.height = self.frame.height - 20
        avatar.frame.size.width = self.frame.height - 20
        nameLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: self.center.y - 50, width: 200, height: 50)
        commentLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: self.center.y + 50, width: self.frame.width, height: 50)
        self.addSubview(nameLabel)
        self.addSubview(commentLabel)
        self.addSubview(avatar)
        print("Yeah")
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
}
