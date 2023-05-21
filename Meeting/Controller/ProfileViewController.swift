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
    
    @IBOutlet weak var mostStackView: UIView!
    
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
                    print("Wow")
                }
                animateProgressToValue = Float(currentAuthUser.imageArr.count) / 9
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        
        profileUpdate()
        print(profilePhoto.frame, "PhotoFrame")
        
        currentAuthUser = navViewController.currentAuthUser /// Каждый раз обновляем currentAuthUser что бы срабатывал блок DidSet
        print(circularProgressBar.center, "CurculatCenter")
        print(circularProgressBar.frame, "FrameCurcular")
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
        
        fillingScaleProfile.frame.origin.x = profilePhoto.frame.origin.x
        fillingScaleProfile.frame.origin.y = profilePhoto.frame.maxY - 7
        
        let changePhotoLayer = changePhotoButton.layer
        let filingScaleLayer = fillingScaleProfile.layer
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
        
        circularProgressBar.createCircularPath(radius: profilePhoto.frame.width / 2  + 8) /// Создаем прогресс бар
        circularProgressBar.progressAnimation(duration: 2,toValue: animateProgressToValue)
        circularProgressBar.backgroundColor = .red
        mostStackView.addSubview(circularProgressBar)
        
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
        
        fillingScaleProfile.frame.origin.x = profilePhoto.frame.origin.x /// Делаем шкалу профиля ровно под фото профиля
        fillingScaleProfile.frame.origin.y = profilePhoto.frame.maxY - 7
        
        changePhotoButton.center.x = profilePhoto.frame.maxX - 25
        changePhotoButton.center.y = profilePhoto.frame.origin.y + 15
        
        circularProgressBar.center = profilePhoto.center
        
        changePhotoButton.titleLabel?.text = ""
        
        var newStatus = animateProgressToValue * 100
        if newStatus > 100 {newStatus = 100}
        fillingScaleProfile.text = String(format: "%.0f", newStatus)  + "% ЗАПОЛНЕНО"
        
        circularProgressBar.progressAnimation(duration: Double(animateProgressToValue) * 5, toValue: animateProgressToValue - 0.1)
            
            
        
    }
    
}
