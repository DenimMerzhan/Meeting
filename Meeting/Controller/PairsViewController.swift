//
//  ViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit
import AudioToolbox

class PairsViewController: UIViewController {
    
    
    
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var stackViewButton: UIStackView!
    
    var indexCurrentImage = 0
    
    var stopCard = false
    var center = CGPoint()
    
    var currentCard: CardView?
    var nextCard = CardModel().createEmptyCard()
        
    var cardModel = CardModel()
    var currentAuthUser = CurrentAuthUser(ID:"+79817550000")
    
    var progressViewLoadUsers = CreateButton().createProgressLoadUsersStartForLaunch(width: 0)
    var timer = Timer()
    
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
            
//            print("usersArr.count - \(usersArr.count)")
            
            if usersArr.count < 50 && currentAuthUser.numberPotenialPairsOnServer > 0 && currentAuthUser.newUsersLoading == false {
                print("Загрузка новых пользователей")
                Task {
                    await loadNewUsers(numberRequsetedUsers: 15)
                }
                
            }
            if currentCard?.ID == "Loading_Card" && usersArr.count > 3 {
               
                currentCard?.removeFromSuperview()
                nextCard.removeFromSuperview()
                createStartCard()
            }else if currentCard?.ID == "Loading_Card" && usersArr.count > 0 && currentAuthUser.newUsersLoading == false {
               
                currentCard?.removeFromSuperview()
                nextCard.removeFromSuperview()
                createStartCard()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.fireTimer()
        }
        
        
        progressViewLoadUsers.backView.center = view.center
        progressViewLoadUsers.label = CreateButton().createProgressLoadUsersStartForLaunch(width: view.frame.width - 40).label
        progressViewLoadUsers.label.center = CGPoint(x: view.center.x, y: view.center.y - 70)
        view.addSubview(progressViewLoadUsers.backView)
        view.addSubview(progressViewLoadUsers.label)
        
        
        Task {
            
            if await loadCurrentUsersData() {
//                await loadNewUsers(numberRequsetedUsers: 1)
                startSettings()
            }else{
                print("Ошибка загрузки текущего пользователя")
            }
        }

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
//MARK: -  Одна из кнопок лайка была нажата
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        var differenceX = CGFloat()
        var differenceY = CGFloat(-150)
        guard let userID = currentCard?.ID else {return}
        
        if sender.restorationIdentifier == "Cancel" {
            differenceX = -200
            currentAuthUser.disLikeArr.append(userID)
        }else if sender.restorationIdentifier == "SuperLike" {
            currentAuthUser.superLikeArr.append(userID)
            checkMatch(ID: userID)
            differenceY = -600
        }else if sender.restorationIdentifier == "Like" {
            currentAuthUser.likeArr.append(userID)
            checkMatch(ID: userID)
            differenceX = 200
        }
        
        currentCard?.changeHeart(xFromCenter: differenceX, yFromCenter: differenceY)
        UIView.animate(withDuration: 0.4, delay: 0) {
            
            self.currentCard!.center = CGPoint(x: self.currentCard!.center.x + differenceX , y: self.currentCard!.center.y + differenceY )
            self.currentCard!.transform = CGAffineTransform(rotationAngle: abs(differenceX) * 0.002)
            self.currentCard!.alpha = 0
            self.loadNewPeople(card: self.currentCard!)
           
        }
        
    }
    
//MARK: - Пользователь тапнул по фото
    
    
    @IBAction func cardTap(_ sender: UITapGestureRecognizer) {
        if let index =  currentCard!.refreshPhoto(sender, indexCurrentImage: indexCurrentImage) {
            indexCurrentImage = index
        }
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
                        self.currentAuthUser.likeArr.append(card.ID)
                        self.checkMatch(ID: card.ID)
                        self.loadNewPeople(card: card)
                        
                    }
                    
                }else if abs(xFromCenter) > 120 { /// Дизлайк пользователя
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x - 150 , y: card.center.y + 100 )
                        card.alpha = 0
                        self.currentAuthUser.disLikeArr.append(card.ID)
                        self.loadNewPeople(card: card)
                       
                    }
                }else if yFromCenter < -250 { /// Супер Лайк
                    
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x , y: card.center.y - 600 )
                        card.alpha = 0
                        self.currentAuthUser.superLikeArr.append(card.ID)
                        self.checkMatch(ID: card.ID)
                        self.loadNewPeople(card: card)
                    }
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
        
        if usersArr.count > 0 {
            basketUser.append(usersArr[0])
            usersArr[0].cleanPhotoUser() /// Удаляем папку с фото с  директории пользователя
            usersArr.removeFirst()
        }
        nextCard = createNextCard()
        
        currentCard!.addGestureRecognizer(panGesture)
        currentCard!.addGestureRecognizer(tapGesture)
        
        view.addSubview(nextCard)
        view.sendSubviewToBack(nextCard)
        
        
        indexCurrentImage = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { /// Чем выше параметр тем выше шанс что карточка не удалиться и останется висеть в памяти надо подумать над этим
            card.removeFromSuperview()
        }
        
        if currentCard?.ID == "Stop_Card"  {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                card.removeFromSuperview()
            }
            currentCard?.removeGestureRecognizer(panGesture)
            currentCard?.removeGestureRecognizer(tapGesture)
            stackViewButton.isHidden = true
        }
    }
    
}
//MARK: - Создание нового CardView


extension PairsViewController {
    
    func createNextCard() -> CardView {
        
        if usersArr.count > 1 {
            return  cardModel.createCard(newUser: usersArr[1])
        }
        else if usersArr.count < 2 && currentAuthUser.newUsersLoading {
            return  cardModel.createLoadingUsersCard()
        }
        else if usersArr.count < 2 && currentAuthUser.numberPotenialPairsOnServer == 0 {
            return cardModel.createEmptyCard()
        }
        else {
            return cardModel.createEmptyCard()
        }
    }
    
}

//MARK: -  Загрузка новых пользователей

extension PairsViewController {
    
    func loadNewUsers(numberRequsetedUsers: Int) async{
        
        currentAuthUser.newUsersLoading = true
                
        if let newUsersID = await currentAuthUser.loadNewPotenialPairs(countUser: numberRequsetedUsers,usersArr: usersArr) {
            
            for ID in newUsersID {
                
                var newUser = User(ID: ID)
                await newUser.loadMetaData()

                if let urlFilesArr = await FirebaseStorageModel().loadPhotoToFile(urlPhotoArr: newUser.urlPhotoArr, userID: ID,currentUser: false) {
                    newUser.loadPhotoFromDirectory(urlFileArr: urlFilesArr)
                    if ID == newUsersID.last {
                        currentAuthUser.newUsersLoading = false
                    }
                    usersArr.append(newUser)
                    progressViewLoadUsers.progressBar.progress += 0.05
            }
        }
            currentAuthUser.newUsersLoading = false
    }
}
//MARK: -  Загрузка данных о текущем авторизованном пользователе
    
    func loadCurrentUsersData() async -> Bool {
        
        if await currentAuthUser.loadMetadata() {
            
            if let urlArrFiles = await FirebaseStorageModel().loadPhotoToFile(urlPhotoArr: currentAuthUser.urlPhotoArr, userID: currentAuthUser.ID,currentUser: true) {
                currentAuthUser.loadPhotoFromDirectory(urlFileArr: urlArrFiles)
            }
            print("количество фото текущего пользователя ", currentAuthUser.imageArr.count)
            return true
        }else {
            return false
        }
    }
}
//MARK: -  Дополнительные расширения

extension PairsViewController {
    
    func startSettings(){
        
        timer.invalidate()
        progressViewLoadUsers.progressBar.setProgress(1, animated: true)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.progressViewLoadUsers.progressBar.removeFromSuperview()
            self.progressViewLoadUsers.label.removeFromSuperview()
            self.progressViewLoadUsers.backView.removeFromSuperview()
            
            self.tabBarController?.tabBar.barTintColor = .white
            self.tabBarController?.tabBar.clipsToBounds = true
            self.tabBarController?.tabBar.backgroundColor = .white
            self.tabBarController?.tabBar.isHidden = false
    
            if self.usersArr.count > 0 {
                self.createStartCard()
            }else {
                self.currentCard = self.cardModel.createEmptyCard()
                self.view.addSubview(self.currentCard!)
            }
        }
    }
    
    func createStartCard(){
        
        currentCard = cardModel.createCard(newUser: usersArr[0])
        center = currentCard!.center
        currentCard!.addGestureRecognizer(self.panGesture)
        currentCard!.addGestureRecognizer(self.tapGesture)
        
        nextCard = createNextCard()
        view.addSubview(nextCard)
        self.view.addSubview(self.currentCard!)
        self.view.bringSubviewToFront(self.stackViewButton)
        
        stackViewButton.isHidden = false
    }
 
    func fireTimer(){
        
        progressViewLoadUsers.progressBar.progress += 0.005
        let progress = progressViewLoadUsers.progressBar.progress
        let randomFloat = Float.random(in: 0...0.025)
        
        UIView.animate(withDuration: 0.8, delay: 0) { [unowned self] in
            self.progressViewLoadUsers.progressBar.setProgress(progress + randomFloat, animated: true)
        }
    }
}



//MARK:  - Когда слуичилось

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
        currentAuthUser.matchArr.append(newMatch)
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
