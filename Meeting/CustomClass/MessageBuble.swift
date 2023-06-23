//
//  testView.swift
//  Meeting
//
//  Created by Деним Мержан on 22.06.23.
//

import UIKit

class messageBuble: UIView {
    
    var isCurrentUser = Bool()
    var labelForCalculate = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 45))
    
    override func draw(_ rect: CGRect) {
        
        if isCurrentUser {
            labelForCalculate.frame.size.width = self.frame.width - 37
        }else {
            labelForCalculate.frame.size.width = self.frame.size.width - 20
        }
        
        var indentFromLeft: CGFloat = 0 /// Обрезка слева   
        var indentFromRight: CGFloat = 0 /// Обрезка справа
        
        if self.frame.height < 55 {
            indentFromLeft =  self.frame.width  - labelForCalculate.intrinsicContentSize.width - 37 /// 37 ( 12 размер статуса сообщения, 20 расстояние в сткэ вию, 5 расстояние между лейбл и статусом сообщения
            indentFromRight = -(self.frame.width  - labelForCalculate.intrinsicContentSize.width - 20)
        }
        
        var maskPath = UIBezierPath()
        
        if isCurrentUser {
            
            var leftRadius = self.frame.height / 2
            if self.frame.height > 55 {
                leftRadius = self.frame.height / 3
            }
            let topLeftRadius = CGSize(width: leftRadius, height: leftRadius)
            let topRightRadius = CGSize(width: 23, height: 23)
            let bottomLeftRadius = CGSize(width: leftRadius, height: leftRadius)
            let bottomRightRadius = CGSize(width: 10, height: 10)
            
            maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius, indentFromLeft: indentFromLeft, indentFromRight: 0)
        }
        else {
            var rightRadius = self.frame.height / 2
            if self.frame.height > 55 {
                rightRadius = self.frame.height / 3
            }
            
            let topLeftRadius = CGSize(width: 23, height: 23)
            let topRightRadius = CGSize(width: rightRadius, height: rightRadius)
            let bottomLeftRadius = CGSize(width: 10, height: 10)
            let bottomRightRadius = CGSize(width: rightRadius, height: rightRadius)
            
            maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius, indentFromLeft: 0, indentFromRight: indentFromRight)
        }
       
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
        
    }
    
}
