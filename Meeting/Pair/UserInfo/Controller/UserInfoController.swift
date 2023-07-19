//
//  UserInfoController.swift
//  Meeting
//
//  Created by Деним Мержан on 30.06.23.
//

import Foundation
import UIKit

class UserInfoController: UIViewController, LoadPhoto {
    
    func userPhotoLoaded() {
        cardView.imageView.image = imageArr[cardView.indexCurrentImage].image
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightScrollView: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    lazy var cardView: CardView = {
        let cardView = CardView(imageArr: imageArr,frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 520))
        cardView.imageView.layer.cornerRadius = 0
        cardView.dataUser.isHidden = true
        cardView.gradient.removeFromSuperlayer()
        
        for progressView in cardView.progressBar {
            progressView.frame.origin.y = topSafeArea + 5
        }
        
        return cardView
    }()
    
    var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "DismissButton"), for: .normal)
        button.addTarget(self, action: #selector(dismissPreesed), for: .touchUpInside)
        return button
    }()
    
    var topSafeArea: CGFloat = {
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        
        guard let window = windowScene?.windows.first else {return 0}
        return window.safeAreaInsets.top
        
    }()
    
    
    lazy var dislikeButton = createButton(image: UIImage(named: "UserInfoDisLike"), selector: #selector(dislikePressed),size: CGSize(width: 90, height: 80))
    lazy var likeButton = createButton(image: UIImage(named: "UserInfoLike"), selector: #selector(dislikePressed),size: CGSize(width: 90, height: 80))
    lazy var superLikeButton = createButton(image: UIImage(named: "UserInfoSuperLike"), selector: #selector(dislikePressed),size: CGSize(width: 90, height: 80))
    
    
    var imageArr = [UserPhoto]()
    var collectionView: UICollectionView?
    var sections = CurrentUserDescription.shared.userData
    var tapGesture = UITapGestureRecognizer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapGesture.addTarget(self, action: #selector(cardTap(_:)))
        cardView.addGestureRecognizer(tapGesture)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: cardView.frame.height, width: self.view.frame.width, height: 900), collectionViewLayout: createLaoyut())
        collectionView?.isScrollEnabled = false
        collectionView?.register(UINib(nibName: "UserInfoCell", bundle: nil), forCellWithReuseIdentifier: "UserInfoCell")
        collectionView?.register(UINib(nibName: "TargetMeetingCell", bundle: nil), forCellWithReuseIdentifier: "TargetMeetingCell")
        collectionView?.register(Header.self, forSupplementaryViewOfKind: "Dr Stranger", withReuseIdentifier: "Header1")
        
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        scrollView.addSubview(cardView)
        scrollView.addSubview(collectionView!)
        scrollView.addSubview(dismissButton)
        
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: cardView.bottomAnchor,constant: -25).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -25).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        setupVisualBlurEffect()
        setupButton()
    }
    
    
    @objc func dismissPreesed(){
        self.dismiss(animated: true)
    }
    
    @objc func cardTap(_ sender: UITapGestureRecognizer){
        cardView.refreshPhoto(sender)
    }
    
    @objc func dislikePressed(){
        
    }
    

    
}

//MARK: - Create BlurEffect and Button

extension UserInfoController {

    
    private func createButton(image: UIImage?,selector:Selector,size: CGSize) -> UIButton {
        let button = UIButton(type: .system)
        button.frame.size = size
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        return button
    }
    
    private func setupButton(){
        
        let stackView = UIStackView(arrangedSubviews: [dislikeButton,superLikeButton,likeButton])
        stackView.backgroundColor = .orange
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        view.addSubview(stackView)
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -100).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
    }
    
    private func setupVisualBlurEffect(){
        
        let blurEffect =  UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.topAnchor,constant: topSafeArea).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
}


//MARK: - UICollectionViewCompositionalLayout

extension UserInfoController {
    
    private func createLaoyut() -> UICollectionViewCompositionalLayout {
        
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let section = self.sections[sectionNumber]
            
            switch section {
                
            case .mostDescription(let items):
                
                var itemArr = [NSCollectionLayoutItem]()
                for index in 0...items.count - 1 {
                    if index == items.count - 1 {
                        let item2 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(70)))
                        item2.contentInsets.top = 20
                        itemArr.append(item2)
                        break
                    }
                    let item1 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(34)))
                    item1.contentInsets.leading = -10
                    itemArr.append(item1)
                }
                
                let sizeGoup = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: sizeGoup, subitems: itemArr)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [
                    .init(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: "Dr Stranger", alignment: .topLeading)]
                section.contentInsets.leading = 16
                section.contentInsets.top = -2
                section.contentInsets.bottom = 17
                
                return section
                
            case .aboutME(_):
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets.leading = -10
                
                let sizeGoup = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: sizeGoup, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [
                    .init(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: "Dr Stranger", alignment: .topLeading)]
                section.contentInsets.leading = 16
                section.contentInsets.bottom = 17
                
                return section
                
            case .moreAboutMe,.lifeStyle, .myHobbie, .languages:
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(40), heightDimension: .absolute(32)))
                item.contentInsets.bottom = 7
                
                let sizeGoup = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: sizeGoup, subitems: [item])
                group.interItemSpacing = .fixed(7)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [
                    .init(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: "Dr Stranger", alignment: .topLeading)]
                section.contentInsets.leading = 16
                section.contentInsets.bottom = 10
                
                return section
                
            case .shareProfile, .banProfile:
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let sizeGoup = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: sizeGoup, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [
                    .init(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), elementKind: "Dr Stranger", alignment: .topLeading)]
                section.contentInsets.leading = 16
                section.contentInsets.top = -5
                section.contentInsets.bottom = 10
                
                return section
            }
            
        }
        
        return layout
    }
    
    
}


//MARK: - UICollectionViewDelegeate and DataSource

extension UserInfoController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: "Dr Stranger", withReuseIdentifier: "Header1", for: indexPath) as! Header
        self.collectionView?.addSubview(header.separatorView)
        
        switch sections[indexPath.section] {case .mostDescription(_):
            let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 35), NSAttributedString.Key.foregroundColor : UIColor.black]
            let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 35), NSAttributedString.Key.foregroundColor : UIColor.black]
            let attributedString1 = NSMutableAttributedString(string:"Сашенька", attributes:attrs1)
            let attributedString2 = NSMutableAttributedString(string:" 24", attributes:attrs2)
            attributedString1.append(attributedString2)
            header.label.attributedText = attributedString1
            header.separatorView.isHidden = true
        case .aboutME(_):
            header.label.text = "Обо мне"
        case .moreAboutMe(_):
            header.label.text = "Больше обо мне"
        case .lifeStyle:
            header.label.text = "Стиль Жизни"
        case .myHobbie(_):
            header.label.text = "Мои интересы"
        case .languages(_):
            header.label.text = "Языки которые я знаю"
        case .shareProfile(_):
            header.tapGesture.addTarget(self, action: #selector(shareProfile))
            header.label.textColor = UIColor(named: "UserInfo")
            header.label.text = "Поделиться профилем"
            header.label.textAlignment = .center
        case .banProfile(_):
            header.tapGesture.addTarget(self, action: #selector(banProfile))
            header.label.textColor = UIColor(named: "UserInfo")
            header.label.text = "Пожаловаться"
            header.label.textAlignment = .center
        }
        
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let countItem = sections[section].countItem else {return 0}
        return countItem
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
        
        switch sections[indexPath.section] {
            
        case .mostDescription(let mostDescrtiption):
            
            cell.image.isHidden = false
            cell.image.image = mostDescrtiption[indexPath.row].image
            cell.label.text = mostDescrtiption[indexPath.row].title
            cell.label.textAlignment = .left
            cell.label.textColor = UIColor(named: "ColorGray")
            cell.label.font = .systemFont(ofSize: 14)
            
            if indexPath.row == sections[indexPath.section].countItem! - 1 {
                let targetMeetingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TargetMeetingCell", for: indexPath) as! TargetMeetingCell
                targetMeetingCell.image.image = mostDescrtiption[indexPath.row].image
                targetMeetingCell.targetMeeting.text = mostDescrtiption[indexPath.row].title
                targetMeetingCell.layer.cornerRadius = 10
                targetMeetingCell.clipsToBounds = true
                return targetMeetingCell
            }
        case .aboutME(let aboutMe):
            
            cell.label.text = aboutMe
            cell.label.textAlignment = .left
            cell.label.textColor = UIColor(named: "ColorGray")
            cell.label.font = .systemFont(ofSize: 14)
            cell.label.lineBreakMode = .byWordWrapping
            cell.label.numberOfLines = 0
        case .moreAboutMe(let item),.lifeStyle(let item), .myHobbie(let item),.languages(let item):
            
            cell.image.isHidden = false
            cell.image.image = item[indexPath.row].image
            cell.layer.cornerRadius = 13
            cell.layer.masksToBounds = true
            cell.label.frame = cell.bounds
            cell.label.text = item[indexPath.row].title
            cell.label.textAlignment = .center
            cell.label.font = .systemFont(ofSize: 12)
            cell.label.textColor = UIColor(named: "ColorGray")
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            cell.label.lineBreakMode = .byWordWrapping
            cell.label.numberOfLines = 1
            
        case .banProfile(let text),.shareProfile(let text):
            
            cell.layer.cornerRadius = 20
            cell.layer.masksToBounds = true
            cell.label.frame = cell.bounds
            cell.label.text = text
            cell.label.textAlignment = .center
            cell.label.font = .systemFont(ofSize: 12)
            cell.label.textColor = UIColor(named: "ColorGray")
            cell.label.lineBreakMode = .byWordWrapping
            cell.label.numberOfLines = 1
            
        }
        heightScrollView.constant = collectionView.collectionViewLayout.collectionViewContentSize.height + cardView.frame.height + 80 /// Обновляем высоту ScrollView  в зависимости от внутреннего размера CollectionView
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let changeY = scrollView.contentOffset.y
        if changeY < 0 {
            cardView.imageView.frame = CGRect(x: changeY, y: changeY, width: view.frame.width + abs(changeY) * 1.5, height: 520 + abs(changeY) * 1.5)
        }
    }
    
}
//MARK: -  Поделиться и пожаловаться на пользователя

extension UserInfoController {
    
    @objc func shareProfile(){
        print("Share")
    }
    
    @objc func banProfile(){
        print("Ban")
    }
}
