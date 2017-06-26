//
//  CardsAnimations.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCards {
    
    func transformToOpenUpCardsWithouAnimation() {
        self.isOnInitialPosition = false
        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos)
    }
    
    func transformToOpenUpCardsAnimation() {
        self.isOnInitialPosition = false
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: nil )
    }
    
    func transformToInitialPositionAnimation() {
        self.isOnInitialPosition = true
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: nil )
    }
    
}
