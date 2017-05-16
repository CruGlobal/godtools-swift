//
//  CardAnimations.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension Card {
    
    func showCardAndPreviousCards() {
        if self.cardState == .open {
            return
        }
        
        self.cardsParentView.setEnvironmentForDisplayingCard(self)
        showCard()
    }
    
    func showCard() {
        if self.cardState == .open {
            return
        }
        
        if self.cardState == .hidden {
            self.isHidden = false
            self.cardState = .enable
        } else {
            self.cardState = .open
        }
        
        let translationY = Card.yTopMarginConstant - self.yPosition
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
        
        enableScrollview()
    }
    
    func hideCard() {
        if self.cardState == .close || self.cardState == .hidden || self.cardState == .enable {
            return
        }
        
        self.cardState = .close
        self.cardsParentView.hideCallToAction()
        
        let translationY = self.yDownPosition
        UIView.animate(withDuration: 0.45,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: { (completed) in
                        if completed {
                            if self.cardNumber == 0 {
                                self.cardsParentView.resetEnvironment()
                            }
                        }})
        
        disableScrollview()
    }
    
    func resetCard() {
        if self.cardState == .preview {
            return
        }
        
        self.cardState = .preview
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
        
        disableScrollview()
    }
    
}
