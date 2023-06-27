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
    @IBOutlet weak var userAvatar: DefaultLoadPhoto!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var currentAuthUser = CurrentAuthUser(ID: "")
    
    var isFirstLaunch = true
    
    var selectedUser = User(ID: "",currentAuthUserID: "")
    var listener: ListenerRegistration?
    var messageLike = Bool()
    
    
    var statusSendMessage: String {
        get {
            for messages in chat.messages {
                if messages.messagedWritingOnServer == false {return "Идет отправка..."}
            }
            guard let messageRead = chat.messages.last?.messageRead else {return "Отправлено"}
            if messageRead {return "Прочитанно"}
            return "Отправлено"
        }
    }
    
    var chat =  Chat(ID: "")
    
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
        currentAuthUser.sendMessageToServer(user: selectedUser, body: body)
        
    }
    
    @objc func userReturnedToChat(){ /// Когда пользователь снова открывает приложение, мы снова загружаем чаты
        loadMessage()
    }
    
    deinit {
        print("Denit")
        listener?.remove() /// Удаляем прослушивателя
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
        
        userAvatar.layer.cornerRadius = userAvatar.frame.width / 2
        userAvatar.clipsToBounds = true
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
        userAvatar.loadIndicator.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        if selectedUser.avatar?.image != nil {
            userAvatar.image = selectedUser.avatar?.image
            userAvatar.loadIndicator.stopAnimating()
        }
        nameUser.text = selectedUser.name
        selectedUser.avatar?.delegate = self
        currentAuthUser.avatar?.delegate = self
        loadMessage()
    }
}

//MARK: - UITableViewDataSource

extension ChatUserController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 0}
        return chat.structuredMessagesByDates[section - 1].messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chat.structuredMessagesByDates.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentChatCell", for: indexPath) as! CurrentChatCell
        
        let message = chat.structuredMessagesByDates[indexPath.section - 1].messages[indexPath.row]
        let sender = message.sender
        let view = cell.messageBubble as! messageBuble
        
        cell.selectionStyle = .none
        cell.messageLabel.text = message.body
        
        if sender == currentAuthUser.ID {
            
            view.isCurrentUser = true
            view.labelForCalculate.text = cell.messageLabel.text /// Передаем текст и шрифт для расчета идеальной ширины лейбла
            view.labelForCalculate.font = cell.messageLabel.font
            
            if message.messagedWritingOnServer {cell.statusMessage.image = UIImage(systemName: "checkmark")}
            if message.messageRead {cell.statusMessage.image = UIImage(named: "MessageSend")}
            if message.messageLike {cell.statusMessage.image = UIImage(named: "LikeMessageRed")}
            
            cell.statusMessage.isHidden = false
            cell.heartView.isHidden = true
            cell.avatar.image = UIImage()
            cell.avatar.loadIndicator.stopAnimating()
            cell.messageBubble.backgroundColor = UIColor(named: "CurrentUserMessageColor")

            cell.messageLabel.textAlignment = .right
            cell.messageLabel.textColor = .white
            
            
        }else {
        
            
            if selectedUser.avatar?.image == nil {
                cell.avatar.loadIndicator.startAnimating()
                cell.avatar.image = UIImage(color: UIColor(named: "GrayColor")!)
            }else {
                cell.avatar.loadIndicator.stopAnimating()
                cell.avatar.image = selectedUser.avatar?.image
            }
            
            view.isCurrentUser = false
            view.labelForCalculate.text = cell.messageLabel.text
            view.labelForCalculate.font = cell.messageLabel.font
            
            let buttonAction = UIAction { [weak self] action in
                print("Action")
                message.messagePathOnServer.setData(["MessageLike" : !message.messageLike],merge: true)
                self?.messageLike = true
                print("ActionEnd")
            }
            cell.messageLikeButton.addAction(buttonAction, for: .touchUpInside)
        
            if message.messageLike {
                cell.messageLikeButton.setImage(UIImage(named: "LikeMessageRed"), for: .normal)
                cell.messageLikeButton.tintColor = UIColor(named: "DeleteChatColor")
                cell.messageLikeButton.alpha = 1
            }
            
            cell.heartView.isHidden = false
            cell.statusMessage.isHidden = true
            cell.messageLabel.textAlignment = .left
            cell.messageBubble.backgroundColor = UIColor(named: "GrayColor")
            cell.messageLabel.textColor = .black
            
        }
        
        if  indexPath.row + 1 < chat.structuredMessagesByDates[indexPath.section - 1].messages.count && chat.structuredMessagesByDates[indexPath.section - 1].messages[indexPath.row + 1].sender == sender {
            cell.avatar.image = UIImage()
            cell.avatar.loadIndicator.stopAnimating()
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
        guard let lastMessage = chat.messages.last else {return nil}
        if lastMessage.sender != currentAuthUser.ID {return nil}
        return section == tableView.numberOfSections - 1 ? viewForFooterSection(section: section) : nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let timeMessage = chat.structuredMessagesByDates[indexPath.section - 1].messages[indexPath.row].timeMessage
        let image = createTimeMessageImage(timeMessage: timeMessage)
        let deleteAction = UIContextualAction(style: .normal, title: "") { action, view, completionHandler in
            completionHandler(true)
        }
        deleteAction.backgroundColor = .white
        deleteAction.image = image
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == tableView.numberOfSections - 1 ? 10 : 0
    }
}

//MARK: -  Отслеживание изменений на сервере

extension ChatUserController {
    
    func loadMessage(){
        
        listener?.remove()
        let chatID = selectedUser.chatID
        let db = Firestore.firestore()
        
        let listener = db.collection("Chats").document(chatID).collection("Messages").order(by: "Date").addSnapshotListener(includeMetadataChanges: true) { [weak self] QuerySnapshot, Error in
            
            if let error = Error {print("Ошибка прослушивания снимков с сервера - \(error)"); return}
            
            guard let document = QuerySnapshot else {return}
            
            if document.isEmpty {return} /// Если документ пустой значит чата не начался
            self?.chat.messages.removeAll()
            
            for data in document.documents {
                
                if let body = data["Body"] as? String, let sender = data["Sender"] as? String, let date = data["Date"] as? Double, let messageRed = data["MessageRead"] as? Bool, let messageSendOnServer = data["MessageSendOnServer"] as? Bool, let messageLike = data["MessageLike"] as? Bool {
                    
                    var message = message(sender: sender, body: body, messagePathOnServer: data.reference, dateMessage: date)
                    
                    message.messageLike = messageLike
                    if sender == self?.selectedUser.ID && messageRed == false {
                        db.collection("Chats").document(chatID).collection("Messages").document(data.documentID).setData(["MessageRead" : true], merge: true)
                    }
                    if document.metadata.isFromCache == false && messageSendOnServer == false {
                        db.collection("Chats").document(chatID).collection("Messages").document(data.documentID).setData(["MessageSendOnServer" : true], merge: true)
                    }
                    
                    message.messagedWritingOnServer = messageSendOnServer
                    message.messageRead = messageRed
                    self?.chat.messages.append(message)
                }
            }
            
            DispatchQueue.main.async {
                
                guard let newMessageArr = self?.chat.messages else {return}
                guard let oldMessageArr = self?.selectedUser.chat?.messages else {return}
                
                if newMessageArr.count > oldMessageArr.count || self?.isFirstLaunch ?? true { /// Если архив сообщений увеличился или это первый запуск то прокручиваем вниз
                    
                    if newMessageArr.count == 0 {return}
                    
                    self?.tableView.reloadData()
                    let sectionNumber = (self?.tableView.numberOfSections ?? 1) - 1
                    let row = (self?.tableView.numberOfRows(inSection: sectionNumber) ?? 1) - 1
                    let indexPath = IndexPath(row: row, section: sectionNumber)
                    self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
                
                self?.selectedUser.chat = self?.chat
                self?.tableView.reloadData()
                self?.isFirstLaunch = false
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
        }else if section <= chat.structuredMessagesByDates.count {
            let text = chat.structuredMessagesByDates[section - 1].dateForHeadersAndFooters
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

//MARK: -  Отклонение контроллера при удаление пары

extension ChatUserController: MatchArrHasBennUpdate, LoadPhoto {
    
    func userPhotoLoaded() {
        tableView.reloadData()
        userAvatar.image = selectedUser.avatar?.image
        userAvatar.loadIndicator.stopAnimating()
    }
    
    func updateDataWhenUserDelete() { /// Если пользователя удалили из пар моментально отклоняем контроллер и выводим предупреждение
       
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Пара удалена", message: "Пользователь удалил вас из пар", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ок", style: .default) { [weak self] action in
                self?.dismiss(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    
    //MARK: -  Создание Image для просмотра времени сообщения
    
    func createTimeMessageImage(timeMessage: String) -> UIImage {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.textColor = .gray
        label.text = timeMessage
        label.font = .systemFont(ofSize: 10)
        
        view.addSubview(label)
        
        return view.asImage()
        
        
    }
    
}

