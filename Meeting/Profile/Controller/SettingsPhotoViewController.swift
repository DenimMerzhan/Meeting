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
    
    var defaults = UserDefaults.standard
    var index = IndexPath()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionPhotoView.delegate = self
        collectionPhotoView.dataSource = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = false /// Спрашивает может ли пользователь редактикровать фото
        imagePicker.sourceType = .photoLibrary
        
        collectionPhotoView.register(SettingsPhotoCell.self, forCellWithReuseIdentifier: SettingsPhotoCell.identifier)
    }
    
    
    @IBAction func donePressed(_ sender: UIButton) {
//        defaults.set(Float(currentAuthUser.imageArr.count) / 9 , forKey: "ProfileFilingScale") /// Записываем данные о количествах фото текущего пользователя
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsPhotoCell.identifier, for: indexPath) as! SettingsPhotoCell
        let row = indexPath.row
        let imagePicker = self.imagePicker
        
        cell.addButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.deleteButton.removeTarget(nil, action: nil, for: .allEvents)
        
        let addAction = UIAction { [weak self] action in
            self?.present(imagePicker, animated: true)
        }
        cell.addButton.addAction(addAction, for: .touchUpInside)
        
        let deleteAction = UIAction { [weak self] action in
            guard let imageID = CurrentAuthUser.shared.imageArr[row].imageID else {return}
            CurrentAuthUser.shared.imageArr.remove(at: row)
            CurrentAuthUser.shared.removePhotoFromServer(imageID: imageID)
            self?.collectionPhotoView.reloadData()
        }
        cell.deleteButton.addAction(deleteAction, for: .touchUpInside)
        
        if CurrentAuthUser.shared.imageArr.count > 1 {
            cell.deleteButton.isEnabled = true
        }else {cell.deleteButton.isEnabled = false}
        
        if row < CurrentAuthUser.shared.imageArr.count {
            
            cell.addButton.isHidden = true
            cell.deleteButton.isHidden = false
            CurrentAuthUser.shared.imageArr[row].delegate = self
            cell.photoImage.image = CurrentAuthUser.shared.imageArr[row].image
            cell.dottedBorder.isHidden = true
            
        }else {
            cell.addButton.isHidden = false
            cell.deleteButton.isHidden = true
            cell.dottedBorder.isHidden = false
            cell.photoImage.image = UIImage(color: UIColor(named: "PhotoCollage")!)
            cell.photoImage.loadIndicator.stopAnimating()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { /// Расчитываем размеры ячейки
        return CGSize(width: (collectionView.frame.size.width / 3) - 4, height: (collectionView.frame.height / 3))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { /// Запрашивает у делегата расстояние между последовательными строками или столбцами раздела.
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { /// Делаем отступы
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
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
        let progressView = CreateButton().createProgressBarLoadPhoto(width: view.frame.width - 40)
        view.addSubview(progressView.backView)
        
        UIView.animate(withDuration: 4, delay: 0.2) {
            progressView.progressBar.setProgress(0.7, animated: true)
        }
        
        Task {  /// Ждем пока поступит ответ, либо успешная загрузка либо нет
            
            let succes = await CurrentAuthUser.shared.uploadImageToStorage(image: image)
            
            
            if succes {
                
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

//MARK: -  Обновляем СollectionView когда фото загрузилось

extension SettingsPhotoViewController: LoadPhoto {
    func userPhotoLoaded() {
        print("Перезагрузка")
        collectionPhotoView.reloadData()
    }
}






