//
//  UserPhotoImageView.swift
//  Meeting
//
//  Created by Деним Мержан on 23.06.23.
//

import UIKit
import FirebaseStorage


protocol LoadPhoto {
    func userPhotoLoaded()
}

class UserPhoto: UIImageView {
    
    var urlPhotoFromServer: String?
    var imageID: String?
    var delegate: LoadPhoto?
    
    private let storage = Storage.storage()
    
    init(frame: CGRect, urlPhotoFromServer: String?,imageID: String?, isAvatarCurrentUser: Bool = false) {
        
        self.urlPhotoFromServer = urlPhotoFromServer
        self.imageID = imageID
        super.init(frame: frame)        
        loadPhotoFromServer(isAvatarCurrentUser: isAvatarCurrentUser)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadPhotoFromServer(isAvatarCurrentUser: Bool){
    
        guard let urlPhoto  = urlPhotoFromServer else {return}
        
        let photoRef = storage.reference(forURL: urlPhoto)
        let maxSize = Int64(1 * 4096 * 4096)
        photoRef.getData(maxSize: maxSize) { [weak self] data, err in
            if let error = err {
                print("Ошибка загрузки фото по данному пути \(urlPhoto), \(error)")
                if Reachability.isConnectedToNetwork() == false { /// Если нет соединения пытаемся скачать фото через 5 секунд
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                        self?.loadPhotoFromServer(isAvatarCurrentUser: isAvatarCurrentUser)
                    }
                }
                return
            }
            guard let photoData = data else {return}
            guard let image = UIImage(data: photoData) else {return}
            
            DispatchQueue.main.async { [weak self] in /// Кидаем выполнение в освной поток, что бы потом не было проблем с доступом к переменной
                self?.image = image
                self?.delegate?.userPhotoLoaded() /// Как только фото загрузилось сообщаем делегату о его загрузке
                
                if isAvatarCurrentUser { /// Каждый раз обновляем фотку аватара в UserDefaults
                    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let url = documents.appendingPathComponent("AvatarCurrentUser.jpeg")
                    do {
                        try photoData.write(to: url)
                    }catch {
                        print("Ошибка записи аватара текущего пользователя в каталог \(error)")
                    }
                }

            }
        }
    }
}
