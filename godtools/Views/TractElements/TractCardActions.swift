//
//  TractCardActions.swift
//  godtools
//
//  Created by Devserker on 5/17/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractCard {
    
    override func receiveMessage() {
        if self.cardState == .hidden {
            showCard()
        }
    }
    
    func processSwipeUp() {
        if self.cardState == .preview || self.cardState == .close {
            showCardAndPreviousCards()
        } else {
            self.cardsParentView.showFollowingCardToCard(self)
        }
    }
    
    func processSwipeDown() {
        if self.cardState == .open || self.cardState == .enable {
            hideCard()
        }
    }
    
    // MARK: - Card State Management
    
    func processCardWithState() {
        switch self.cardState {
        case .preview:
            showCardAndPreviousCards()
        case .open:
            hideCard()
        case .close:
            showCardAndPreviousCards()
        case .enable:
            hideCard()
        default: break
        }
    }
    
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
        
        showCardAnimation()
        enableScrollview()
    }
    
    func hideCard() {
        if self.cardState == .close || self.cardState == .hidden {
            return
        }
        
        if self.cardState == .enable {
            self.cardState = .hidden
        } else {
            self.cardState = .close
            self.cardsParentView.hideCallToAction()
        }
        
        hideCardAnimation()
        disableScrollview()
    }
    
    func resetCard() {
        if self.cardState == .preview {
            return
        }
        
        self.cardState = .preview
        
        resetCardToOriginalPositionAnimation()
        disableScrollview()
    }
    
}
