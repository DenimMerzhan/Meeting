//
//  CustomScrollView.swift
//  Meeting
//
//  Created by Деним Мержан on 25.05.23.
//

import Foundation
import UIKit

class CustomScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
