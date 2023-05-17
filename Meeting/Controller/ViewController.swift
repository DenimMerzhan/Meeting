//
//  ViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 16.04.23.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var stackViewButton: UIStackView!
    
    var indexCurrentImage = 0
    
    var stopCard = false
    var center = CGPoint()
    
  
    var currentCard: CardView?
    var nextCard: CardView?
    
    var cardModel = CardModel()
    var currentAuthUser = CurrentAuthUser(ID: "+79817550000")
    
    var progressViewLoadUsers = CreateButton().createProgressLoadUsersStartForLaunch()
    
    var timer = Timer()
    
    var usersArr =  [User]() {
        didSet {
            
            if usersArr.count < 50 && currentAuthUser.numberPotenialPairsOnServer > 1 && currentAuthUser.newUsersLoading == false {
                print("Загрузка новых пользователей")
                Task {
                    await loadNewUsers(numberRequsetedUsers: 15)
                }
                
            }else if usersArr.count == 0 && currentAuthUser.numberPotenialPairsOnServer == 0 {
                print("Пользователи закончились")
                currentAuthUser.writingPairsInfrormation()}
            
            if currentCard?.ID == "Loading_Card" && usersArr.count > 3{
                currentCard?.removeFromSuperview()
                createStartCard()
            }
            
            if currentCard?.ID == "Loading_Card" && currentAuthUser.numberPotenialPairsOnServer == 0 {
                currentCard?.removeFromSuperview()
                createStartCard()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        cardModel.width = view.frame.width - 32
        cardModel.height = view.frame.height - 236
        
        tabBarController?.tabBar.isHidden = true
        stackViewButton.isHidden = true
    
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.fireTimer()
        }
        
        view.addSubview(progressViewLoadUsers.backView)
        progressViewLoadUsers.backView.center = view.center
        
        Task {
            
            if await loadCurrentUsersData() {
                await loadNewUsers(numberRequsetedUsers: 1)
                startSettings()
            }else{
                print("Ошибка загрузки текущего пользователя")
            }
        }

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
            differenceY = -600
        }else if sender.restorationIdentifier == "Like" {
            currentAuthUser.likeArr.append(userID)
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

        
        let coordinates = sender.location(in: currentCard!).x
        let currentImage = currentCard!.imageUserView as! imageUserView
        let imageArr = currentCard!.imageArr!

        if coordinates > 220 && indexCurrentImage < imageArr.count - 1 {
            indexCurrentImage += 1
            currentImage.progressBar[indexCurrentImage-1].backgroundColor = .gray
        }else if  coordinates < 180 && indexCurrentImage > 0  {
            indexCurrentImage -= 1
            currentImage.progressBar[indexCurrentImage+1].backgroundColor = .gray
        }else if indexCurrentImage == 0 || indexCurrentImage == imageArr.count - 1 {
            currentCard?.backgroundColor = .white
            cardModel.createAnimate(indexImage: indexCurrentImage, currentCard: currentCard!)
           
        }
        
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(1161)) { /// Cоздаем звук при Тапе
        }
        
        currentImage.progressBar[indexCurrentImage].backgroundColor = .white
        currentImage.image = imageArr[indexCurrentImage]
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


extension ViewController {
    
    func loadNewPeople(card:CardView){
        
        if usersArr.count > 0 {
            if let ID = currentAuthUser.potentialPairs.firstIndex(where: { $0 == card.ID}) {
                usersArr[ID].cleanPhotoUser()
                usersArr.remove(at: ID)
                currentAuthUser.potentialPairs.remove(at: ID)
            }
        }
        currentAuthUser.writingPairsInfrormation()
        
        card.removeGestureRecognizer(panGesture)
        card.removeGestureRecognizer(tapGesture)
        currentCard = nextCard
        
        if currentCard?.ID != "Loading_Card" && currentCard?.ID != "Stop_Card" {
            currentCard!.addGestureRecognizer(panGesture)
            currentCard!.addGestureRecognizer(tapGesture)
            nextCard = createCard(currentUserIDCard: currentCard!.ID)
            view.addSubview(nextCard!)
            view.sendSubviewToBack(nextCard!)
        }
        
        indexCurrentImage = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { /// Чем выше параметр тем выше шанс что карточка не удалиться и останется висеть в памяти надо подумать над этим
            card.removeFromSuperview()
        }
        
        if currentCard?.ID == "Stop_Card"  {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                card.removeFromSuperview()
            }
            stackViewButton.isHidden = true
        }
    }
    
}


//MARK: - Создание нового CardView


extension ViewController {
    
    
    func createDataCard(currentUserIDCard: String?) -> User? {
        
        if  usersArr.count > 1 {
            var newUser = usersArr.randomElement()
            if let currentUserID = currentUserIDCard {
                newUser = randomUserFromArray(currentUserID: currentUserID)
            }
            return (newUser)
        }else {
            return nil
        }
        
    }
    
    func createCard(currentUserIDCard:String?) -> CardView {
        
        if let newUser = createDataCard(currentUserIDCard: currentUserIDCard) {
            
            let card = cardModel.createCard(newUser: newUser)
            center = card.center
            print("User ID Card - ", card.ID)
            return card
            
        }else if currentAuthUser.newUsersLoading {
            let card = cardModel.createLoadingUsersCard()
            print("User ID Card - ", card.ID)
            return card
            
        }else{
            stopCard = true
            let card = cardModel.createEmptyCard()
            return card
        }
    }
}


//MARK: -  Загрузка новых пользователей

extension ViewController {
    
    func loadNewUsers(numberRequsetedUsers: Int) async{
        
        currentAuthUser.newUsersLoading = true
        
        if let newUsersID = await currentAuthUser.loadNewPotenialPairs(countUser: numberRequsetedUsers) {
            
            for ID in newUsersID {
                
                var newUser = User(ID: ID)
                await newUser.loadMetaData()

                if let urlFilesArr = await FirebaseStorageModel().loadPhotoToFile(urlPhotoArr: newUser.urlPhotoArr, userID: ID,currentUser: false) {
                    newUser.loadPhotoFromDirectory(urlFileArr: urlFilesArr)
                    if ID == newUsersID.last {
                        currentAuthUser.newUsersLoading = false
                    }
                    usersArr.append(newUser)
                    currentAuthUser.potentialPairs.append(ID)
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

extension ViewController {
    
    func startSettings(){
        
        timer.invalidate()
        progressViewLoadUsers.progressBar.setProgress(1, animated: true)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.progressViewLoadUsers.progressBar.removeFromSuperview()
            self.progressViewLoadUsers.backView.removeFromSuperview()
            
            self.tabBarController?.tabBar.barTintColor = .white
            self.tabBarController?.tabBar.clipsToBounds = true
            self.tabBarController?.tabBar.backgroundColor = .white
            self.tabBarController?.tabBar.isHidden = false
    
            self.createStartCard()
        }
    }
    
    func createStartCard(){
        
        currentCard = self.createCard(currentUserIDCard: nil)
        nextCard = self.createCard(currentUserIDCard: self.currentCard!.ID)
        stackViewButton.isHidden = false
        
        if currentCard?.ID != "Stop_Card" {
            self.currentCard!.addGestureRecognizer(self.panGesture)
            self.currentCard!.addGestureRecognizer(self.tapGesture)
            self.view.addSubview(self.nextCard!)
        }
        self.view.addSubview(self.currentCard!)
        self.view.bringSubviewToFront(self.stackViewButton)
        
    }
    
    func randomUserFromArray(currentUserID:String) -> User? {
        
        var newUser = usersArr.randomElement()
        
        if currentUserID == newUser?.ID {
            newUser = randomUserFromArray(currentUserID: currentUserID)
        }
        return newUser
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


