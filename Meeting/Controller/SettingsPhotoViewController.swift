//
//  SettingsPhotoViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 30.04.23.
//

import UIKit

class SettingsPhotoViewController: UIViewController {
    
    
    @IBOutlet weak var collectionPhotoView: UICollectionView!
    
    let imageArr = [UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!,UIImage(named: "4")!]
    
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
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        
        if let imageView = createImage(indexPath: indexPath.row, cellWidth: cell.frame.width, cellHeight: cell.frame.height) {
            cell.contentView.addSubview(imageView)
        }else {
            cell.backgroundColor = UIColor(named: "PhotoCollage")
            let newBorder = createDottedLine(bounds: cell.bounds)
            cell.layer.addSublayer(newBorder)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width / 3) - 8 , height: (collectionView.frame.height / 3) - 8)
    }
    
    
    
    
    func createImage(indexPath: Int,cellWidth: CGFloat,cellHeight: CGFloat) -> UIImageView? {
        
        if indexPath < imageArr.count {
            print(indexPath)
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight))
            imageView.image = imageArr[indexPath]
            imageView.contentMode = .scaleAspectFill
            return imageView
            
        }
        return nil
    }
    
    
    func createDottedLine(bounds: CGRect) -> CAShapeLayer { /// Создание пунткирной границы
        
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = UIColor.gray.cgColor
        viewBorder.lineDashPattern = [10,4]  /// Штриховой узор, применяемый к контуру фигуры при обводке.
        viewBorder.frame = bounds
        viewBorder.opacity = 0.4
        viewBorder.lineWidth = 5
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(rect: viewBorder.bounds).cgPath
        
        return viewBorder
        
    }
}
