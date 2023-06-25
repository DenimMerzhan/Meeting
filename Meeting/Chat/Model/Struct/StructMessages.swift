//
//  DateMessages.swift
//  Meeting
//
//  Created by Деним Мержан on 12.06.23.
//

import Foundation
import UIKit


struct StructMessages {
    
    var dateDouble: Double
    var dateToCompare: String
    
    var dateForHeadersAndFooters: NSMutableAttributedString {
        get {
           
            let dateFormatter = DateFormatter()
            let dateMessage = Date(timeIntervalSince1970: dateDouble)
            var text1 = ""
            var text2 = ""
            
            dateFormatter.dateFormat = "MMM:YYY"
            let currentMonth = dateFormatter.string(from: Date())
            let monthMessage = dateFormatter.string(from: dateMessage)
           
            
            if Calendar.current.isDateInToday(dateMessage) {
                dateFormatter.dateFormat = "HH:mm"
                text1 = "Today "
                text2 = dateFormatter.string(from: dateMessage)
            }else if Calendar.current.isDateInYesterday(dateMessage){
                dateFormatter.dateFormat = "HH:mm"
                text1 = "Yesterday "
                text2 = dateFormatter.string(from: dateMessage)
            }else if Calendar.current.isDateInWeekend(dateMessage) {
                dateFormatter.dateFormat = "EEEE: "
                text1 = dateFormatter.string(from: dateMessage)
                dateFormatter.dateFormat = "HH:mm"
                text2 = dateFormatter.string(from: dateMessage)
            }else if currentMonth == monthMessage {
                dateFormatter.dateFormat = "MMM: "
                text1 = dateFormatter.string(from: dateMessage)
                dateFormatter.dateFormat = "HH:mm"
                text2 = dateFormatter.string(from: dateMessage)
            }else {
                dateFormatter.dateFormat = "MMM dd yyy "
                text1 = dateFormatter.string(from: dateMessage)
                dateFormatter.dateFormat = "HH:mm"
                text2 = dateFormatter.string(from: dateMessage)
            }
            
            
            let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.darkGray]
            let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.gray]
            let attributedString1 = NSMutableAttributedString(string:text1, attributes:attrs1)
            let attributedString2 = NSMutableAttributedString(string:text2, attributes:attrs2)
            attributedString1.append(attributedString2)
            return attributedString1
        }
    }
    
    var messages: [message]
    
}
