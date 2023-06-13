//
//  ChatUserController.swift
//  Meeting
//
//  Created by Деним Мержан on 24.05.23.
//

import UIKit
import FirebaseFirestore

class ChatUserController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topElementView: UIView!
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var currentAuthUser = CurrentAuthUser(ID: "")
    var selectedUser = User(ID: "")
    var listener: ListenerRegistration?
    
    var cachedCellHeight = [[Float]]()
    
    var statusSendMessage: String {
        get {
            for messages in messageArr {
                if messages.messagedWritingOnServer == false {return "Идет отправка..."}
            }
            guard let messageRead = messageArr.last?.messageRead else {return "Отправлено"}
            if messageRead {return "Прочитанно"}
            return "Отправлено"
        }
    }
    
    var messageArr =  [message]() {
        didSet {
            guard let index = indexChat else {return}
            currentAuthUser.chatArr[index].messages = messageArr
            structMessagesArr = currentAuthUser.chatArr[index].structuredMessagesByDates
        }
    }
    var structMessagesArr =  [StructMessages]()
    var indexChat: Int?
    
    let widthMessagViewCurrentUser = UIScreen.main.bounds.width - 60 /// 45 - ширина аватара, 15 - отступы друг от друга
    let widthMessagViewOtherUser = UIScreen.main.bounds.width - 90 /// 45 - ширина аватара, 25 - ширина сердечка справа, 20 - отуступы от краев и от друг друга
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSetings()
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        guard let body = textField.text else {return}
        if textField.text?.count == 0 {return}
        textField.text = ""
        
        currentAuthUser.sendMessageToServer(pairUserID: selectedUser.ID, body: body)
        
        if currentAuthUser.chatArr.firstIndex(where: {$0.ID.contains(selectedUser.ID)}) == nil { /// Если чата не существует, значит это первое сообщение
            
            var chatID = String()
            if currentAuthUser.ID > selectedUser.ID {
                chatID = currentAuthUser.ID + "\\" + selectedUser.ID
            }else {
                chatID = selectedUser.ID + "\\" + currentAuthUser.ID
            }
            
            var chat = Chat(ID: chatID)
            let message = message(sender: currentAuthUser.ID, body: body,dateMessage: Date().timeIntervalSince1970)
            chat.messages.append(message)
            currentAuthUser.chatArr.append(chat)
            indexChat = currentAuthUser.chatArr.firstIndex(where: {$0.ID == chatID}) ?? 0
            messageArr.append(message)
            loadMessage()
        }
        
    }
    
    @objc func userReturnedToChat(){ /// Когда пользователь снова открывает приложение, мы снова загружаем чаты
        loadMessage()
    }
    
    deinit {
        print("Denit")
        listener?.remove() /// Удаляем прослушивателя
        if let chatIndex = currentAuthUser.chatArr.firstIndex(where: {$0.ID.contains(selectedUser.ID)}) {
            currentAuthUser.chatArr[chatIndex].lastUnreadMessage = nil
        } /// После того как пользователь прочитал сообщения обнуляем последнее не прочитанное сообщение
        
        NotificationCenter.default.removeObserver(self,name: Notification.Name("sceneWillEnterForeground"), object: nil)
    }
}


//MARK: -  Стартовые настройки

extension ChatUserController {
    
    func setupSetings(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(userReturnedToChat), name: Notification.Name(rawValue: "sceneWillEnterForeground"), object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CurrentChatCell", bundle: nil), forCellReuseIdentifier: "currentChatCell")
        tableView.sectionHeaderHeight = 40
        
        avatarUser.layer.cornerRadius = avatarUser.frame.width / 2
        avatarUser.clipsToBounds = true
        topElementView.addBottomShadow()
        
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.backgroundColor = UIColor(named: "PlaceHolderChatColor")
        textField.layer.borderWidth = 0.2
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.masksToBounds = true
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Сообщение",attributes: attributes)
        
        avatarUser.image = selectedUser.avatar
        nameUser.text = selectedUser.name
        
        loadMessage()
    }
}

//MARK: - UITableViewDataSource

extension ChatUserController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 0}
        return structMessagesArr[section - 1].messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return structMessagesArr.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentChatCell", for: indexPath) as! CurrentChatCell
        
        cell.messageLabel.text = structMessagesArr[indexPath.section - 1].messages[indexPath.row].body
        let sender = structMessagesArr[indexPath.section - 1].messages[indexPath.row].sender
        
        cell.selectionStyle = .none
    
        let label = UILabel() /// Лейбл с постоянной высотой 45 и шириной что бы всегда расчитывать одну и ту же идеальную ширину текста для ячейки
        
        label.text = cell.messageLabel.text
        label.font = cell.messageLabel.font
        label.frame.size.height = 45
        
        if sender == currentAuthUser.ID {
            cell.currentUser = true
        
            label.frame.size.width = widthMessagViewCurrentUser - 32
            cell.statusMessage.isHidden = false
            if structMessagesArr[indexPath.section - 1].messages[indexPath.row].messagedWritingOnServer {
                cell.statusMessage.image = UIImage(systemName: "checkmark")
            }
            
            if structMessagesArr[indexPath.section - 1].messages[indexPath.row].messageRead {
                cell.statusMessage.image = UIImage(named: "MessageSend")
            }
            
            cell.heartLikeView.isHidden = true
            cell.rightMessageViewConstrainsToHeartView.isActive = false
            cell.avatar.image = UIImage()
            cell.rightMessageViewConstrainsToSuperView.isActive = true /// Дополнительная константа которая говорит что MessageView будт на расстояние от SuperView на 5 пунктов
            
            cell.messageLabel.textAlignment = .right
            cell.messageView.backgroundColor = UIColor(named: "CurrentUserMessageColor")
            cell.messageLabel.textColor = .white
            
            let widthLabel = label.intrinsicContentSize.width
            
            if widthLabel < widthMessagViewCurrentUser {
                let newLeftConstant = widthMessagViewCurrentUser - widthLabel - 32 /// MessageView стал больше после того как мы скрыли сердечко, получаем расстояение от MessageView до аватарки, 32 - (10 расстояние Лейбла от левого, 22 растояние от правого края)
                cell.leftMessageViewConstrainsToSuperView.constant = newLeftConstant + 5
            }else {
                cell.leftMessageViewConstrainsToSuperView.constant = 5
            }
            
            
        }else {
            label.frame.size.width = widthMessagViewOtherUser - 20 /// 20 -  (10 расстояние Лейбла от левого, 10 растояние от правого края)
            
            cell.statusMessage.isHidden = true
            cell.labelRightConstrainsToMessageView.constant = 10
            cell.messageLabel.textAlignment = .left
            cell.messageView.backgroundColor = UIColor(named: "GrayColor")
            cell.avatar.image = selectedUser.avatar
            cell.messageLabel.textColor = .black
            
            let widthLabel = label.intrinsicContentSize.width
            
            if widthLabel < widthMessagViewOtherUser {
                let newRightConstrains = widthMessagViewOtherUser - widthLabel - 20
                cell.rightMessageViewConstrainsToHeartView.constant = newRightConstrains + 5
            }else {
                cell.rightMessageViewConstrainsToHeartView.constant = 5
            }
        }
        
        
        
        if  indexPath.row + 1 < structMessagesArr[indexPath.section - 1].messages.count && structMessagesArr[indexPath.section - 1].messages[indexPath.row + 1].sender == sender {
            cell.avatar.image = UIImage()
            cell.bottomMessageViewConstrains.constant = 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = viewForHeaderSection(section: section)
        return view
    }
        
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let lastMessage = messageArr.last else {return nil}
        if lastMessage.sender != currentAuthUser.ID {return nil}
        return section == tableView.numberOfSections - 1 ? viewForFooterSection(section: section) : nil
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("SwipeStart")
        return .some(.init())
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == tableView.numberOfSections - 1 ? 20 : 0
    }
}

//MARK: -  Отслеживание изменений на сервере

extension ChatUserController {
    
    func loadMessage(){
        
        listener?.remove()
        guard let index = indexChat else {return}
        let chatID = currentAuthUser.chatArr[index].ID
        let db = Firestore.firestore()
        
        let listener = db.collection("Chats").document(chatID).collection("Messages").order(by: "Date").addSnapshotListener(includeMetadataChanges: true) { [weak self] QuerySnapshot, Error in
            
            if let error = Error {print("Ошибка прослушивания снимков с сервера - \(error)"); return}
            
            print("LoadMessage")
                       
            guard let document = QuerySnapshot else {return}
            self?.messageArr.removeAll()
            
            for data in document.documents {
                
                if let body = data["Body"] as? String, let sender = data["Sender"] as? String, let date = data["Date"] as? Double, let messageRed = data["MessageRead"] as? Bool, let messageSendOnServer = data["MessageSendOnServer"] as? Bool {
                    
                    var message = message(sender: sender, body: body,dateMessage: date)
                    
                    if sender == self?.selectedUser.ID && messageRed == false {
                        db.collection("Chats").document(chatID).collection("Messages").document(data.documentID).setData(["MessageRead" : true], merge: true)
                        print("MessagerRead")
                    }
                    message.messagedWritingOnServer = messageSendOnServer
                    message.messageRead = messageRed
                    self?.messageArr.append(message)
                }
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                let sectionNumber = (self?.tableView.numberOfSections ?? 1) - 1
                let row = (self?.structMessagesArr.last?.messages.count ?? 1) - 1
                let indexPath = IndexPath(row: row, section: sectionNumber)
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
            
        self.listener = listener
    }
    
}


//MARK: -  Тень для TopView

extension UIView {
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 0.5)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
}

//MARK: -  Создание View для колонтитулов

extension ChatUserController {
    
    func viewForHeaderSection(section: Int) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        label.textColor = .gray
        label.textAlignment = .center
        label.center = view.center
        view.addSubview(label)
        
        if section == 0 {
            label.text = "Вы образовали пару 19.04.23"
        }else if section <= structMessagesArr.count {
            let text = structMessagesArr[section - 1].dateOnFormat
            label.attributedText = text
        }
        return view
    }
    
    
    func viewForFooterSection(section: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        
        let label = UILabel(frame: CGRect(x: view.frame.maxX - 110, y: 0, width: 100, height: 20))
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        
        label.text = statusSendMessage
        
        view.addSubview(label)
        
        return view
    }
    
}
