//
//  CollectionPhotoCellCollectionViewCell.swift
//  Meeting
//
//  Created by Деним Мержан on 01.05.23.
//

import UIKit

class CollectionPhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoCell"
    var photoImage =  UIImageView()
    var dottedBorder = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(photoImage)
        
        dottedBorder = createDottedLine()
        contentView.layer.addSublayer(dottedBorder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImage.frame = contentView.bounds
        dottedBorder.frame = contentView.bounds
        
    }
    
    override func prepareForReuse() {
        photoImage.image = nil
    }
    
    
    func createDottedLine() -> CAShapeLayer { /// Создание пунткирной границы
        
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = UIColor.gray.cgColor
        viewBorder.lineDashPattern = [10,4]  /// Штриховой узор, применяемый к контуру фигуры при обводке.
        viewBorder.frame = bounds
        viewBorder.opacity = 0.4
        viewBorder.lineWidth = 5
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(rect: viewBorder.bounds).cgPath
        
        return viewBorder
        
    }
    
}

