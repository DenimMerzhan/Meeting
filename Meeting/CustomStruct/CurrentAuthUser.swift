//
//  CurrentAuthUserID.swift
//  Meeting
//
//  Created by Деним Мержан on 10.05.23.
//

import Foundation
import UIKit
import FirebaseFirestore


class CurrentAuthUser {
    
    
    var ID  = String()
    
    var name = String()
    var age = Int()
    
    var urlPhotoArr = [String]()
    var imageArr = [UIImage]()
    
    var likeArr = [String]()
    var disLikeArr = [String]()
    var superLikeArr = [String]()
    
    var couplesOver = Bool()
    
    private let db = Firestore.firestore()
   
    init(ID: String){
        self.ID = ID
    }
    
    
    //MARK: -  Загрузка метаданных о текущем авторизованном пользователе с FireStore
            
     func loadMetadata() async {
        
        let collection  = db.collection("Users2").document(ID)
        
        do {
            
            let docSnap = try await collection.getDocument()
            if let dataDoc = docSnap.data() {
                
                if let name = dataDoc["Name"] as? String ,let age = dataDoc["Age"] as? Int {
                    
                    self.name = name
                    self.age = age
                    
                    if let likeArr = dataDoc["LikeArr"] as? [String], let disLikeArr = dataDoc["DisLikeArr"] as? [String], let superLikeArr = dataDoc["SuperLikeArr"] as? [String]  {
                        self.likeArr = likeArr
                        self.disLikeArr = disLikeArr
                        self.superLikeArr = superLikeArr
                    }
                    
                    
                    for data in dataDoc {
                        if data.key.contains("photoImage") {
                            if let urlPhoto = data.value as? String {
                                self.urlPhotoArr.append(urlPhoto)
                            }
                        }
                    }
                        
                    
                }else {
                    print("Ошибка в преобразование данных о текущем пользователе")
                }
            }
            
        }catch{
            print("Ошибка получения ссылок на фото с сервера FirebaseFirestore - \(error)")
        }
    }

    
//MARK:  - Записиь информации о парах
    
    func writingPairsInfrormation(){
        
        
        let documenRef = db.collection("Users2").document(ID)
    
        documenRef.setData([
            "LikeArr" : self.likeArr,
            "DisLikeArr" : self.disLikeArr,
            "SuperLikeArr": self.superLikeArr
        ],merge: true) { err in
            if let error = err {
                print("Ошибка записи данных о парах пользователя - \(error)")
            }
            
        }
    }
    
    func loadPhotoFromDirectory(urlFileArr: [URL] ){
        
        for url in urlFileArr {
            if let newImage = UIImage(contentsOfFile: url.path) {
                imageArr.append(newImage)
//                newImage = .remove
            }
        }
    }
}
