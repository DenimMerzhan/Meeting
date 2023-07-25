//
//  DescriptionUser.swift
//  test
//
//  Created by Деним Мержан on 04.07.23.
//

import Foundation
import UIKit


struct UserDescription {
    
    var mostDescription: UserInfoSection?
    var aboutME: UserInfoSection?
    var moreAboutMe: UserInfoSection?
    var lifeStyle: UserInfoSection?
    var myInterests: UserInfoSection?
    var languages: UserInfoSection?
    
    let shareProfile: UserInfoSection = {
        .shareProfile("Узнай мнение своих друзей")
    }()
    
    let banProfile: UserInfoSection = {
        .banProfile("Пользователь об этом не узнает")
    }()
    
    
    var userData: [UserInfoSection] {
        var descrtiptionArr = [UserInfoSection]()
        let mirror = Mirror(reflecting: self)
        
        for (_,value) in mirror.children {
            if let section = value as? UserInfoSection {
                descrtiptionArr.append(section)
            }
        }
        
        return descrtiptionArr
    }
    
}

