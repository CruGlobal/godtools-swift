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
    
    func moveViewForPresentingKeyboardAnimation() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: TractCard.keyboardYTransformation) },
                       completion: nil )
    }
    
    func moveViewForDismissingKeyboardAnimation() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
    }
    
}
