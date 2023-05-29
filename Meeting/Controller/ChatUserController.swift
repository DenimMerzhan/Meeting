//
//  ChatUserController.swift
//  Meeting
//
//  Created by Деним Мержан on 24.05.23.
//

import UIKit

class ChatUserController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var userID = String()
    var chatArr = [message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        chatArr.append(message(sender: "Vika22", body: "Привет как ты?"))
        chatArr.append(message(sender: userID, body: "Я ок, а ты как?"))
        chatArr.append(message(sender: "Vika22", body: "Я тоже"))
        chatArr.append(message(sender: "Vika22", body: "Что будем делать?"))
        
        tableView.register(UINib(nibName: "CurrentChatCell", bundle: nil), forCellReuseIdentifier: "currentChatCell")
       
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
    }
    

}


extension ChatUserController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentChatCell", for: indexPath) as! CurrentChatCell
        
        cell.textLabel?.text = chatArr[indexPath.row].body
        
       
        return cell
    }
    


}

