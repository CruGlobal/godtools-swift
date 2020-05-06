//
//  TractCardsActions.swift
//  godtools
//
//  Created by Devserker on 5/17/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractCards {
    
    // MARK: - Animations for the cards inside of the Cards container
    
    func setEnvironmentForDisplayingCard(_ card: TractCard) {
        changeToOpenCards()
        
        var foundCard = false
        
        for element in elements! {
            let elementCard = element as! TractCard
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
        
        if card == self.lastCard {
            showCallToAction()
        } else {
            hideCallToAction()
        }
    }
    
    func resetEnvironment() {
        changeToPreviewCards()
        self.lastCardOpened = nil
        
        for element in elements! {
            let elementCard = element as! TractCard
            elementCard.resetCard()
        }
    }
    
    func showFollowingCardToCard(_ card: TractCard) {
        var foundCard = false
        
        for element in elements! {
            let elementCard = element as! TractCard
            if card == elementCard {
                foundCard = true
                continue
            }
            if foundCard {
                elementCard.showCard()
                
                
                if elementCard == self.lastCard {
                    showCallToAction()
                } else {
                    hideCallToAction()
                }
                
                break
            }
        }
    }
    
    func showCallToAction(animated: Bool = true) {
        let pageView = self.page
        pageView?.showCallToAction(animated: animated)
    }
    
    func hideCallToAction() {
        let pageView = self.page
        pageView?.hideCallToAction()
    }
    
    // MARK: - Animations for the Cards container and the Header
    
    func changeToOpenCards() {
        let properties = cardsProperties()
        
        if properties.cardsState == .open {
            return
        }
        
        properties.cardsState = .open
        
        let pageView = self.page
        pageView?.hideHeader()
        transformToOpenUpCardsAnimation()
    }
    
    func changeToPreviewCards() {
        let properties = cardsProperties()
        
        if properties.cardsState == .preview {
            return
        }
        
        properties.cardsState = .preview
        
        let pageView = self.page
        pageView?.showHeader()
        transformToInitialPositionAnimation()
    }
    
}
