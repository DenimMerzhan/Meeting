//
//  ProfileViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 30.04.23.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var fillingScaleProfile: UILabel!
    
    var circularProgressBar = CircularProgressBarView(frame: .zero)
    
    
    override func viewDidAppear(_ animated: Bool) {
        changePhotoButton.titleLabel?.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSettings()
        
    }
}






//MARK: - Стартовые нстройки при запуске контроллера

extension ProfileViewController {
        
    func startSettings(){
        
        let changePhotoLayer = changePhotoButton.layer
        let filingScaleLayer = fillingScaleProfile.layer
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
        
        circularProgressBar.center = profilePhoto.center
        circularProgressBar.createCircularPath(radius: 98) /// Создаем прогресс бар
        circularProgressBar.progressAnimation(duration: 2,toValue: 0.5)
        view.addSubview(circularProgressBar)
        
        changePhotoLayer.cornerRadius = changePhotoButton.frame.size.width / 2 /// Делаем круглым наш карандаш
        changePhotoButton.clipsToBounds = true
        
        filingScaleLayer.cornerRadius = 15 /// Делаем закругленные края у шкалы заполнения профиля
        fillingScaleProfile.clipsToBounds = true /// Обрезаем до краев что бы тени не выходили за них
        
        changePhotoLayer.shadowColor = UIColor.black.cgColor /// Добавляем тень
        changePhotoLayer.shadowOffset = .zero
        changePhotoLayer.shadowOpacity = 1
        changePhotoLayer.shadowRadius = 10
        
        filingScaleLayer.shadowColor = UIColor.black.cgColor
        filingScaleLayer.shadowOffset = .zero
        filingScaleLayer.shadowOpacity = 1
        filingScaleLayer.shadowRadius = 10
        
        
        view.bringSubviewToFront(fillingScaleProfile)
        view.bringSubviewToFront(changePhotoButton)
    }
}
