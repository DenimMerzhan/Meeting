import Foundation
import UIKit

class ChatCellView: UIView {
    
    let avatar = UIImageView(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
    let nameLabel =  UILabel()
    let commentLabel =  UILabel()
    private let bottomLine = UIView()
    
    init(x: CGFloat,y: CGFloat,width: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: 100))
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        avatar.frame.size.height = 80
        avatar.frame.size.width = 80
        
        nameLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 25, width: 200, height: 30)
        
        commentLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 60, width: self.frame.width, height: 20)
        
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        
        nameLabel.font = .boldSystemFont(ofSize: 30)
        commentLabel.font = .systemFont(ofSize: 12)
        commentLabel.textColor = .gray
        
        
        bottomLine.frame = CGRect(x: avatar.frame.maxX, y: 99, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = .gray
        bottomLine.layer.cornerRadius = 10
        bottomLine.clipsToBounds = true
        bottomLine.alpha = 0.3
        
        
        
        self.backgroundColor = .clear
        
        
        
        self.addSubview(avatar)
        self.addSubview(nameLabel)
        self.addSubview(commentLabel)
        self.addSubview(bottomLine)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
