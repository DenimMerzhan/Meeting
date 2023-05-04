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
    
    var imageFiles = [CurrentUserFile]()
    
    var index = IndexPath()
    
    let fileManager = FileManager.default
    var currentPhotoFolder = URL(string: "")

    let storage = Storage.storage()
    var userID = "+79817550000"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let newArr = getSavedImage() {
            imageFiles = newArr
            collectionPhotoView.reloadData()
        }
        
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
            
            let button = createDeleteButton(x: cell.frame.maxX ,y: cell.frame.maxY, index: indexPath.row,cell: cell)
            collectionPhotoView.addSubview(button)
            
        }else {
            
            cell.backgroundColor = UIColor(named: "PhotoCollage")
            cell.dottedBorder.isHidden = false
            cell.photoImage.image = .none
            
            let button = createAddButton(x: cell.frame.maxX ,y: cell.frame.maxY)
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
        
        
        if indexPath < imageFiles.count {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight))
            imageView.image = imageFiles[indexPath].image
            imageView.contentMode = .scaleAspectFill
            return imageView
            
        }
        return nil
    }
    
    
    

//MARK: - Создание кнопок удаления и добавления
    
    
    func createAddButton(x: CGFloat, y: CGFloat) -> UIButton {
        let buttonAdd = CreateButton().createAddButtonPhotoSetings(x: x, y: y)
        
        let action = UIAction { action in
            
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false /// Спрашивает может ли пользователь редактикровать фото
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)

        }
        buttonAdd.addAction(action, for: .touchUpInside)
        
        return buttonAdd
    }
    
    
    func createDeleteButton(x: CGFloat, y: CGFloat,index: Int,cell:CollectionPhotoCell) -> UIButton {
        let buttonDelete = CreateButton().createDeleteButtonPhotoSetings(x: x, y: y)
        
        let action = UIAction { action in
            
            self.imageFiles.remove(at: index)
            self.collectionPhotoView.reloadData()
        }
        buttonDelete.addAction(action, for: .touchUpInside)
        
        return buttonDelete
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
        
        let progressView = createProgressBarLoadPhoto()
        view.addSubview(progressView.backView)
        
        let  firebaseStorage = FirebaseStorageModel(userID: userID)
        
        UIView.animate(withDuration: 4, delay: 0.2) {
            progressView.progressBar.setProgress(0.7, animated: true)
        }
        
        Task { /// Ждем пока поступит ответ, либо успешная загрузка либо нет
            
            let data = await firebaseStorage.uploadImageToStorage(image: image)
            
            if data.succes {
                
                print(data.imageId)
                UIView.animate(withDuration: 1.5, delay: 0) {
                    
                    progressView.progressBar.setProgress(1, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        progressView.checkMark.isHidden = false
                        self.imageFiles.append(CurrentUserFile(nameFile: data.imageId,image: image))
                        self.collectionPhotoView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            progressView.backView.removeFromSuperview()
                        }
                    }
                }
                
            }
        }
    }

}




//MARK: - Получение изображения из файлов

extension SettingsPhotoViewController {
    
    func getSavedImage() -> [CurrentUserFile]? {
        
        var imageFiles = [CurrentUserFile]()
        
        if let urlArr = getUrlFile() {
            
            for url in urlArr {
                let fileName = String((url.path as NSString).lastPathComponent)
                if let newImage = UIImage(contentsOfFile: url.path) {
                    imageFiles.append(CurrentUserFile(nameFile: fileName,image: newImage))
                }
            }
        }
        
        if imageFiles.count == 0 {
            return nil
        }else {
            return imageFiles
        }
    }
    
    private func getUrlFile() -> [URL]? {
        
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CurrentUsersPhoto")
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil,options: .skipsHiddenFiles)
            return fileURLs
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            return nil
        }
        
    }
    
}









extension SettingsPhotoViewController {
   
   func createProgressBarLoadPhoto() -> (progressBar : UIProgressView,backView: UIView, checkMark: UIImageView) {
       
       
       let backView = UIView(frame: CGRect(x: 20, y: 50, width: 350, height: 50))
       backView.backgroundColor = UIColor(named: "LoadPhotoColor")
       backView.layer.cornerRadius = 10
       
       let checkMarkImage = UIImageView(frame: CGRect(x: 290, y: 10, width: 50, height: 20))
       checkMarkImage.image = UIImage(systemName: "checkmark")
       checkMarkImage.contentMode = .scaleAspectFit
       checkMarkImage.tintColor = .white
       checkMarkImage.isHidden = true
       backView.addSubview(checkMarkImage)
       
       let label = UILabel(frame: CGRect(x: 25, y: 10, width: 100, height: 20))
       label.text = "Загрузка фото..."
       label.font = .systemFont(ofSize: 17)
       label.textColor = .white
       
       backView.addSubview(label)
       
       
       let progressBar = UIProgressView(frame: CGRect(x: 25, y: 35, width: 300, height: 30))
       backView.addSubview(progressBar)
       progressBar.progressViewStyle = .bar
       progressBar.progressTintColor = UIColor(named: "MainAppColor")
       progressBar.trackTintColor = .gray
       progressBar.setProgress(0.0, animated: false)
       
       
       return (progressBar,backView,checkMarkImage)
       
       
   }
   
}
