//
//  CardsAnimations.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension Cards {
    
    func setEnvironmentForDisplayingCard(_ card: Card) {
        changeToOpenCards()
        
        var foundCard = false
        
        for element in elements! {
            let elementCard = element as! Card
            if card != elementCard {
                if foundCard {
                    elementCard.hideCard()
                } else {
                    elementCard.showCard()
                }
            } else {
                foundCard = true
            }
        }
    }
    
    func hideCardsExcept(card: Card) {
        for element in elements! {
            let elementCard = element as! Card
            if card != elementCard {
                elementCard.hideCard()
            }
        }
    }
    
    func changeToOpenCards() {
        if self.cardsState == .open {
            return
        }
        
        let rootView = self.parent as! TractRoot
        rootView.hideHeader()
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: -self.yPosition) },
                       completion: nil )
    }
    
    func changeToPreviewCards() {
        if self.cardsState == .preview {
            return
        }
        
        let rootView = self.parent as! TractRoot
        rootView.showHeader()
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0.0) },
                       completion: nil )
    }
    
}
