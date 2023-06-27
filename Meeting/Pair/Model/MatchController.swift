//
//  MatchController.swift
//  Meeting
//
//  Created by Деним Мержан on 31.05.23.
//

import UIKit

protocol passDataDelegate {
    
    func goToMatchVC(matchController:UIViewController?,matchUser: User, currentAuthUser:CurrentAuthUser)
    
}

class MatchController: UIViewController {

    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    @IBOutlet weak var textField: UITextField!
    var delegate: passDataDelegate?
    var currentAuthUser: CurrentAuthUser?
    var newMatch: User? {
        didSet {
            guard let user = newMatch else {return}
            let card = CardView(userID: user.ID, name: user.name, age: String(user.age), imageArr: user.imageArr)
            card.addGestureRecognizer(tapGesture)
            card.name.isHidden = true
            card.age.isHidden = true
            changePostionProgressBar(progressBar: card.progressBar, y: 50)
            view.addSubview(card)
            view.sendSubviewToBack(card)
        }
    }
    
    let cardModel = CardModel()
    
    var card: CardView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapCard(_ sender: UITapGestureRecognizer) {
        guard let currentCard = card else {return}
        currentCard.refreshPhoto(sender)
    }
    

    
    @IBAction func backToSwipe(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        guard let newMatch = self.newMatch else {return}
        guard let authUser = currentAuthUser else {return}
        if authUser.matchArr.contains(where: {$0.ID == newMatch.ID }) == false {return} /// Проверяем добавился ли пользаватель в MatchArr
        
        guard let body = textField.text else {return}
        if textField.text?.count == 0 {return}
        textField.text = ""
        authUser.sendMessageToServer(user: newMatch, body: body) /// Отправляем первое сообщение
        
        self.dismiss(animated: false, completion: nil)
        delegate?.goToMatchVC(matchController: self,matchUser: newMatch,currentAuthUser: authUser)
    }
    
    func changePostionProgressBar(progressBar:[UIView],y: CGFloat){
        for view in progressBar {
            view.frame.origin.y = y
        }
    }
}
