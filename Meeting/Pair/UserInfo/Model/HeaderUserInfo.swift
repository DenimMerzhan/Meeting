

import UIKit

class Header:UICollectionReusableView {
    
    let label = UILabel()
    let separatorView = UIView()
    let tapGesture = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        separatorView.backgroundColor = .gray.withAlphaComponent(0.5)
        self.addGestureRecognizer(tapGesture)
        self.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = self.bounds
        separatorView.frame =  CGRect(x: 0, y: frame.origin.y, width: frame.width + 16, height: 1)
    }
    
    
}
