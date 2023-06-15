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
    var bottomConstant = CGFloat()
    
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



//MARK: - Расширение для построения MessageView разной формы


extension UIBezierPath {
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGSize = .zero, topRightRadius: CGSize = .zero, bottomLeftRadius: CGSize = .zero, bottomRightRadius: CGSize = .zero,indentFromLeft: CGFloat, indentFromRight: CGFloat){

        self.init()

        let path = CGMutablePath()
        
        let topLeft = CGPoint(x: rect.minX + indentFromLeft, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX + indentFromRight, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX + indentFromRight, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX + indentFromLeft, y: rect.maxY)
        
        

        if topLeftRadius != .zero{
            path.move(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }

        if topRightRadius != .zero{
            path.addLine(to: CGPoint(x: topRight.x-topRightRadius.width, y: topRight.y))
            path.addCurve(to:  CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height), control1: CGPoint(x: topRight.x, y: topRight.y), control2:CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height))
        } else {
             path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
        }

    
        if bottomRightRadius != .zero{
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y-bottomRightRadius.height))
            path.addCurve(to: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y), control1: CGPoint(x: bottomRight.x, y: bottomRight.y), control2: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y))
        } else {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        }

        if bottomLeftRadius != .zero{
            path.addLine(to: CGPoint(x: bottomLeft.x+bottomLeftRadius.width, y: bottomLeft.y))
            path.addCurve(to: CGPoint(x: bottomLeft.x , y: bottomLeft.y-bottomLeftRadius.height), control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y), control2: CGPoint(x: bottomLeft.x , y: bottomLeft.y-bottomLeftRadius.height))
        } else {
            path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        }

        if topLeftRadius != .zero{
            path.addLine(to: CGPoint(x: topLeft.x , y: topLeft.y+topLeftRadius.height))
            path.addCurve(to: CGPoint(x: topLeft.x+topLeftRadius.width , y: topLeft.y) , control1: CGPoint(x: topLeft.x , y: topLeft.y) , control2: CGPoint(x: topLeft.x+topLeftRadius.width , y: topLeft.y))
        } else {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }

        path.closeSubpath()
        cgPath = path
    }
}

extension UIView{
    func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0,indentFromLeft:CGFloat,indentFromRight:CGFloat) {//(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius,indentFromLeft: indentFromLeft,indentFromRight: indentFromRight)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

