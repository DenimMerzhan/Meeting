//
//  CollectionPhotoCellCollectionViewCell.swift
//  Meeting
//
//  Created by Деним Мержан on 01.05.23.
//

import UIKit

protocol settingsPhotoChanged {
    func buttonChangePhotoPressed(index: Int)
}

class SettingsPhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoCell"
   
    var photoImage =  DefaultLoadPhoto(frame: .zero)
    var dottedBorder = CAShapeLayer()
    var addButton = UIButton()
    var deleteButton = UIButton()
    var customView = UIView(frame:.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        photoImage.layer.cornerRadius = 10
        photoImage.layer.masksToBounds = true
        photoImage.frame = CGRect(x: 0, y: 0, width: frame.width - 14, height: frame.height - 22)
        photoImage.loadIndicator.removeFromSuperview() /// Удаляем индикатор т.к он создался  по размерм .zero при инициализации
        photoImage.setupView() /// Создаем заново индикатор и начинаем анимацию
        photoImage.contentMode = .scaleAspectFill
        self.contentView.addSubview(photoImage)
        
        dottedBorder = createDottedLine()
        photoImage.layer.addSublayer(dottedBorder)
        
        addButton = createAddButtonPhotoSetings(x: photoImage.frame.maxX, y: photoImage.frame.maxY)
        deleteButton = createDeleteButtonPhotoSetings(x: photoImage.frame.maxX, y: photoImage.frame.maxY)
        self.addSubview(addButton)
        self.addSubview(deleteButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        photoImage.image = nil
    }
    
    
    
    
//MARK: -   Создание пунктирной линии
    
    private func createDottedLine() -> CAShapeLayer { /// Создание пунткирной границы
        
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = UIColor.gray.cgColor
        viewBorder.lineDashPattern = [10,4]  /// Штриховой узор, применяемый к контуру фигуры при обводке.
        viewBorder.frame = photoImage.bounds
        viewBorder.opacity = 0.4
        viewBorder.lineWidth = 5
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(rect: viewBorder.bounds).cgPath
        
        return viewBorder
        
    }

//MARK: -  Cоздание кнопок удаления и добавления
    
    private func createAddButtonPhotoSetings(x: CGFloat, y: CGFloat) -> UIButton { /// Кнопка добавления
        
        let button = createStandartPhotoSettingsButton(x: x, y: y)
        button.layer.shadowRadius = 10
        
        button.backgroundColor = UIColor(named: "MainAppColor")
        button.setImage(UIImage(named: "AddPhoto"), for: .normal)
        button.tintColor = UIColor.white

        return button
    }
    
    private func createDeleteButtonPhotoSetings(x: CGFloat, y: CGFloat ) -> UIButton { /// Кнопка удаления
        let button = createStandartPhotoSettingsButton(x: x, y: y)
        
        button.backgroundColor = .white
        button.setImage(UIImage(named: "DeletePhoto"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = UIColor.gray
        
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.gray.cgColor
        
        return button
    }
    
    private func createStandartPhotoSettingsButton(x: CGFloat, y: CGFloat) -> UIButton {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0,width: 30, height: 30))
        button.center = CGPoint(x: x - 5, y: y - 5)
        button.layer.cornerRadius = button.frame.size.width / 2
        button.layer.masksToBounds = true
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = .zero
        button.layer.opacity = 1
        button.layer.shadowRadius = 10
        
        return button
        
    }
    
}

