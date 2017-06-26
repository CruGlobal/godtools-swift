//
//  CallToActionAnimations.swift
//  godtools
//
//  Created by Devserker on 5/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCallToAction {
    
    func showCallToActionWithoutAnimation() {
        self.currentAnimation = .show
        let translationY = self.parent!.getMaxHeight() - self.elementFrame.finalY() - self.height
        self.transform = CGAffineTransform(translationX: 0, y: translationY)
    }
    
    func hideCallToActionWithoutAnimation() {
        self.currentAnimation = .none
        self.transform = CGAffineTransform(translationX: 0, y: 0.0)
    }
    
    func showCallToActionAnimation() {
        self.currentAnimation = .show
        let translationY = self.parent!.getMaxHeight() - self.elementFrame.finalY() - self.height
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
    }
    
    func hideCallToActionAnimation() {
        self.currentAnimation = .none
        UIView.animate(withDuration: 0.30,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0.0) },
                       completion: nil )
    }
    
}
