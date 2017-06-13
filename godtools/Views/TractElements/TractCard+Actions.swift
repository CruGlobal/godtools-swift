//
//  TractCardActions.swift
//  godtools
//
//  Created by Devserker on 5/17/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCard {
    
    override func receiveMessage() {
        if isHiddenKindCard() {
            showCard()
        }
    }
    
    func processSwipeUp() {
        if self.properties.cardState == .preview || self.properties.cardState == .close {
            showCardAndPreviousCards()
        } else if self.properties.cardState == .open {
            self.cardsParentView.showFollowingCardToCard(self)
        }
    }
    
    func processSwipeDown() {
        if self.properties.cardState == .open || self.properties.cardState == .enable {
            hideCard()
        }
    }
    
    func processCardWithState() {
        switch self.properties.cardState {
        case .preview:
            showCardAndPreviousCards()
        case .open:
            hideAllCards()
        case .close:
            showCardAndPreviousCards()
        case .enable:
            hideCard()
        default: break
        }
    }
    
    func showCardAndPreviousCards() {
        if self.properties.cardState == .open {
            return
        }
        
        self.cardsParentView.setEnvironmentForDisplayingCard(self)
        showCard()
    }
    
    func showCard() {
        if self.properties.cardState == .open {
            return
        }
        
        if isHiddenKindCard() {
            setStateEnable()
        } else {
            setStateOpen()
        }
        
        showCardAnimation()
        enableScrollview()
    }
    
    func hideCard() {
        if self.properties.cardState == .close || self.properties.cardState == .hidden {
            return
        }
        
        if isHiddenKindCard() {
            setStateHidden()
        } else {
            setStateClose()
        }
        
        self.cardsParentView.hideCallToAction()
        hideCardAnimation()
        disableScrollview()
    }
    
    func hideAllCards() {
        if self.properties.cardState == .close || self.properties.cardState == .hidden {
            return
        }
        
        self.cardsParentView.resetEnvironment()
        self.cardsParentView.hideCallToAction()
    }
    
    func resetCard() {
        if self.properties.cardState == .preview {
            return
        }
        
        if isHiddenKindCard() {
            setStateHidden()
        } else {
            setStatePreview()
        }
        
        resetCardToOriginalPositionAnimation()
        disableScrollview()
    }
    
    // MARK: - ScrollView
    
    func disableScrollview() {
        if self.properties.cardState != .open {
            let startPoint = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
            self.scrollView.isScrollEnabled = false
            self.scrollView.setContentOffset(startPoint, animated: true)
        }
    }
    
    func enableScrollview() {
        if self.properties.cardState == .open {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    // MARK: - Management of card state
    
    fileprivate func isHiddenKindCard() -> Bool {
        return self.properties.cardState == .hidden || self.properties.cardState == .enable
    }
    
    fileprivate func setStateOpen() {
        if self.properties.cardState == .preview || self.properties.cardState == .close {
            self.properties.cardState = .open
        }
    }
    
    fileprivate func setStateClose() {
        if self.properties.cardState == .open || self.properties.cardState == .preview {
            self.properties.cardState = .close
        }
    }
    
    fileprivate func setStateHidden() {
        if self.properties.cardState == .enable {
            self.properties.cardState = .hidden
        }
    }
    
    fileprivate func setStateEnable() {
        if self.properties.cardState == .hidden {
            self.isHidden = false
            self.properties.cardState = .enable
        }
    }
    
    fileprivate func setStatePreview() {
        if self.properties.cardState == .open || self.properties.cardState == .close {
            self.properties.cardState = .preview
        }
    }
    
}
