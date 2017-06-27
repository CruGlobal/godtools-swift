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
    
    func openingAnimation() {
        let yTransformation: CGFloat = -50.0
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: yTransformation) },
                       completion: { finished in
                        self.closingAnimation()
        } )
        
    }
    
    func closingAnimation() {
        let yTransformation: CGFloat = 0.0
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: yTransformation) },
                       completion: nil )
    }
    
    func showCardWithoutAnimation() {
        self.currentAnimation = .show
        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos)
    }
    
    func hideCardWithoutAnimation() {
        self.currentAnimation = .hide
        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos)
    }
    
    func resetCardToOriginalPositionWithoutAnimation() {
        self.currentAnimation = .none
        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos)
    }
    
    func showCardAnimation() {
        self.currentAnimation = .show
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: nil )
    }
    
    func hideCardAnimation() {
        self.currentAnimation = .hide
        let properties = cardProperties()
        UIView.animate(withDuration: 0.45,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: { (completed) in
                        if completed {
                            if properties.cardNumber == 0 {
                                self.cardsParentView.resetEnvironment()
                            }
                            
                            if properties.cardState == .hidden {
                                self.isHidden = true
                            }
                        }})
    }
    
    func resetCardToOriginalPositionAnimation() {
        self.currentAnimation = .none
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: nil )
    }
    
}
