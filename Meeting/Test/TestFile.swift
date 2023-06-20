//
//  TestFile.swift
//  Meeting
//
//  Created by Деним Мержан on 09.05.23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore


struct Test {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let colorArr = [UIColor.red,UIColor.brown,UIColor.green,UIColor.yellow,.orange]
    
    
    //MARK: -  Загрузка фото на сервер
        
    
    func createUser() -> (nameUser: String,ageUser: Int,imageUserArr: [UIImage]){
        
        let name = randomString(length: 10)
        let age = Int.random(in: 0...100)
        let rand = Int.random(in: 1...5)
        var imageArr = [UIImage]()
        for _ in 1...rand {
            let image = UIImage(color: colorArr.randomElement()!)!
            imageArr.append(image)
        }
        return (name,age,imageArr)
    }
    
    func uploadImageToStorage() async {
        
        let dataUser = createUser()
        for image in dataUser.imageUserArr {
            
            let imageID = "photoImage" + dataUser.nameUser + randomString(length: 5)
            
            let imagesRef = storage.reference().child("UsersPhoto").child(dataUser.nameUser).child(imageID) /// Создаем ссылку на файл
            guard let imageData = image.jpegData(compressionQuality: 0.0) else { /// Преобразуем в Jpeg c сжатием
                return
            }
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg" /// Указываем явный тип данных в FireBase
            
            do {
                try await imagesRef.putDataAsync(imageData)
                let url = try await imagesRef.downloadURL()
                await uploadDataToFirestore(url: url, imageID: imageID,currentUserID: dataUser.nameUser,name: dataUser.nameUser,age: dataUser.ageUser)
            }catch {
                print(error)
            }
        }
}
        
        
    private func uploadDataToFirestore(url:URL,imageID: String,currentUserID: String,name: String,age:Int) async {
        
         
        let colletcion = db.collection("Users").document(currentUserID) /// Добавляем в FiresStore ссылку на фото\
        
        do {
            try await colletcion.setData(["Name" : name],merge: true)
            try await colletcion.setData(["Age" : age],merge: true)
           try await colletcion.setData([imageID : url.absoluteString], merge: true)
        }catch{
            print("Ошибка загрузки данных фото на сервер Firebase Firestore \(error)")
        }
    }
    
}


private extension Test {
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}


public extension UIImage {
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
