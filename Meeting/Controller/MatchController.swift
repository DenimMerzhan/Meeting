//
//  MatchController.swift
//  Meeting
//
//  Created by Деним Мержан on 31.05.23.
//

import UIKit

class MatchController: UIViewController {

    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    var delegate: passDataDelegate?
    
    var newMatch: User? {
        didSet {
            guard let user = newMatch else {return}
            print(user.imageArr.count)
            card = cardModel.createCard(newUser: user)
            card?.addGestureRecognizer(tapGesture)
            
            guard let imageUserView = card?.imageUserView as? ImageUserView else {return}
            imageUserView.nameUser.isHidden = true
            imageUserView.age.isHidden = true
            changePostionProgressBar(progressBar: imageUserView.progressBar, y: 50)
            
            view.addSubview(card!)
            view.sendSubviewToBack(card!)
        }
    }
    
    let cardModel = CardModel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    var card: CardView?
    
    var indexCurrentImage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapCard(_ sender: UITapGestureRecognizer) {
        guard let currentCard = card else {return}
        if let index =  currentCard.refreshPhoto(sender, indexCurrentImage: indexCurrentImage) {
            indexCurrentImage = index
        }
    }
    

    
    @IBAction func backToSwipe(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        guard let user = newMatch else {return}
        delegate?.goToMatchVC(matchController: self,matchUser: user)
    }
    
    func changePostionProgressBar(progressBar:[UIView],y: CGFloat){
        for view in progressBar {
            view.frame.origin.y = y
        }
    }
    deinit {
        print("MatchController уничтожен")
    }
}
