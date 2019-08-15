//
//  TractViewControllerGestures.swift
//  godtools
//
//  Created by Devserker on 5/30/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractViewController {
    
    func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right && !isRightToLeft {
            NotificationCenter.default.post(name: .moveToPreviousPageNotification, object: nil, userInfo: nil)
        } else if sender.direction == .left && !isRightToLeft {
            NotificationCenter.default.post(name: .moveToNextPageNotification, object: nil, userInfo: nil)
        }
        else if sender.direction == .right && isRightToLeft {
            NotificationCenter.default.post(name: .moveToNextPageNotification, object: nil, userInfo: nil)
        } else if sender.direction == .left && isRightToLeft {
            NotificationCenter.default.post(name: .moveToPreviousPageNotification, object: nil, userInfo: nil)
        }
    }
}
