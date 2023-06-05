//
//  CollectionPhotoCell.swift
//  Meeting
//
//  Created by Деним Мержан on 04.06.23.
//

import UIKit

class PotentialChatCell: UICollectionViewCell {

    

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.cornerRadius = 5
        avatar.clipsToBounds = true
        
        name.minimumScaleFactor = 0.5
        name.adjustsFontSizeToFitWidth = true
    }

}
