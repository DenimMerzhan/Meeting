//
//  Message.swift
//  Meeting
//
//  Created by Деним Мержан on 23.05.23.
//

import Foundation

struct Chat {
    
    let ID: String
    var messages =  [message]()
    var lastUnreadMessage: String?
    var numberUnreadMessges = 0
    var dateLastMessageRead: Double
    
    init(ID: String,dateLastMessageRead:Double) {
        self.ID = ID
        self.dateLastMessageRead = dateLastMessageRead
    }
}

struct message {
    var sender: String
    var body: String
    var messagedWritingOnServer = Bool()
}

