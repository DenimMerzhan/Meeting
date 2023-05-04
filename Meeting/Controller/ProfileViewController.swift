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
    var animateProgressToValue = Float(0)
    
    override func viewDidAppear(_ animated: Bool) {
        changePhotoButton.titleLabel?.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSettings(animateProgressToValue: animateProgressToValue)
        
    }
    
    
    @IBAction func settingsPhotoPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "settingsToPhotoSettings", sender: self)
    }
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue){
        
        guard let source = sender.source as? SettingsPhotoViewController else { return }
        animateProgressToValue = source.animateProgressToValue
        print(animateProgressToValue)
        circularProgressBar.progressAnimation(duration: Double(animateProgressToValue) * 5, toValue: animateProgressToValue)
    }
    
}






//MARK: - Стартовые нстройки при запуске контроллера

extension ProfileViewController {
        
    func startSettings(animateProgressToValue: Float){
        
        let changePhotoLayer = changePhotoButton.layer
        let filingScaleLayer = fillingScaleProfile.layer
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
        
        circularProgressBar.center = profilePhoto.center
        circularProgressBar.createCircularPath(radius: 98) /// Создаем прогресс бар
        circularProgressBar.progressAnimation(duration: 2,toValue: animateProgressToValue)
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
