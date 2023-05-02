//
//  Extension.swift
//  Meeting
//
//  Created by Деним Мержан on 02.05.23.
//

import Foundation
import UIKit




 extension SettingsPhotoViewController {
    
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
