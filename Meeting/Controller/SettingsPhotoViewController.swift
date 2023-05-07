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
    
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var collectionPhotoView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    var animateProgressToValue = Float(0)
    var imageFiles = [CurrentUserFile]()
    
    var defaults = UserDefaults.standard
    var index = IndexPath()
    
    let fileManager = FileManager.default
    var currentPhotoFolder = URL(string: "")
    
    let storage = Storage.storage()
    var userID = "+79213229900"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let newArr = getSavedImage() { /// Если в каталоге есть фото текущего пользователя то загружаем их
            imageFiles = newArr
            collectionPhotoView.reloadData()
        }
        
        collectionPhotoView.delegate = self
        collectionPhotoView.dataSource = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = false /// Спрашивает может ли пользователь редактикровать фото
        imagePicker.sourceType = .photoLibrary

        
        collectionPhotoView.register(CollectionPhotoCell.self, forCellWithReuseIdentifier: CollectionPhotoCell.identifier)
        
    }
    
    
    @IBAction func donePressed(_ sender: UIButton) {
        defaults.set(Float(imageFiles.count) / 9 , forKey: "ProfileFilingScale") /// Записываем данные о количествах фото текущего пользователя
        
        
        self.dismiss(animated: true)
    }
    
    deinit {
        print("\(self) уничтожен")
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




//MARK: - Создание фото из архива


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
        
        let action = UIAction { [unowned self] action in
            
            self.present(self.imagePicker, animated: true)

        }
        buttonAdd.addAction(action, for: .touchUpInside)
        
        return buttonAdd
    }
    
    
    func createDeleteButton(x: CGFloat, y: CGFloat,index: Int,cell:CollectionPhotoCell) -> UIButton {
        let buttonDelete = CreateButton().createDeleteButtonPhotoSetings(x: x, y: y)
        
        let action = UIAction { [unowned self] action in
            
            
            let  firebaseStorage = FirebaseStorageModel(userID: self.userID)
            firebaseStorage.removePhotoFromServer(userID: self.userID, imageID: self.imageFiles[index].nameFile)
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
}


//MARK: -  Загрузка фото на сервре

extension SettingsPhotoViewController {

    func uploadDataToServer(image: UIImage){
        doneButton.isHidden = true
        let progressView = CreateButton().createProgressBarLoadPhoto()
        view.addSubview(progressView.backView)
        
        let  firebaseStorage = FirebaseStorageModel(userID: userID)
        
        UIView.animate(withDuration: 4, delay: 0.2) {
            progressView.progressBar.setProgress(0.7, animated: true)
        }
        
        Task {  /// Ждем пока поступит ответ, либо успешная загрузка либо нет
            
            let data = await firebaseStorage.uploadImageToStorage(image: image)
            
            if data.succes {
               
                imageFiles.append(CurrentUserFile(nameFile: data.fileName,image: image))
                
                
                UIView.animate(withDuration: 1.5, delay: 0) {
                    
                    progressView.progressBar.setProgress(1, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [unowned self] in
                        progressView.checkMark.isHidden = false
                        self.collectionPhotoView.reloadData()
                        self.doneButton.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            progressView.backView.removeFromSuperview()
                        }
                    }
                }
                
            }
        }
    }

}




//MARK: - Получение изображения из файлов библиотеки пользователя

extension SettingsPhotoViewController {
    
    func getSavedImage() -> [CurrentUserFile]? { /// Фото сохраняется в памяти, и при выходи из контроллера не удаляется!
        
        var imageFiles = [CurrentUserFile]()
        
        if let urlArr = getUrlFile() {
            
            for url in urlArr {
                let fileName = String((url.path as NSString).lastPathComponent)
                
                if var newImage = UIImage(contentsOfFile: url.path) {
                    imageFiles.append(CurrentUserFile(nameFile: fileName,image: newImage))
                    newImage = .remove
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
            print("Ошибка получения адресов файлов \(documentsURL.path): \(error.localizedDescription)")
            return nil
        }
        
    }
    
}

       
       
   


