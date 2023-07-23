//
//  ProfileViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 30.04.23.
//

import UIKit

class ProfileViewController: UIViewController {
    

    
    @IBOutlet weak var avatar: DefaultLoadPhoto!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var fillingScaleProfile: UILabel!
    
    @IBOutlet weak var mostStackView: UIView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    
    var circularProgressBar = CircularProgressBarView(frame: .zero)
    var profileProgress: Float {
        get {
            return Float(CurrentAuthUser.shared.imageArr.count) / 9
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CurrentAuthUser.shared.avatar?.image != nil {
            avatar.image = CurrentAuthUser.shared.avatar?.image
        }
        profileUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSettings()
    }
    
    
    @IBAction func settingsPhotoPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "settingsToPhotoSettings", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? SettingsPhotoViewController else {return}
    }
}



//MARK: - Стартовые нстройки при запуске контроллера

private extension ProfileViewController {
        
    func startSettings(){
        
        CurrentAuthUser.shared.avatar?.delegate = self
        avatar.image = CurrentAuthUser.shared.avatar?.image
        
        nameAgeLabel.text = CurrentAuthUser.shared.name + " " + String(CurrentAuthUser.shared.age)
        nameAgeLabel.lineBreakMode = .byWordWrapping
        nameAgeLabel.numberOfLines = 3
        
        
        
        let changePhotoLayer = changePhotoButton.layer
        let filingScaleLayer = fillingScaleProfile.layer
        
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.clipsToBounds = true
        
        circularProgressBar.createCircularPath(radius: avatar.frame.width / 2  + 8) /// Создаем прогресс бар
        circularProgressBar.progressAnimation(duration: 2,toValue: profileProgress)
        circularProgressBar.backgroundColor = .red
        mostStackView.addSubview(circularProgressBar)
        
        changePhotoButton.frame.size = CGSize(width: 50, height: 50)
        changePhotoLayer.cornerRadius = changePhotoButton.frame.size.width / 2 /// Делаем круглым наш карандаш
        changePhotoButton.clipsToBounds = true
        
        filingScaleLayer.cornerRadius = 12 /// Делаем закругленные края у шкалы заполнения профиля
        filingScaleLayer.masksToBounds = true
        fillingScaleProfile.clipsToBounds = true /// Обрезаем до краев что бы тени не выходили за них
        
        changePhotoLayer.shadowColor = UIColor.black.cgColor /// Добавляем тень
        changePhotoLayer.shadowOffset = .zero
        changePhotoLayer.shadowOpacity = 1
        changePhotoLayer.shadowRadius = 10
        
        filingScaleLayer.shadowColor = UIColor.black.cgColor
        filingScaleLayer.shadowOffset = .zero
        filingScaleLayer.shadowOpacity = 1
        filingScaleLayer.shadowRadius = 10
        
        mostStackView.bringSubviewToFront(fillingScaleProfile)
        mostStackView.bringSubviewToFront(changePhotoButton)
    }
    
//MARK: -  Обновление шкалы профиля
    
    func profileUpdate(){ /// Обновления шкалы заполненности профиля
        
        changePhotoButton.center.x = avatar.frame.maxX - 20
        changePhotoButton.center.y = avatar.frame.origin.y + 10
        
        circularProgressBar.center = avatar.center
        
        changePhotoButton.titleLabel?.text = ""
        
        var newStatus = profileProgress * 100
        if newStatus > 100 {newStatus = 100}
        fillingScaleProfile.text = String(format: "%.0f", newStatus)  + "% ЗАПОЛНЕНО"
        
        circularProgressBar.progressAnimation(duration: Double(profileProgress) * 8, toValue: profileProgress - 0.1)
    }
}

extension ProfileViewController: LoadPhoto {
    func userPhotoLoaded() {
        avatar.image = CurrentAuthUser.shared.avatar?.image
    }
}
