//
//  TractCards+Gestures.swift
//  godtools
//
//  Created by Pablo Marti on 7/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCards {
    
    func setupSwipeGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
    }
    
    func setupPressGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePressGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        let frame = CGRect(x: 0.0,
                           y: self.height - TractCards.tapViewHeightConstant,
                           width: self.width,
                           height: TractCards.tapViewHeightConstant)
        self.tapView.frame = frame
        self.tapView.addGestureRecognizer(tapGesture)
        self.tapView.isUserInteractionEnabled = true
        self.addSubview(self.tapView)
    }
    
    @objc func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            self.lastCardOpened?.processSwipeUp()
        } else if sender.direction == .down {
            self.lastCardOpened?.processSwipeDown()
        }
    }
    
    @objc func handlePressGesture(sender: UITapGestureRecognizer) {
        self.lastCardOpened?.processSwipeUp()
    }
    
}
