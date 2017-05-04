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
    
    func hideCardsExcept(card: Card) {
        let rootView = self.parent as! TractRoot
        rootView.hideHeader()
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: -self.yPosition) },
                       completion: nil )
        
        for element in elements! {
            let elementCard = element as! Card
            if card != elementCard {
                elementCard.hideCard()
            }
        }
    }
    
    func showCardsExcept(card: Card) {
        let rootView = self.parent as! TractRoot
        rootView.showHeader()
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0.0) },
                       completion: nil )
        
        for element in elements! {
            let elementCard = element as! Card
            if card != elementCard {
                elementCard.resetCard()
            }
        }
    }
    
}
