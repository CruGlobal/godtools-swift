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
        if sender.direction == .right {
            print("New gesture")
            moveToPreviousPage()
        } else if sender.direction == .left {
            moveToNextPage()
        }
    }
    
}
