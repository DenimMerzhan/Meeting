//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "chatCell")
    }
    

}
