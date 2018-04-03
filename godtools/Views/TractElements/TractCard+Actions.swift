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
    
    override func receiveDismissMessage() {
        hideCard()
    }
    
    func processSwipeUp() {
        let properties = cardProperties()
        if properties.cardState == .preview || properties.cardState == .close {
            showCardAndPreviousCards()
        } else if properties.cardState == .open {
            self.cardsParentView.showFollowingCardToCard(self)
        }
    }
    
    func processSwipeDown() {
        let properties = cardProperties()
        
        if properties.cardState == .open || properties.cardState == .enable {
            hideCard()
        }
    }
    
    func processCardWithState() {
        let properties = cardProperties()
        
        switch properties.cardState {
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
        let relay = AnalyticsRelay.shared
        relay.timer.invalidate()
        relay.isTimerRunning = false
        let properties = cardProperties()
        
        if properties.cardState == .open {
            return
        }
        
        self.cardsParentView.setEnvironmentForDisplayingCard(self)
        showCard()
        
        if !relay.isTimerRunning {
            relay.timerCounter = 6
            relay.runTimer()
        }
        
        let cardName = properties.cardLetterName
        let tractPlusCardName = "\(relay.tractName)\(cardName)"
        relay.tractPlusCardName = tractPlusCardName
        
        // TODO - This isn't quite tracking correct values. It's appending letters and not replacing???
        
        //sendScreenViewNotification(screenName: tractPlusCardName)
    }
    
    func showCard() {
        let properties = cardProperties()
        if properties.cardState == .open {
            return
        }
        
        if isHiddenKindCard() {
            setStateEnable()
        } else {
            setStateOpen()
        }
        
        showTexts()
        showCardAnimation()
        enableScrollview()
        
        self.cardsParentView.lastCardOpened = self
    }
    
    func hideCard() {
        let properties = cardProperties()
        
        if properties.cardState == .close || properties.cardState == .hidden {
            return
        }
        
        if isHiddenKindCard() {
            setStateHidden()
        } else {
            setStateClose()
        }
        
        hideTexts()
        self.cardsParentView.hideCallToAction()
        hideCardAnimation()
        disableScrollview()
    }
    
    func hideAllCards() {
        let properties = cardProperties()
        
        if properties.cardState == .close || properties.cardState == .hidden {
            return
        }
        
        hideTexts()
        self.cardsParentView.resetEnvironment()
        self.cardsParentView.hideCallToAction()
    }
    
    func resetCard() {
        let properties = cardProperties()
        
        if properties.cardState == .preview {
            return
        }
        
        if isHiddenKindCard() {
            setStateHidden()
        } else {
            setStatePreview()
        }
        
        hideTexts()
        resetCardToOriginalPositionAnimation()
        disableScrollview()
    }
    
    func showTexts() {
        for element in self.elements! {
            if BaseTractElement.isLabelElement(element) {
                continue
            }
            
            element.isHidden = false
        }
    }
    
    func hideTexts() {
        for element in self.elements! {
            if BaseTractElement.isLabelElement(element) {
                continue
            }
            
            element.isHidden = true
        }
    }
    
    // MARK: - ScrollView
    
    func disableScrollview() {
        let properties = cardProperties()
        
        if properties.cardState != .open && properties.cardState != .enable {
            let startPoint = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
            self.scrollView.isScrollEnabled = false
            self.scrollView.setContentOffset(startPoint, animated: true)
        }
    }
    
    func enableScrollview() {
        let properties = cardProperties()
        
        if properties.cardState == .open || properties.cardState == .enable {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    // MARK: - Management of card state
    
    fileprivate func isHiddenKindCard() -> Bool {
        let properties = cardProperties()
        
        return properties.cardState == .hidden || properties.cardState == .enable
    }
    
    fileprivate func setStateOpen() {
        let properties = cardProperties()
        
        if properties.cardState == .preview || properties.cardState == .close {
            properties.cardState = .open
        }
    }
    
    fileprivate func setStateClose() {
        let properties = cardProperties()
        
        if properties.cardState == .open || properties.cardState == .preview {
            properties.cardState = .close
        }
    }
    
    fileprivate func setStateHidden() {
        let properties = cardProperties()
        
        if properties.cardState == .enable {
            properties.cardState = .hidden
        }
    }
    
    fileprivate func setStateEnable() {
        let properties = cardProperties()
        
        if properties.cardState == .hidden {
            self.isHidden = false
            properties.cardState = .enable
        }
    }
    
    fileprivate func setStatePreview() {
        let properties = cardProperties()
        
        if properties.cardState == .open || properties.cardState == .close {
            properties.cardState = .preview
        }
    }
    
    // MARK - Analytics helper
    
    func sendScreenViewNotification(screenName: String) {
        let userInfo = [GTConstants.kAnalyticsScreenNameKey: screenName]
        NotificationCenter.default.post(name: .screenViewNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
}
