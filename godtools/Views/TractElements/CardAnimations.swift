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
    
    func showCard() {
        if self.cardState == .open {
            return
        }
        
        self.cardState = .open
        
        self.cardsParentView.setEnvironmentForDisplayingCard(self)
        
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
        if self.cardState == .close {
            return
        }
        
        self.cardState = .close
        
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
