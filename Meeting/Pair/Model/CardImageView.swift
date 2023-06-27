//
//  CardImageView.swift
//  Meeting
//
//  Created by Деним Мержан on 27.06.23.
//

import Foundation
import UIKit

class CardImageView: DefaultLoadPhoto {

    var name = UILabel()
    var age = UILabel()
    var progressBar = [UIView]()

    init(name: String, age: String, countPhoto: Int) {
        self.name.text = name
        self.age.text = age
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - 236))
        self.addSubview(self.name)
        self.addSubview(self.age)
        createProgressBar(countPhoto: countPhoto)
    }

    override func setupView() {
        
        let point = CGPoint(x: 10, y: frame.height - 130)
        name.font = .boldSystemFont(ofSize: 40)
        name.frame = CGRect(origin: point, size: name.sizeThatFits(CGSize(width: CGFloat.infinity, height: 48))) /// Расширяем рамку в зависимости от размера текста
        name.textColor = .white
        
        age.frame = CGRect(x: name.frame.maxX + 10, y: frame.height - 130, width: 100, height: 48.0) /// Возраст, ставим по позиции x относительно имени
        age.font = .systemFont(ofSize: 40)
        age.textColor = .white
        
        let gradient = CAGradientLayer() ///  Градиент
        gradient.frame = CGRect(x: 0, y: frame.height - 203, width: frame.width, height: 203)
        gradient.locations = [0.0, 1.0]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
        
        super.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
//        print("Объект imageUserView уничтожен")
    }
}


//MARK: - Создание ProgressBar

extension CardImageView {
    
        func createProgressBar(countPhoto: Int) { /// Создаем кучу одинаковых View
            
            if countPhoto == 0 {return}
            
            let mostWidth = (self.frame.size.width - 5 - CGFloat(countPhoto * 7)) / CGFloat(countPhoto) /// Расчитываем длинну каждой полоски
            
            for i in 0...countPhoto - 1 {
                
                let newView = UIView()
                
                if i == 0 { /// Если первый элемент то задаем начальную позицию
                    newView.frame = CGRect(x: 5, y: 10, width: mostWidth, height: 4)
                    newView.backgroundColor = .white
                }else {
                    let xCoor = progressBar[i-1].frame.maxX /// Узнаем где кончилась предыдущая полоска
                    newView.frame = CGRect(x: xCoor + 7, y: 10, width: mostWidth, height: 4) /// Добавляем к ней 7 пунктов и создаем новую
                    newView.backgroundColor = .gray
                }
                
                newView.layer.cornerRadius = 2 /// Закругление
                newView.layer.masksToBounds = true /// Обрезание слоев по границам
                newView.alpha = 0.6
                progressBar.append(newView) /// Добавляем в архив полосок
                self.addSubview(newView)
            }
        }
}
