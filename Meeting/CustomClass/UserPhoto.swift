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
    
    var urlPhotoFromServerFirestore: String?
    var imageID: String?
    var delegate: LoadPhoto?
    
    private let storage = Storage.storage()
    
    init(frame: CGRect, urlPhotoFromServer: String?,imageID: String?) {
        
        self.urlPhotoFromServerFirestore = urlPhotoFromServer
        self.imageID = imageID
        super.init(frame: frame)        
        loadPhotoFromServer()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadPhotoFromServer(){
    
        guard let urlPhoto  = urlPhotoFromServerFirestore else {return}
        
        let photoRef = storage.reference(forURL: urlPhoto)
        let maxSize = Int64(1 * 4096 * 4096)
        photoRef.getData(maxSize: maxSize) { [weak self] data, err in
            if let error = err {
                print("Ошибка загрузки фото по данному пути \(urlPhoto), \(error)")
                if Reachability.isConnectedToNetwork() == false { /// Если нет соединения пытаемся скачать фото через 5 секунд
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                        self?.loadPhotoFromServer()
                    }
                }
                return
            }
            guard let photoData = data else {return}
            guard let image = UIImage(data: photoData) else {return}
            
            DispatchQueue.main.async { [weak self] in /// Кидаем выполнение в освной поток, что бы потом не было проблем с доступом к переменной
                self?.image = image
                self?.delegate?.userPhotoLoaded() /// Как только фото загрузилось сообщаем делегату о его загрузке
            }
        }
    }
}
