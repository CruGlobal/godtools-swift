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
    
    static let bounceDecayFactor: CGFloat = 0.2
    static let bounceCycles = 3
    static let numberOfBounces = 2
    static let secondsBetweenCycles: Double = 0.6
    static let bounceDuration: Double = 0.15
    
    func openingAnimation(yTransformation: CGFloat = -50.0, delay: Double = 0.0, cycleNumber: Int = 1, bounceNumber: Int = 1 ) {
        UIView.animate(withDuration: TractCard.bounceDuration,
                       delay: delay,
                       options: .curveEaseOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: yTransformation) },
                       completion: { finished in
                        self.closingAnimation(cycleNumber: cycleNumber,
                                              bounceNumber: bounceNumber,
                                              yOpeningTransformation: yTransformation)
        } )
    }
    
    func closingAnimation(cycleNumber: Int, bounceNumber: Int, yOpeningTransformation: CGFloat) {
        let yTransformation: CGFloat = 0.0
        UIView.animate(withDuration: TractCard.bounceDuration,
                       delay: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: yTransformation) },
                       completion: { finished in
                        
                        if bounceNumber < TractCard.numberOfBounces {
                            self.openingAnimation(yTransformation: yOpeningTransformation * TractCard.bounceDecayFactor,
                                                  delay: 0.1,
                                                  cycleNumber: cycleNumber,
                                                  bounceNumber: bounceNumber + 1)
                        } else if cycleNumber < TractCard.bounceCycles {
                            self.openingAnimation(delay: TractCard.secondsBetweenCycles,
                                                  cycleNumber: cycleNumber + 1)
                        }
                        
        })
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
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: nil )
    }
    
    func hideCardAnimation() {
        self.currentAnimation = .hide
        let properties = cardProperties()
        UIView.animate(withDuration: 0.45,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
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
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: nil )
    }
    
    func moveViewForPresentingKeyboardAnimation() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: TractCard.keyboardYTransformation) },
                       completion: nil )
    }
    
    func moveViewForDismissingKeyboardAnimation() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
    }
    
}
