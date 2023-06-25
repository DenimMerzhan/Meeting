//
//  TableViewCell.swift
//  Meeting
//
//  Created by Деним Мержан on 04.06.23.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var countUnreadMessageView: UIView!
    @IBOutlet weak var countUnreadMessageLabel: UILabel!
    
    var banImage = UIImage()
    var deleteImage = UIImage()
    var loadIndicator = UIActivityIndicatorView(frame: .zero)
    
    var userID = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadIndicator.frame.size = avatar.frame.size
        loadIndicator.backgroundColor = .gray
        loadIndicator.style = UIActivityIndicatorView.Style.large
        loadIndicator.startAnimating()
        loadIndicator.hidesWhenStopped = true
        avatar.addSubview(loadIndicator)
        
        banImage = createBanImage()
        deleteImage = createDeleteImage()
        
        countUnreadMessageView.layer.cornerRadius = countUnreadMessageView.frame.width / 2
        countUnreadMessageView.clipsToBounds = true
        countUnreadMessageView.alpha = 0.6
        
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
        commentLabel.textColor = .gray
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    override func prepareForReuse() {
        countUnreadMessageView.isHidden = true
    }
    
}
    



//MARK: - Создание Image для кнопок удаления и жалобы

extension ChatCell {
    
    
    func createBanImage() -> UIImage {
        
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 100))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 20, width: 25, height: 25))
        
        imageView.center.x = view.center.x
        imageView.image = UIImage(named: "BanImage")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: 60, height: 40))
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Пожаловаться"
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.backgroundColor = .clear
        
        return view.asImage()
    }
    
    func createDeleteImage() -> UIImage {
        
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 100))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 20, width: 20, height: 20))
        
        imageView.center.x = view.center.x
        imageView.image = UIImage(named: "DeleteChatUser")?.withTintColor(.white)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: 60, height: 40))
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Удалить из пар"
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.backgroundColor = .clear
        
        return view.asImage()
        
    }
    
}
