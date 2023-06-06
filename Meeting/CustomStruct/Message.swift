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
    
    init(ID: String) {
        self.ID = ID
    }
}

struct message {
    var sender: String
    var body: String
}

