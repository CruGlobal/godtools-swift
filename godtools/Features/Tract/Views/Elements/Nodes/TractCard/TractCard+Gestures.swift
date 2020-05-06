//
//  CardGestures.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCard {
    
    func setupSwipeGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            processSwipeUp()
        } else if sender.direction == .down {
            processSwipeDown()
        }
    }
    
}

extension TractCard : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: self.superview)
        let scrollOffset = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        
        if translation.y > 0 {
            if scrollOffset == 0 {
                hideCard()
            }
        } else {
            if scrollOffset + scrollViewHeight == scrollContentSizeHeight {
                self.cardsParentView.showFollowingCardToCard(self)
            }
        }
    }
    
}
