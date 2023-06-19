//
//  Messages.swift
//  Meeting
//
//  Created by Деним Мержан on 12.06.23.
//

import Foundation

struct Chat {
    
  
    let ID: String
    var messages =  [message]()
    var lastUnreadMessage: String?
    var numberUnreadMessges = 0
    
    var structuredMessagesByDates: [StructMessages] {
        get {
            let newArr = messages.sorted(by: {$0.dateMessage < $1.dateMessage})
            var messageArr = [StructMessages]()
            for message in newArr {
                if messageArr.count == 0 {
                    messageArr.append(StructMessages(dateDouble: message.dateMessage, dateToCompare: message.dateMessageToCompare, messages: [message]))
                }else {
                    if let index = messageArr.firstIndex(where: {$0.dateToCompare == message.dateMessageToCompare }) {
                        messageArr[index].messages.append(message)
                    }else {
                        messageArr.append(StructMessages(dateDouble: message.dateMessage, dateToCompare: message.dateMessageToCompare, messages: [message]))
                    }
                }
            }
            
            return messageArr
        }
    }
    
    init(ID: String) {
        self.ID = ID
    }
}
