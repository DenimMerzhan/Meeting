//
//  Message.swift
//  Meeting
//
//  Created by Деним Мержан on 23.05.23.
//

import Foundation
import FirebaseFirestore


struct message {
    
    var sender: String
    var body: String
    var messagedWritingOnServer = Bool()
    var messageRead = Bool()
    var dateMessage: Double
    
    var dateMessageToCompare: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyy, MMM, EEEE"
            let date = Date(timeIntervalSince1970: dateMessage)
            return dateFormatter.string(from: date)
        }
    }
}

