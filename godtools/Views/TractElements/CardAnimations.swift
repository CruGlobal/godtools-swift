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
        
        let cardsView = self.parent as! Cards
        cardsView.setEnvironmentForDisplayingCard(self)
        
        let translationY = Card.yTopMarginConstant - self.yPosition
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
    }
    
    func hideCard() {
        if self.cardState == .close {
            return
        }
        
        let translationY = self.yDownPosition
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
    }
    
    func resetCard() {
        let cardsView = self.parent as! Cards
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
        cardsView.showCardsExcept(card: self)
    }
    
}
