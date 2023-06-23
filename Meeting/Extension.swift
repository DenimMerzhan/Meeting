//
//  Extension.swift
//  Meeting
//
//  Created by Деним Мержан on 15.06.23.
//

import Foundation
import UIKit



//MARK: - Конвертирование UIView to Image

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
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

//MARK: -  Расширение для формирования рандомного ID для фото - Надо исправить т.к есть шанс получить одинаковый ID

extension String {
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
