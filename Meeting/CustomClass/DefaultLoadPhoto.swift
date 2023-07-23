//
//  DefaultChatCell.swift
//  Meeting
//
//  Created by Деним Мержан on 25.06.23.
//

import UIKit

class DefaultLoadPhoto: UIImageView {

    let loadIndicator = UIActivityIndicatorView(frame: .zero)
    

    override var image: UIImage? {
        didSet {
            if image != nil {
                loadIndicator.stopAnimating()
                self.backgroundColor = .clear
            }else {
                loadIndicator.startAnimating()
                self.backgroundColor = UIColor(named: "GrayColor")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView(){
        
        loadIndicator.frame.size = self.frame.size
        loadIndicator.center.x = self.frame.width / 2
        loadIndicator.center.y = self.frame.height / 2
        loadIndicator.style = UIActivityIndicatorView.Style.large
        loadIndicator.startAnimating()
        loadIndicator.hidesWhenStopped = true
        
        self.addSubview(loadIndicator)
    }
    
}
