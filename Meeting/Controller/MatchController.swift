//
//  MatchController.swift
//  Meeting
//
//  Created by Деним Мержан on 31.05.23.
//

import UIKit

class MatchController: UIViewController {

    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    @IBOutlet weak var textField: UITextField!
    var delegate: passDataDelegate?
    var currentAuthUser: CurrentAuthUser?
    var newMatch: User? {
        didSet {
            guard let user = newMatch else {return}
            
            let card = cardModel.createCard(newUser: user)
            card.addGestureRecognizer(tapGesture)
            card.nameUser.isHidden = true
            card.age.isHidden = true
            changePostionProgressBar(progressBar: card.progressBar, y: 50)
            
            view.addSubview(card)
            view.sendSubviewToBack(card)
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
