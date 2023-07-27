//
//  CustomCell1CollectionViewCell.swift
//  test
//
//  Created by Деним Мержан on 03.07.23.
//

import UIKit

class UserInfoCell: UICollectionViewCell {

    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image.isHidden = true
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        
    }
    
    override func prepareForReuse() {
        image.isHidden = true
    }

}

