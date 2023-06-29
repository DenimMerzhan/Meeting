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
    
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var stackViewButton: UIStackView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var superLikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var stopCard = false
    var center = CGPoint()
    var currentCard =  CardView(imageArr: nil,emptyCard: true)
    var nextCard =  CardView(imageArr: nil,emptyCard: true)
    var currentAuthUser = CurrentAuthUser(ID: "+79817550000")
    var delegate: PassReferenceCurrentAuthUser?
    var a = SceneDelegate().currentAuthUser
    
    var loadUserAnimation = LottieAnimationView(name: "40377-simple-map-pulse")
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
            if usersArr.count < 5 && currentAuthUser.potentialPairID.count > 0 && currentAuthUser.newUsersLoading == false {
                print("Загрузка новых пользователей")
                Task {
                    await loadNewUsers(numberRequsetedUsers: 10)
                }
            }
        }
    }
    
    override func viewDidLoad() {
       
        
        Task {
            await currentAuthUser.loadMetadata()
            delegate?.referenceCurrentAuthUser(currentAuthUser: currentAuthUser)
            super.viewDidLoad()
            animationSettings()
            await loadNewUsers(numberRequsetedUsers: 15)
            startSettings()
        }
        
    }
    
    
    //MARK: -  Одна из кнопок лайка была нажата
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        var differenceX = CGFloat()
        var differenceY = CGFloat(-150)
        
        if sender.restorationIdentifier == "Cancel" {
            differenceX = -200
            currentAuthUser.disLikeArr.append(currentCard.ID)
        }else if sender.restorationIdentifier == "SuperLike" {
            currentAuthUser.superLikeArr.append(currentCard.ID)
            checkMatch(ID: currentCard.ID)
            differenceY = -600
        }else if sender.restorationIdentifier == "Like" {
            currentAuthUser.likeArr.append(currentCard.ID)
            checkMatch(ID: currentCard.ID)
            differenceX = 200
        }
        
        currentCard.changeHeart(xFromCenter: differenceX, yFromCenter: differenceY)
        UIView.animate(withDuration: 0.4, delay: 0) {
            
            self.currentCard.center = CGPoint(x: self.currentCard.center.x + differenceX , y: self.currentCard.center.y + differenceY )
            self.currentCard.transform = CGAffineTransform(rotationAngle: abs(differenceX) * 0.002)
            self.currentCard.alpha = 0
            self.loadNewPeople(card: self.currentCard)
            
        }
        
    }
    
    //MARK: - Пользователь тапнул по фото
    
    
    @IBAction func cardTap(_ sender: UITapGestureRecognizer) {
        currentCard.refreshPhoto(sender)
    }
    
    //MARK: -  Карта была нажата пальцем
    
    @IBAction func cardsDrags(_ sender: UIPanGestureRecognizer) {
        
        
        if let card = sender.view  as? CardView { /// Представление, к которому привязан распознаватель жестов.
            
            let point = sender.translation(in: card) /// Отклонение от начального положения по x и y  в зависимости от того куда перетащил палец пользователь
            
            let xFromCenter = card.center.x - view.center.x
            let yFromCenter = card.center.y - view.center.y
            
            card.changeHeart(xFromCenter: xFromCenter, yFromCenter: yFromCenter)
            card.center = CGPoint(x: view.center.x + point.x , y: view.center.y + point.y ) /// Перемящем View взависимости от движения пальца
            card.transform = CGAffineTransform(rotationAngle: abs(xFromCenter) * 0.002) /// Поворачиваем View, внутри  rotationAngle радианты а не градусы
            
            
            //MARK: -   Когда пользователь отпустил палец
            
            if sender.state == UIGestureRecognizer.State.ended { ///  Когда пользователь отпустил палец
                
                if xFromCenter > 120 { /// Если карта ушла за пределы 215 пунктов то лайкаем пользователя
                    
                    UIView.animate(withDuration: 0.2, delay: 0) {
                        card.center = CGPoint(x: card.center.x + 150 , y: card.center.y + 100 )
                        card.alpha = 0
                    }
                    currentAuthUser.likeArr.append(card.ID)
                    checkMatch(ID: card.ID)
                    loadNewPeople(card: card)
                    
                }else if abs(xFromCenter) > 120 { /// Дизлайк пользователя
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x - 150 , y: card.center.y + 100 )
                        card.alpha = 0
                    }
                    currentAuthUser.disLikeArr.append(card.ID)
                    loadNewPeople(card: card)
                }else if yFromCenter < -250 { /// Супер Лайк
                    
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x , y: card.center.y - 600 )
                        card.alpha = 0
                    }
                    currentAuthUser.superLikeArr.append(card.ID)
                    checkMatch(ID: card.ID)
                    loadNewPeople(card: card)
                }
                
                else { /// Если не ушла то возвращаем в центр
                    
                    UIView.animate(withDuration: 0.2, delay: 0) { /// Вызывает анимацию длительностью 0.3 секунды после анимации мы выставляем card view  на первоначальную позицию
                        card.center = self.center
                        card.transform = CGAffineTransform(rotationAngle: 0)
                        card.resetCard()
                    }
                }
            }
        }
    }
}

//MARK: - Загрузка нового пользователя


extension PairsViewController {
    
    func loadNewPeople(card:CardView){
        
        currentAuthUser.writingPairsInfrormation()
        card.removeGestureRecognizer(panGesture)
        card.removeGestureRecognizer(tapGesture)
        
        currentCard = nextCard
        basketUser.append(usersArr[0])
        usersArr.removeFirst()
        
        if usersArr.count > 1 {
            let nextUser = usersArr[1]
            nextCard = CardView(userID: nextUser.ID, name: nextUser.name, age: String(nextUser.age), imageArr: nextUser.imageArr)
        }else {
            nextCard = CardView(imageArr: nil,emptyCard: true)
        }
        
        if usersArr.count == 0  {
            stackViewButton.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { /// Чем выше параметр тем выше шанс что карточка не удалиться и останется висеть в памяти надо подумать над этим
                card.removeFromSuperview()
            }
            return
        }
        
        currentCard.addGestureRecognizer(panGesture)
        currentCard.addGestureRecognizer(tapGesture)
        view.addSubview(nextCard)
        view.sendSubviewToBack(nextCard)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { /// Чем выше параметр тем выше шанс что карточка не удалиться и останется висеть в памяти надо подумать над этим
            card.removeFromSuperview()
        }
    }
    
}

//MARK: -  Загрузка новых пользователей

extension PairsViewController {
    
    func loadNewUsers(numberRequsetedUsers: Int) async{
        currentAuthUser.newUsersLoading = true
        
        for _ in 0...numberRequsetedUsers {
            
            if currentAuthUser.potentialPairID.count == 0 {break}
            
            let newUser = User(ID: currentAuthUser.potentialPairID[0],currentAuthUserID: currentAuthUser.ID)
            await newUser.loadMetaData()
            usersArr.append(newUser)
            currentAuthUser.potentialPairID.removeFirst()
        }
        print(usersArr, "UserArr")
        currentAuthUser.newUsersLoading = false
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
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
        imageView.center = self.view.center
        backView.center = imageView.center
        backView.layer.cornerRadius = backView.frame.height / 2
        backView.layer.masksToBounds = true
        backView.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFill
        imageView.image = avatarUser
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.masksToBounds = true
       
        self.view.addSubview(backView)
        self.view.addSubview(imageView)
        
    }
    
    func startSettings(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.loadUserAnimation.stop()
            self.loadUserAnimation.removeFromSuperview()
            let dislikeImage = UIImage(named: "DisLikeButton")?.withRenderingMode(.alwaysOriginal)
            let likeImage = UIImage(named: "LikeButton")?.withRenderingMode(.alwaysOriginal)
            let superLikeImage = UIImage(named: "SuperLikeButton")?.withRenderingMode(.alwaysOriginal)
            self.cancelButton.setImage(dislikeImage, for: .normal)
            self.likeButton.setImage(likeImage, for: .normal)
            self.superLikeButton.setImage(superLikeImage, for: .normal)
            self.cancelButton.isEnabled = true
            self.likeButton.isEnabled = true
            self.superLikeButton.isEnabled = true
            
            if self.usersArr.count > 0 {
                self.createStartCard()
            }else {
                self.view.addSubview(self.currentCard)
            }
        }
    }
    
    func createStartCard(){
        
        let firstUser = usersArr[0]
        
        currentCard = CardView(userID: firstUser.ID, name: firstUser.name, age: String(firstUser.age), imageArr: firstUser.imageArr)
        center = currentCard.center
        print(currentCard.center)
        currentCard.addGestureRecognizer(panGesture)
        currentCard.addGestureRecognizer(tapGesture)
        
        if usersArr.count > 1 {
            let secondUser = usersArr[1]
            nextCard = CardView(userID: secondUser.ID, name: secondUser.name, age: String(secondUser.age), imageArr: secondUser.imageArr)
        }else {
            nextCard = CardView(imageArr: nil,emptyCard: true)
        }
        
        view.addSubview(nextCard)
        view.addSubview(currentCard)
        self.view.bringSubviewToFront(self.stackViewButton)
        stackViewButton.isHidden = false
    }
}



//MARK:  - Когда случилось

extension PairsViewController  {
    
    func checkMatch(ID: String) {
        Task {
            let match = await currentAuthUser.checkMatch(potetnialPairID: ID)
            if match {
                matchID = ID
                performSegue(withIdentifier: "goToMatch", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destanationVC = segue.destination as? MatchController else {return}
        guard let newMatch = basketUser.first(where: {$0.ID == matchID }) else {return}
        destanationVC.currentAuthUser = currentAuthUser
        destanationVC.newMatch = newMatch
        destanationVC.delegate = self
    }
}
//MARK: - Переход с MATCH Сontroller с помощью делегата

extension PairsViewController: passDataDelegate {
    func goToMatchVC( matchController: UIViewController?,matchUser:User,currentAuthUser:CurrentAuthUser) {
        
        guard let vc = self.tabBarController?.viewControllers![1] as? ChatViewController else {return}
        guard let matchVC = matchController as? MatchController else {return}
        matchVC.delegate = vc
        matchVC.delegate?.goToMatchVC(matchController: nil, matchUser: matchUser,currentAuthUser: currentAuthUser)
        tabBarController?.selectedIndex = 1
    }
}
