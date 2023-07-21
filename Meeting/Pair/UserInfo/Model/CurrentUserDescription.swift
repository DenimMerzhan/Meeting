//
//  DescriptionUser.swift
//  test
//
//  Created by Деним Мержан on 04.07.23.
//

import Foundation
import UIKit


struct CurrentUserDescription {
    
    static let shared = CurrentUserDescription()
    
    private var mostDescription: UserInfoSection  = {
        .mostDescription([UserInfo(title: "17 км от вас", image: UIImage(named: "DistanceToUser")!),UserInfo(title: "Гетеро", image: UIImage(systemName: "target")),UserInfo(title: "Гетеро", image: UIImage(systemName: "target")),UserInfo(title: "Пошел нахуй сучка", image: UIImage(systemName: "target")), UserInfo(title: "Долгосрочный партрнер бля", image: UIImage(named: "Holiday")!)])
    }()
    
    private var aboutME: UserInfoSection = {
        .aboutME("Я просто шалава и такая пришла ушла и привет пока в общем что говорить все бывает /n а потом еще и понеслась ")
    }()
    
    private var moreAboutMe: UserInfoSection? = {
        .moreAboutMe([UserInfo(title: "Водолей", image: UIImage(systemName: "shareplay")),UserInfo(title: "Я не хочу детей", image: UIImage()),UserInfo(title: "Нет прививки", image: UIImage()),UserInfo(title: "Гоняю быстро"), UserInfo(title: "Разведена")])
    }()
    
    private var lifeStyle: UserInfoSection? = {
        .lifeStyle([UserInfo(title: "Люблю кошек", image: UIImage()),UserInfo(title: "Курю", image: UIImage())])
    }()
    
    private var myHobbie: UserInfoSection?
    
    private var languages: UserInfoSection? = {
        .languages([UserInfo(title: "Английский"),UserInfo(title: "Немецкий")])
    }()
    
    private var shareProfile: UserInfoSection = {
        .shareProfile("Узнай мнение своих друзей")
    }()
    
    private var banProfile: UserInfoSection = {
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
    
    private init(){
        
    }
    
}

