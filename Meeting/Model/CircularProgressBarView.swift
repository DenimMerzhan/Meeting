//
//  CircularProgressBarView.swift
//  Meeting
//
//  Created by Деним Мержан on 30.04.23.
//

import Foundation
import UIKit


class CircularProgressBarView: UIView {
    
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var startPoint = CGFloat(-3 * Double.pi / 2)
    private var endPoint = CGFloat(Double.pi / 2) /// Прогресс layer начинается с этой точки
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createCircularPath(radius: CGFloat){
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: radius, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round /// Задает стиль окончания линии для контура фигуры.
        circleLayer.lineWidth = 10.0
        circleLayer.strokeEnd = 1.0 /// Относительное местоположение, в котором следует прекратить обводку контура. Анимация.
        circleLayer.strokeColor = UIColor.gray.cgColor /// Цвет, используемый для обводки траектории фигуры. Анимация.
        circleLayer.opacity = 0.2
        
        layer.addSublayer(circleLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor(named: "MainAppColor")?.cgColor
        
        layer.addSublayer(progressLayer)
    }
    
    
    func progressAnimation(duration: TimeInterval,toValue: Float) {
        
            // created circularProgressAnimation with keyPath
            let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
            // set the end time
        
            circularProgressAnimation.duration = duration
            circularProgressAnimation.toValue = toValue
            circularProgressAnimation.fillMode = .forwards /// Приемник остается видимым в своем конечном состоянии, когда анимация завершена.
            circularProgressAnimation.isRemovedOnCompletion = false /// Определяет, удаляется ли анимация из анимаций целевого слоя после завершения.
            progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        }
   
    
}
