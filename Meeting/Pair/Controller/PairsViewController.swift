//
//  ViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit
import AudioToolbox
import Lottie


class PairsViewController: UIViewController {
    
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!

    lazy var stackViewButton = UIStackView()
    lazy var returnUserButton = createButton(image: UIImage(named: "ReturnUser"), buttonID: "ReturnUser")
    lazy var disLikeButton = createButton(image: UIImage(named: "DisLikeButton"), buttonID: "DisLike")
    lazy var superLikeButton = createButton(image: UIImage(named: "SuperLikeButton"), buttonID: "SuperLike")
    lazy var likeButton = createButton(image: UIImage(named: "LikeButton"), buttonID: "Like")
    lazy var boostButton = createButton(image: UIImage(named: "BoostButton"), buttonID: "Boost")
    
    var stopCard = false
    var center = CGPoint()
    var currentCard =  CardView(user: nil)
    var nextCard =  CardView(user: nil)
    
    var loadUserAnimation = LottieAnimationView(name: "40377-simple-map-pulse")
    var avatarPulse = UIImageView()
    var backViewAvatarPulse = UIView()
    var matchID = String()
    
    var basketUser = [User](){
        didSet {
            if basketUser.count > 10 {
                basketUser.removeFirst()
            }
        }
    }
    
    var usersArr =  [User]() {
        didSet {
            if usersArr.count < 5 && CurrentAuthUser.shared.potentialPairID.count > 0 && CurrentAuthUser.shared.newUsersLoading == false {
                print("Загрузка новых пользователей")
                Task {
                    await loadNewUsers(numberRequsetedUsers: 10)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        CurrentAuthUser.shared.ID = "2FoiV3dqXelseEy"
        
        Task {
            await CurrentAuthUser.shared.loadMetadata()
            super.viewDidLoad()
            animationSettings()
            await loadNewUsers(numberRequsetedUsers: 2)
            startSettings()
            setupStackView()
        }
        
    }
    
    //MARK: -  Одна из кнопок лайка была нажата
    
    @objc func buttonPressed(_ sender: UIButton) {
        
        var differenceX = CGFloat()
        var differenceY = CGFloat(-150)
        
        if sender.restorationIdentifier == "ReturnUser" {
            returnUser()
        }else if sender.restorationIdentifier == "Boost" {
            
        }else {
            let card = currentCard
            if sender.restorationIdentifier == "DisLike" {
                differenceX = -200
                CurrentAuthUser.shared.disLikeArr.append(currentCard.userID)
            }else if sender.restorationIdentifier == "SuperLike" {
                CurrentAuthUser.shared.superLikeArr.append(currentCard.userID)
                checkMatch(ID: currentCard.userID)
                differenceY = -600
            }else {
                CurrentAuthUser.shared.likeArr.append(currentCard.userID)
                checkMatch(ID: currentCard.userID)
                differenceX = 200
            }
            
            currentCard.changeHeart(xFromCenter: differenceX, yFromCenter: differenceY)
            UIView.animate(withDuration: 0.6, delay: 0) {
                
                card.center = CGPoint(x: card.center.x + differenceX , y: card.center.y + differenceY )
                card.transform = CGAffineTransform(rotationAngle: abs(differenceX) * 0.002)
                card.alpha = 0
            }
            loadNewPeople(card: self.currentCard)
        }
    }
    
    //MARK: - Пользователь тапнул по фото
    
    @IBAction func cardTap(_ sender: UITapGestureRecognizer) {
        let y = sender.location(in: currentCard).y
        if y > currentCard.frame.height * 0.7 {
            performSegue(withIdentifier: "GoToUserInfo", sender: self)
        }else {currentCard.refreshPhoto(sender)}
    }
}

//MARK: - Загрузка нового пользователя


extension PairsViewController {
    
    private func loadNewPeople(card:CardView){
        
        CurrentAuthUser.shared.refreshPairInfroOnServer()
        card.removeGestureRecognizer(tapGesture)
        
        currentCard = nextCard
        currentCard.delegate = self
        basketUser.append(usersArr[0])
        usersArr.removeFirst()
        
        if usersArr.count > 1 {
            let nextUser = usersArr[1]
            nextCard = CardView(user: nextUser)
        }else {
            nextCard = CardView(user: nil)
        }
        
        if usersArr.count == 0  {
            stackViewButton.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { /// Чем выше параметр тем выше шанс что карточка не удалиться и останется висеть в памяти надо подумать над этим
                card.removeFromSuperview()
            }
            return
        }
        
        currentCard.addGestureRecognizer(tapGesture)
        view.addSubview(nextCard)
        view.sendSubviewToBack(nextCard)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { /// Чем выше параметр тем выше шанс что карточка не удалиться и останется висеть в памяти надо подумать над этим
            card.removeFromSuperview()
        }
    }
    
    //MARK: - Возврат пользователя при выборе лайка и т.д
    
    private func returnUser(){
        
        guard let returnUser = basketUser.last else {return}
        basketUser.removeLast()
        usersArr.insert(returnUser, at: 0)
        
        let returnCard = CardView(user: returnUser)
        returnCard.alpha = 0
        returnCard.delegate = self
        if let index = CurrentAuthUser.shared.likeArr.firstIndex(where: {$0 == returnUser.ID }) {
            returnCard.center.x = view.frame.maxX + returnCard.frame.width / 2
            returnCard.center.y = view.center.y - 200
            returnCard.transform = CGAffineTransform(rotationAngle: 0.8)
            CurrentAuthUser.shared.likeArr.remove(at: index)
        }else if let index = CurrentAuthUser.shared.disLikeArr.firstIndex(where: {$0 == returnUser.ID }) {
            returnCard.center.x = view.frame.origin.x - returnCard.frame.width / 2
            returnCard.center.y = view.center.y - 200
            returnCard.transform = CGAffineTransform(rotationAngle: -0.8)
            CurrentAuthUser.shared.disLikeArr.remove(at: index)
        }else {
            returnCard.center.x = view.center.x
            returnCard.center.y = view.frame.origin.y - returnCard.frame.height / 2
            CurrentAuthUser.shared.superLikeArr.removeAll(where: {$0 == returnUser.ID })
        }
        
        CurrentAuthUser.shared.refreshPairInfroOnServer()
    
        self.view.addSubview(returnCard)
        self.view.bringSubviewToFront(stackViewButton)
        
        UIView.animate(withDuration: 0.6, delay: 0) {
            returnCard.center.x = self.view.center.x
            returnCard.center.y = self.view.center.y
            returnCard.transform = CGAffineTransform(rotationAngle: 0)
            returnCard.alpha = 1
        }
        
        nextCard.removeFromSuperview()
        nextCard = currentCard
        currentCard = returnCard
        currentCard.addGestureRecognizer(tapGesture)
        
    }
    
}

//MARK: -  Загрузка новых пользователей с сервера

extension PairsViewController {
    
    func loadNewUsers(numberRequsetedUsers: Int) async{
        CurrentAuthUser.shared.newUsersLoading = true
        
        for _ in 0...numberRequsetedUsers {
            
            if CurrentAuthUser.shared.potentialPairID.count == 0 {break}
            
            let newUser = User(ID: CurrentAuthUser.shared.potentialPairID[0],currentAuthUserID: CurrentAuthUser.shared.ID)
            await newUser.loadMetaData()
            usersArr.append(newUser)
            CurrentAuthUser.shared.potentialPairID.removeFirst()
        }

        CurrentAuthUser.shared.newUsersLoading = false
    }
}
//MARK: -  Действия при первом запуске

extension PairsViewController {
    
    func animationSettings(){
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("AvatarCurrentUser.jpeg")
        let avatarUser = UIImage(contentsOfFile: url.path)
        
        loadUserAnimation.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        loadUserAnimation.contentMode = .scaleAspectFit
        loadUserAnimation.loopMode = .loop
        loadUserAnimation.animationSpeed = 1.8
        loadUserAnimation.play()
        loadUserAnimation.backgroundColor = .clear
        loadUserAnimation.center = self.view.center
        view.addSubview(loadUserAnimation)
        
        avatarPulse = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        backViewAvatarPulse = UIView(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
        avatarPulse.center = self.view.center
        backViewAvatarPulse.center = avatarPulse.center
        backViewAvatarPulse.layer.cornerRadius = backViewAvatarPulse.frame.height / 2
        backViewAvatarPulse.layer.masksToBounds = true
        backViewAvatarPulse.backgroundColor = .white
        
        avatarPulse.contentMode = .scaleAspectFill
        avatarPulse.image = avatarUser
        avatarPulse.layer.cornerRadius = avatarPulse.frame.height / 2
        avatarPulse.layer.masksToBounds = true
       
        self.view.addSubview(backViewAvatarPulse)
        self.view.addSubview(avatarPulse)
        
    }
    
    func startSettings() {
        
            self.loadUserAnimation.stop()
            self.loadUserAnimation.removeFromSuperview()
            self.avatarPulse.removeFromSuperview()
            self.backViewAvatarPulse.removeFromSuperview()
            
            if self.usersArr.count > 0 {
                self.createStartCard()
            }else {
                self.view.addSubview(self.currentCard)
            }
    }
    
    private func createStartCard(){
        
        currentCard = CardView(user: usersArr[0])
        center = currentCard.center
        currentCard.addGestureRecognizer(tapGesture)
        currentCard.delegate = self
        
        if usersArr.count > 1 {
            nextCard = CardView(user: usersArr[1])
        }else {
            nextCard = CardView(user: nil)
        }
        
        view.addSubview(nextCard)
        view.addSubview(currentCard)
        stackViewButton.isHidden = false
    }
    
    //MARK: - Настройка кнопок
    
    private func createButton(image: UIImage?,buttonID:String) -> UIButton {
        
        let button = UIButton(type: .system)
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.restorationIdentifier = buttonID
        return button
    }
    
    private func setupStackView(){
        
        stackViewButton =  UIStackView(arrangedSubviews: [returnUserButton, disLikeButton,superLikeButton,likeButton,boostButton])
        stackViewButton.translatesAutoresizingMaskIntoConstraints = false
        stackViewButton.distribution = .fillEqually
        stackViewButton.spacing = 10
        
        view.addSubview(stackViewButton)
        
        stackViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -118).isActive = true
        stackViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16).isActive = true
        stackViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16).isActive = true
        stackViewButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
    }
}

//MARK:  - Когда случилось

extension PairsViewController  {
    
    func checkMatch(ID: String) {
        Task {
            let match = await CurrentAuthUser.shared.checkMatch(potetnialPairID: ID)
            if match {
                matchID = ID
                performSegue(withIdentifier: "goToMatch", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userUnfoVC = segue.destination as? UserInfoController {
            guard let selectedUser = usersArr.first(where: {$0.ID == currentCard.userID}) else {return}
            userUnfoVC.selectedUser = selectedUser
            userUnfoVC.delegate = self
        }
        guard let destanationVC = segue.destination as? MatchController else {return}
        guard let newMatch = basketUser.first(where: {$0.ID == matchID }) else {return}
        destanationVC.newMatch = newMatch
        destanationVC.delegate = self
    }
}
//MARK: - Переход с MATCH Сontroller с помощью делегата

extension PairsViewController: passDataDelegate {
    func goToMatchVC( matchController: UIViewController?,matchUser:User) {
        
        guard let vc = self.tabBarController?.viewControllers![1] as? ChatViewController else {return}
        guard let matchVC = matchController as? MatchController else {return}
        matchVC.delegate = vc
        matchVC.delegate?.goToMatchVC(matchController: nil, matchUser: matchUser)
        tabBarController?.selectedIndex = 1
    }
}

//MARK:  - Когда пользователь нажал одну из кнопок лайка в UserInfoController

extension PairsViewController: UserInfoControllerDelegate {
    func likeButtonsPressed(buttonID: String) {
        let card = currentCard
        if buttonID == "Like" {
            card.changeHeart(xFromCenter: 300, yFromCenter: 0)
            UIView.animate(withDuration: 0.6, delay: 0) {
                card.transform = CGAffineTransform(rotationAngle: abs(100) * 0.002)
                card.center = CGPoint(x: self.currentCard.center.x + 150 , y: self.currentCard.center.y - 150 )
                card.alpha = 0
            }
            CurrentAuthUser.shared.likeArr.append(currentCard.userID)}
        else if buttonID == "DisLike" {
            card.changeHeart(xFromCenter: -300, yFromCenter: 0)
            UIView.animate(withDuration: 0.6, delay: 0) {
                card.transform = CGAffineTransform(rotationAngle: abs(100) * 0.002)
                card.center = CGPoint(x: card.center.x - 150 , y: card.center.y + 100 )
                card.alpha = 0
            }
            CurrentAuthUser.shared.disLikeArr.append(currentCard.userID)}
        else {
            card.changeHeart(xFromCenter: 0, yFromCenter: -500)
            UIView.animate(withDuration: 0.6, delay: 0) {
                card.center = CGPoint(x: card.center.x , y: card.center.y - 600 )
                card.alpha = 0
            }
            CurrentAuthUser.shared.superLikeArr.append(currentCard.userID)}

        checkMatch(ID: currentCard.userID)
        loadNewPeople(card: currentCard)
        
    }
    
}

//MARK: -  Когда пользователь закончил перетаскивание

extension PairsViewController: CardViewDelegate {
    func swipeEndend(card: CardView) {
        checkMatch(ID: card.userID)
        loadNewPeople(card: card)
    }
}


