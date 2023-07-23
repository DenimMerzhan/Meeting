//
//  UserInfoSection.swift
//  test
//
//  Created by Деним Мержан on 05.07.23.
//

import Foundation


enum UserInfoSection {
    
    case mostDescription([UserInfo])
    case aboutME(String)
    case moreAboutMe([UserInfo])
    case lifeStyle([UserInfo])
    case myHobbie([UserInfo])
    case languages([UserInfo])
    case shareProfile(String)
    case banProfile(String)
    

    
    var countItem: Int? {
        
        switch self {
        case .mostDescription(let item):
            return item.count
        case .aboutME(_):
            return 1
        case .moreAboutMe(let moreAboutMe):
            return moreAboutMe.count
        case .lifeStyle(let item):
            return item.count
        case .myHobbie(let myHobbie):
            return myHobbie.count
        case .languages(let languages):
            return languages.count
        case .shareProfile(_):
            return 1
        case .banProfile(_):
            return 1
        }
        
    }
    
    
}

