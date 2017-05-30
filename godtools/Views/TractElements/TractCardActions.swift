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
        if self.cardState == .preview || self.cardState == .close {
            showCardAndPreviousCards()
        } else if self.cardState == .open {
            self.cardsParentView.showFollowingCardToCard(self)
        }
    }
    
    func processSwipeDown() {
        if self.cardState == .open || self.cardState == .enable {
            hideCard()
        }
    }
    
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
        
        if isHiddenKindCard() {
            setStateEnable()
        } else {
            setStateOpen()
        }
        
        showCardAnimation()
        enableScrollview()
    }
    
    func hideCard() {
        if self.cardState == .close || self.cardState == .hidden {
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
    
    func resetCard() {
        if self.cardState == .preview {
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
        if self.cardState != .open {
            let startPoint = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
            self.scrollView.isScrollEnabled = false
            self.scrollView.setContentOffset(startPoint, animated: true)
        }
    }
    
    func enableScrollview() {
        if self.cardState == .open {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    // MARK: - Management of card state
    
    fileprivate func isHiddenKindCard() -> Bool {
        return self.cardState == .hidden || self.cardState == .enable
    }
    
    fileprivate func setStateOpen() {
        if self.cardState == .preview || self.cardState == .close {
            self.cardState = .open
        }
    }
    
    fileprivate func setStateClose() {
        if self.cardState == .open || self.cardState == .preview {
            self.cardState = .close
        }
    }
    
    fileprivate func setStateHidden() {
        if self.cardState == .enable {
            self.cardState = .hidden
        }
    }
    
    fileprivate func setStateEnable() {
        if self.cardState == .hidden {
            self.isHidden = false
            self.cardState = .enable
        }
    }
    
    fileprivate func setStatePreview() {
        if self.cardState == .open || self.cardState == .close {
            self.cardState = .preview
        }
    }
    
}
