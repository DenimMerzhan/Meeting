//
//  SettingsPhotoViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 30.04.23.
//

import UIKit

class SettingsPhotoViewController: UIViewController {
    

    

    
    
    @IBOutlet weak var collectionPhotoView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionPhotoView.delegate = self
        collectionPhotoView.dataSource = self
        
        
    }


}


extension SettingsPhotoViewController : UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageUserCell", for: indexPath)
        
        cell.backgroundColor = .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print((collectionView.frame.size.width / 3) - 3)
        return CGSize(width: (collectionView.frame.size.width / 3) - 13 , height: (collectionView.frame.height / 3))
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
}
