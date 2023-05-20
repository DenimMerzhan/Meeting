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
    
    @IBOutlet weak var nameAgeLabel: UILabel!
    
    var circularProgressBar = CircularProgressBarView(frame: .zero)
    var animateProgressToValue = Float(0)
    
    let defaults = UserDefaults.standard
    var navViewController = ViewController()
    
    var currentAuthUser =   CurrentAuthUser(ID: "") {
        didSet {
            if currentAuthUser.currentUserLoaded {
                nameAgeLabel.text = currentAuthUser.name + " " + String(currentAuthUser.age)
                if currentAuthUser.imageArr.count != 0 {
                    profilePhoto.image = currentAuthUser.imageArr[0].image
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profileUpdate()
        currentAuthUser = navViewController.currentAuthUser /// Каждый раз обновляем currentAuthUser что бы срабатывал блок DidSet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navViewController = tabBarController?.viewControllers?[0] as? ViewController { /// Передаем ссылку на главный ViewController
            self.navViewController = navViewController
        }

        startSettings(animateProgressToValue: animateProgressToValue)
    }
    
    
    @IBAction func settingsPhotoPressed(_ sender: UIButton) {
        
        if currentAuthUser.currentUserLoaded {
            print(currentAuthUser.imageArr.count, "imageArr Current User")
            performSegue(withIdentifier: "settingsToPhotoSettings", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "settingsToPhotoSettings" else {return}
        guard let destination = segue.destination as? SettingsPhotoViewController else {return}
        destination.currentAuthUser = currentAuthUser
        
    }
    
}



//MARK: - Стартовые нстройки при запуске контроллера

private extension ProfileViewController {
        
    func startSettings(animateProgressToValue: Float){
        
        view.bringSubviewToFront(nameAgeLabel) /// В Iphone 4 этот лейбл скрывается т.к не помещяеся в элемент MostView поэтому он всегда будет на переднем плане
        fillingScaleProfile.center.x = profilePhoto.center.x
        fillingScaleProfile.center.y = profilePhoto.frame.maxY - 5
        
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
    
//MARK: -  Обновление шкалы профиля
    
    func profileUpdate(){ /// Обновления шкалы заполненности профиля
        
        changePhotoButton.titleLabel?.text = ""
        
        let oldValue = animateProgressToValue
        animateProgressToValue = defaults.float(forKey: "ProfileFilingScale")
        
        if oldValue != animateProgressToValue { /// Если значения разные то обновляем шкалу заполненности
            
            circularProgressBar.progressAnimation(duration: Double(animateProgressToValue) * 5, toValue: animateProgressToValue - 0.1)
            
            var newStatus = animateProgressToValue * 100
            if newStatus > 100 {newStatus = 100}
            fillingScaleProfile.text = String(format: "%.0f", newStatus)  + "% ЗАПОЛНЕНО"
        }
    }
    
}
