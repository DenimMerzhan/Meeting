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
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var preferencesButton: UIButton!
    
    var indexCurrentImage = 0
    
    var stopCard = false
    var center = CGPoint()
    
    var oddCard: CardView?
    var honestCard: CardView?
    var currentCard: CardView?
    
    var cardModel = CardModel()
    var currentAuthUser = CurrentAuthUser(ID: "+79817550000")
    
    var progressViewLoadUsers = CreateButton().createProgressLoadUsersStartForLaunch()
    
    var timer = Timer()
    
    var usersIDArr:  [String] {
        get{
            var newArr = [String]()
            for user in usersArr {
                newArr.append(user.ID)
            }
            return newArr
        }set{
            
        }
    }
    
    var usersArr =  [User]() {
        didSet {
            
            print("Количество пользователей в архиве - \(usersIDArr.count)")
            
            if usersArr.count < 15 && currentAuthUser.couplesOver == false {
                
                print("Загрузка новых пользователей")
                currentAuthUser.writingPairsInfrormation()
                Task {
                
                    await loadNewUsers(numberRequsetedUsers: 15,nonSwipedUsers: usersIDArr)
                }
                
            }else if usersArr.count == 0 {
                print("Пользователи закончились")
                currentAuthUser.writingPairsInfrormation()}
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        buttonStackView.isHidden = true

        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.fireTimer()
        }
        
        view.addSubview(progressViewLoadUsers.backView)
        progressViewLoadUsers.backView.center = view.center
        
        Task {
            
            if await loadCurrentUsersData() {
                await loadNewUsers(numberRequsetedUsers: 15)
                startSettings()
            }else{
                print("Ошибка загрузки текущего пользователя")
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        preferencesButton.titleLabel?.isHidden = true
    }
    
    
    
//MARK: -  Одна из кнопок лайка была нажата
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        var differenceX = CGFloat()
        var differenceY = CGFloat(-150)
        guard let userID = currentCard?.userID else {return}
        
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
        
        changeHeart(xFromCenter: differenceX, currentCard: currentCard!, yFromCenter: differenceY)
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
        
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(1161)) {
            
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
            
            changeHeart(xFromCenter: xFromCenter, currentCard: card,yFromCenter: yFromCenter)
            
            
            card.center = CGPoint(x: view.center.x + point.x , y: view.center.y + point.y ) /// Перемящем View взависимости от движения пальца
            card.transform = CGAffineTransform(rotationAngle: abs(xFromCenter) * 0.002) /// Поворачиваем View, внутри  rotationAngle радианты а не градусы
            
   
         
    
            
            
//MARK: -   Когда пользователь отпустил палец
            
            
            if sender.state == UIGestureRecognizer.State.ended { ///  Когда пользователь отпустил палец
                
                if xFromCenter > 120 { /// Если карта ушла за пределы 215 пунктов то лайкаем пользователя
                    
                    UIView.animate(withDuration: 0.2, delay: 0) {
                        card.center = CGPoint(x: card.center.x + 150 , y: card.center.y + 100 )
                        card.alpha = 0
                        self.currentAuthUser.likeArr.append(card.userID)
                        self.loadNewPeople(card: card)
                        
                    }
                    
                }else if abs(xFromCenter) > 120 { /// Дизлайк пользователя
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x - 150 , y: card.center.y + 100 )
                        card.alpha = 0
                        self.currentAuthUser.disLikeArr.append(card.userID)
                        self.loadNewPeople(card: card)
                       
                    }
                }else if yFromCenter < -250 { /// Супер Лайк
                    
                    UIView.animate(withDuration: 0.22, delay: 0) {
                        card.center = CGPoint(x: card.center.x , y: card.center.y - 600 )
                        card.alpha = 0
                        self.currentAuthUser.superLikeArr.append(card.userID)
                        self.loadNewPeople(card: card)
                      
                    }
                }
                
                else { /// Если не ушла то возвращаем в центр
                    
                    UIView.animate(withDuration: 0.2, delay: 0) { /// Вызывает анимацию длительностью 0.3 секунды после анимации мы выставляем card view  на первоначальную позицию
                        
                        card.center = self.center
                        card.transform = CGAffineTransform(rotationAngle: 0)
                        card.likHeartImage.isHidden = true
                        card.dislikeHeartImage.isHidden = true
                        card.superLike.isHidden = true
                        
                    }
                }
            }
        }
    }
    
    
}



//MARK: - Загрузка нового пользователя


extension ViewController {
    
    func loadNewPeople(card:CardView){
        
        if usersArr.count != 0 {
            if let i = usersIDArr.firstIndex(where: { $0 == card.userID}) {
                usersArr[i].cleanPhotoUser()
                usersArr.remove(at: i)
            }
        }
        
        if stopCard == false {
            
            card.removeGestureRecognizer(panGesture)
            card.removeGestureRecognizer(tapGesture)
            
            if card == honestCard {
                
                oddCard!.addGestureRecognizer(panGesture)
                oddCard!.addGestureRecognizer(tapGesture)
                honestCard = createCard(currentUserIDCard: oddCard?.userID)
                currentCard = oddCard!
               
                view.addSubview(honestCard!)
                view.sendSubviewToBack(honestCard!)
                
                
            }else {
                
                honestCard!.addGestureRecognizer(panGesture)
                honestCard!.addGestureRecognizer(tapGesture)
                oddCard = createCard(currentUserIDCard: honestCard?.userID)
                currentCard = honestCard!
               
                view.addSubview(oddCard!)
                view.sendSubviewToBack(oddCard!)
                
                
            }
            
            indexCurrentImage = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { /// Чем выше параметр тем выше шанс что карточка не удалиться и останется висеть в памяти надо подумать над этим
                card.removeFromSuperview()
            }
        }
        
        else {
            card.removeFromSuperview()
            buttonStackView.isHidden = true
        }
    }
    
}


    
//MARK: - Логика сердец


extension ViewController {
    
    func changeHeart(xFromCenter:CGFloat,currentCard: CardView,yFromCenter:CGFloat){ /// Функция обработки сердец
        
        
        if xFromCenter > 25 { /// Если пользователь перетаскивает вправо то появляется зеленое сердечко
            
            currentCard.likHeartImage.tintColor = UIColor.green.withAlphaComponent(xFromCenter * 0.005)
            currentCard.likHeartImage.isHidden = false
            currentCard.dislikeHeartImage.isHidden = true
            currentCard.superLike.isHidden = true
            
        }else if xFromCenter < -25 { /// Если влево красное
            
            currentCard.dislikeHeartImage.tintColor = UIColor.red.withAlphaComponent(abs(xFromCenter) * 0.005)
            currentCard.dislikeHeartImage.isHidden = false
            currentCard.likHeartImage.isHidden = true
            currentCard.superLike.isHidden = true
            
        }else if yFromCenter < 0 {
            
            currentCard.superLike.alpha = abs(yFromCenter) * 0.005
            currentCard.superLike.isHidden = false
            currentCard.dislikeHeartImage.isHidden = true
            currentCard.likHeartImage.isHidden = true
            
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
            return card
        }else {
            stopCard = true
            return createEmptyCard()
        }
        
    }
    func createEmptyCard() -> CardView {
        
        let card = cardModel.createEmptyCard()
        
        return card
    }
    
}


//MARK: -  Загрузка новых пользователей

extension ViewController {
    
    func loadNewUsers(numberRequsetedUsers: Int,nonSwipedUsers:[String] = [String]()) async{
        
        var newUsersArr = [User]()
        
        if let loadUsersIDArr = await FirebaseStorageModel().loadUsersID(countUser: numberRequsetedUsers,currentUser: currentAuthUser,nonSwipedUsers: nonSwipedUsers) {
            
            print("Количество только что загруженных полльзователей - \(loadUsersIDArr.count)")
            if numberRequsetedUsers > loadUsersIDArr.count {
                currentAuthUser.couplesOver = true
            }
            
            for ID in loadUsersIDArr {
                
                var newUser = User(ID: ID)
                await newUser.loadMetaData()
                
                if let urlFilesArr = await FirebaseStorageModel().loadPhotoToFile(urlPhotoArr: newUser.urlPhotoArr, userID: ID,currentUser: false) {
                    newUser.loadPhotoFromDirectory(urlFileArr: urlFilesArr)
                    newUsersArr.append(newUser)
                    progressViewLoadUsers.progressBar.progress += 0.02
                }
                
            }
            
            usersArr = usersArr +  newUsersArr
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
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.progressViewLoadUsers.backView.removeFromSuperview()
            self.tabBarController?.tabBar.isHidden = false
            self.buttonStackView.isHidden = false
            
            self.oddCard = self.createCard(currentUserIDCard: nil)
            self.honestCard = self.createCard(currentUserIDCard: self.oddCard?.userID)
            self.currentCard = self.oddCard
            
            self.oddCard!.addGestureRecognizer(self.panGesture)
            self.oddCard!.addGestureRecognizer(self.tapGesture)
            self.view.addSubview(self.honestCard!)
            self.view.addSubview(self.oddCard!)
            self.view.bringSubviewToFront(self.buttonStackView)
        }
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


