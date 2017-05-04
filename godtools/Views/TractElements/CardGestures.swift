//
//  CardGestures.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension Card {
    
    func setupSwipeGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
    }
    
    func handleGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            showCard()
        } else if sender.direction == .down {
            hideCard()
        }
    }
    
}
