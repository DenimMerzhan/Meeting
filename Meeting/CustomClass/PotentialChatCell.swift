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
    
    var loadIndicator = UIActivityIndicatorView(frame: .zero)
    
    var chatID = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        loadIndicator.frame.size = avatar.frame.size
        loadIndicator.backgroundColor = .gray
        loadIndicator.style = UIActivityIndicatorView.Style.large
        loadIndicator.startAnimating()
        loadIndicator.hidesWhenStopped = true
        avatar.addSubview(loadIndicator)
        
        avatar.layer.cornerRadius = 5
        avatar.clipsToBounds = true
        
        name.minimumScaleFactor = 0.5
        name.adjustsFontSizeToFitWidth = true
    }

}
