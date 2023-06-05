//
//  CustomError.swift
//  Meeting
//
//  Created by Деним Мержан on 11.05.23.
//

import Foundation


enum erorrMeeting: Error {
  
    case fewUsers(code:Int)
    case missingUserPhoto
    case errorLoadPhoto(code: Error)
    case messageNotSent(code: Error)
}

extension erorrMeeting: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .fewUsers(let code):
            return "Оставщихся пользователей меньше чем запрошенных. Оставшихся пользователей - " + String(code)
        case .missingUserPhoto:
            return "Фото пользователя отсуствует"
        case .errorLoadPhoto(code: let code):
            return "Ошибка загрузки данных изображения с FirebaseStorage \(code)"
        case .messageNotSent(code: let code):
            return "Ошибка отправки сообщения \(code)"
        }
    }
}

