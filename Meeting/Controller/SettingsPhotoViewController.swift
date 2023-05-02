//
//  SettingsPhotoViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 30.04.23.
//

import UIKit
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore

class SettingsPhotoViewController: UIViewController {
    
    
    @IBOutlet weak var collectionPhotoView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    var imageArr = [UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!,UIImage(named: "4")!]
    var index = IndexPath()
    
  
    let storage = Storage.storage()
    var userID = "+79817550000"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionPhotoView.delegate = self
        collectionPhotoView.dataSource = self
        
        collectionPhotoView.register(CollectionPhotoCell.self, forCellWithReuseIdentifier: CollectionPhotoCell.identifier)

        
    }


}




//MARK:  - Настройка фотоколлажа

extension SettingsPhotoViewController : UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionPhotoCell.identifier, for: indexPath) as! CollectionPhotoCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
      
        
        if let imageView = createImage(indexPath: indexPath.row, cellWidth: cell.frame.width, cellHeight: cell.frame.height) {
            
        
            cell.photoImage.image = imageView.image
            cell.photoImage.contentMode = .scaleAspectFill
            cell.dottedBorder.isHidden = true
            
            
            let button = createButton(x: cell.frame.maxX ,y: cell.frame.maxY,add: false,index: indexPath.row,cell: cell)
            collectionPhotoView.addSubview(button)
            
        }else {
            
            cell.backgroundColor = UIColor(named: "PhotoCollage")
            cell.dottedBorder.isHidden = false
            cell.photoImage.image = .none
            
            let button = createButton(x: cell.frame.maxX ,y: cell.frame.maxY,add: true,index: indexPath.row,cell: cell)
            collectionPhotoView.addSubview(button)
            
        }
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { /// Расчитываем размеры ячейки
        return CGSize(width: (collectionView.frame.size.width / 3) - 14 , height: (collectionView.frame.height / 3) - 20)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { /// Запрашивает у делегата расстояние между последовательными строками или столбцами раздела.
        return 15
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { /// Делаем отступы
        return UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 10)
    }
    
    
}




//MARK: - Внешние оформление ячеек


extension SettingsPhotoViewController {
        
    func createImage(indexPath: Int,cellWidth: CGFloat,cellHeight: CGFloat) -> UIImageView? { /// Создание фото
        
        
        if indexPath < imageArr.count {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight))
            imageView.image = imageArr[indexPath]
            imageView.contentMode = .scaleAspectFill
            return imageView
            
        }
        return nil
    }
    
    
    

//MARK: - Создание кнопок удаления и добавления
    
    
    func createButton(x: CGFloat, y: CGFloat, add: Bool,index: Int,cell:CollectionPhotoCell ) -> UIButton {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0,width: 30, height: 30))
        button.center = CGPoint(x: x - 5, y: y - 5)
        button.layer.cornerRadius = button.frame.size.width / 2
        button.layer.masksToBounds = true
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = .zero
        button.layer.opacity = 1
        button.layer.shadowRadius = 10
        
        
        if add { /// Добавляем фото
            
            button.backgroundColor = UIColor(named: "MainAppColor")
            button.setImage(UIImage(named: "Plus"), for: .normal)
            button.tintColor = UIColor.white
            
            let action = UIAction { action in
                
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = false /// Спрашивает может ли пользователь редактикровать фото
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true)
                
                
            }
            
            button.addAction(action, for: .touchUpInside)
            
            return button
            
            
            
        }else { /// Удаляем фото
            
            button.backgroundColor = .white
            button.setImage(UIImage(named: "DeletePhoto"), for: .normal)
            button.tintColor = UIColor.gray
            
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.gray.cgColor
            
            let action = UIAction { action in
                
                self.imageArr.remove(at: index)
                self.collectionPhotoView.reloadData()
                
                
            }
            button.addAction(action, for: .touchUpInside)

            return button
        }
    }
}




//MARK: - Загрузка фото из галереи пользователя


extension SettingsPhotoViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            uploadDataToServer(image: image)
        }
        imagePicker.dismiss(animated: true)
    }
    
    
//MARK: -  Загрузка фото на сервре
    
    func uploadDataToServer(image: UIImage){
        
        let imageID = "photoImage" + randomString(length: 5)
        
        let progressView = createProgressBarLoadPhoto()
        view.addSubview(progressView.backView)
        
        UIView.animate(withDuration: 4, delay: 0.2) {
            progressView.progressBar.setProgress(0.7, animated: true)
        }
        
        let imagesRef = Storage.storage().reference().child("UsersPhoto").child(userID).child(imageID) /// Создаем ссылку на файл
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { /// Преобразуем в Jpeg c сжатием
            return
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg" /// Указываем явный тип данных в FireBase
        
        
        imagesRef.putData(imageData,metadata: metaData) { metadata, erorr in
            
            guard metadata != nil else {
                print(erorr!)
                return
            }
            
            imagesRef.downloadURL { url, error in /// Получаем URL адрес фото
                
                if let url = url {
                    
                    let db = Firestore.firestore().collection("Users").document(self.userID) /// Добавляем в FiresStore ссылку на фото
                    db.setData([imageID : url.absoluteString],merge: true) { err in
                        if let error = err {
                            print(error)
                        }else{ /// В случае успешного выполнения обновляем архив
                            
                            UIView.animate(withDuration: 1.5, delay: 0) {
                                progressView.progressBar.setProgress(1, animated: true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    progressView.checkMark.isHidden = false
                                    self.imageArr.append(image)
                                    self.collectionPhotoView.reloadData()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                                    progressView.backView.removeFromSuperview()
                                }
                            }

                        }
                    }

                }else{
                    print(erorr!)
                }
            }
        }
    }
    
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

}
