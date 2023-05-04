//
//  CreateButton.swift
//  Meeting
//
//  Created by Деним Мержан on 02.05.23.
//

import Foundation
import UIKit


struct CreateButton {
    
    
 //MARK: - Создание кнопок для PhotoSettingsController
    
    func createAddButtonPhotoSetings(x: CGFloat, y: CGFloat) -> UIButton { /// Кнопка добавления
        
        let button = createStandartPhotoSettingsButton(x: x, y: y)
        button.layer.shadowRadius = 10
        
        button.backgroundColor = UIColor(named: "MainAppColor")
        button.setImage(UIImage(named: "Plus"), for: .normal)
        button.tintColor = UIColor.white

        return button
    }
    
    func createDeleteButtonPhotoSetings(x: CGFloat, y: CGFloat ) -> UIButton { /// Кнопка удаления
        let button = createStandartPhotoSettingsButton(x: x, y: y)
        
        button.backgroundColor = .white
        button.setImage(UIImage(named: "DeletePhoto"), for: .normal)
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


//MARK: - Создание ProgressBar для SettingsPhotoController

extension CreateButton {
    
    func createProgressBarLoadPhoto() -> (progressBar : UIProgressView,backView: UIView, checkMark: UIImageView) {
        
        let backView = UIView(frame: CGRect(x: 20, y: 50, width: 350, height: 50))
        backView.backgroundColor = UIColor(named: "LoadPhotoColor")
        backView.layer.cornerRadius = 10
        
        let checkMarkImage = UIImageView(frame: CGRect(x: 290, y: 10, width: 50, height: 20))
        checkMarkImage.image = UIImage(systemName: "checkmark")
        checkMarkImage.contentMode = .scaleAspectFit
        checkMarkImage.tintColor = .white
        checkMarkImage.isHidden = true
        backView.addSubview(checkMarkImage)
        
        let label = UILabel(frame: CGRect(x: 25, y: 10, width: 100, height: 20))
        label.text = "Загрузка фото..."
        label.font = .systemFont(ofSize: 17)
        label.textColor = .white
        
        backView.addSubview(label)
        
        
        let progressBar = UIProgressView(frame: CGRect(x: 25, y: 35, width: 300, height: 30))
        backView.addSubview(progressBar)
        progressBar.progressViewStyle = .bar
        progressBar.progressTintColor = UIColor(named: "MainAppColor")
        progressBar.trackTintColor = .gray
        progressBar.setProgress(0.0, animated: false)
        
        return (progressBar,backView,checkMarkImage)
    }
    
}
