//
//  ProfileViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 30.04.23.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePhoto: UIImageView!
    var circularProgressBar = CircularProgressBarView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(profilePhoto.frame)
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
        setUpCircularProgressBarView()
        
       
    }
    

    func setUpCircularProgressBarView(){
        circularProgressBar.center = profilePhoto.center
        circularProgressBar.createCircularPath(radius: 98)
        circularProgressBar.progressAnimation(duration: 2,toValue: 0.5)
        view.addSubview(circularProgressBar)
    }
}
