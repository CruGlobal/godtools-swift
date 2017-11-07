//
//  TractHeaderAnimations.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractHeader {
    
    func showHeaderWithoutAnimation() {
        self.currentAnimation = .none
        self.transform = CGAffineTransform(translationX: 0, y: 0.0)
    }
    
    func hideHeaderWithoutAnimation() {
        self.currentAnimation = .hide
        let translationY = -self.elementFrame.y - self.height
        self.transform = CGAffineTransform(translationX: 0, y: translationY)
    }
    
    func showHeader() {
        self.currentAnimation = .none
        UIView.animate(withDuration: 0.30,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0.0) },
                       completion: nil )
    }
    
    func hideHeader() {
        self.currentAnimation = .hide
        let translationY = -self.elementFrame.y - self.height + TractPage.statusbarHeight
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
    }
    
}
