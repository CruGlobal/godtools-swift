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
        
        if card == elements?.last {
            showCallToAction()
        } else {
            hideCallToAction()
        }
    }
    
    func resetEnvironment() {
        changeToPreviewCards()
        
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
                
                
                if elementCard == elements?.last {
                    showCallToAction()
                } else {
                    hideCallToAction()
                }
                
                break
            }
        }
    }
    
    func showCallToAction() {
        let pageView = self.parent as! TractPage
        pageView.showCallToAction()
    }
    
    func hideCallToAction() {
        let pageView = self.parent as! TractPage
        pageView.hideCallToAction()
    }
    
    // MARK: - Animations for the Cards container and the Header
    
    func changeToOpenCards() {
        if self.properties.cardsState == .open {
            return
        }
        
        self.properties.cardsState = .open
        
        let pageView = self.parent as! TractPage
        pageView.hideHeader()
        transformToOpenUpCardsAnimation()
    }
    
    func changeToPreviewCards() {
        if self.properties.cardsState == .preview {
            return
        }
        
        self.properties.cardsState = .preview
        
        let pageView = self.parent as! TractPage
        pageView.showHeader()
        transformToInitialPositionAnimation()
    }
    
}
