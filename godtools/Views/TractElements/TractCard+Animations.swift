//
//  CardAnimations.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCard {
    
    func showCardAnimation() {
        let translationY = TractCard.yTopMarginConstant - self.elementFrame.y
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
    }
    
    func hideCardAnimation() {
        let translationY = self.yDownPosition
        UIView.animate(withDuration: 0.45,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: { (completed) in
                        if completed {
                            if self.properties.cardNumber == 0 {
                                self.cardsParentView.resetEnvironment()
                            }
                            
                            if self.properties.cardState == .hidden {
                                self.isHidden = true
                            }
                        }})
    }
    
    func resetCardToOriginalPositionAnimation() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
    }
    
}
