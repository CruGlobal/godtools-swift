//
//  TractCard.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractCard: BaseTractElement {
    
    enum CardAnimationState {
        case show, hide, none
    }
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 12.0
    static let shadowPaddingConstant: CGFloat = 2.0
    static let yTopMarginConstant: CGFloat = 8.0
    static let yBottomMarginConstant: CGFloat = 120.0
    static let xPaddingConstant: CGFloat = 28.0
    static let contentBottomPadding: CGFloat = 8.0
    static let transparentViewHeight: CGFloat = 60.0
    static let keyboardYTransformation: CGFloat = -80.0
    
    // MARK: - Positions and Sizes
    
    var yDownPosition: CGFloat = 0.0
    
    var externalHeight: CGFloat {
        return (self.parent?.height)! - TractCard.yTopMarginConstant - TractCard.yBottomMarginConstant - TractPage.navbarHeight
    }
    
    var internalHeight: CGFloat {
        if self.height > self.externalHeight {
            return self.height + TractCard.transparentViewHeight + TractCard.contentBottomPadding
        } else {
            return self.externalHeight
        }
    }
    
    var translationY: CGFloat {
        return self.externalHeight - self.elementFrame.y
    }
    
    // MARK: - Object properties
    
    var shadowView = UIView()
    let scrollView = UIScrollView()
    let backgroundView = UIView()
    let containerView = UIView()
    var cardsParentView: TractCards {
        return self.parent as! TractCards
    }
    var currentAnimation: TractCard.CardAnimationState = .none
    var animationYPos: CGFloat {
        switch self.currentAnimation {
        case .show:
            return TractCard.yTopMarginConstant - self.elementFrame.y
        case .hide:
            return self.yDownPosition
        case .none:
            return 0.0
        }
    }
    
    var tractCardAnalyticEvents: [TractAnalyticEvent]  {
            return self.analyticsUserInfo
    }
    
    // MARK: - Setup
    
    override func loadElementProperties(_ properties: [String : Any]) {
        super.loadElementProperties(properties)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveHeroActionEvent(notification:)),
                                               name: .heroActionTrackNotification,
                                               object: nil)
    }
    
    override func propertiesKind() -> TractProperties.Type {
        return TractCardProperties.self
    }
    
    override func loadStyles() {
        let properties = cardProperties()
        
        if properties.hidden {
            self.isHidden = true
            properties.cardState = .hidden
        }
    }
    
    override func render() -> UIView {
        setupScrollView()
        setBordersAndShadows()
        disableScrollview()
        setupSwipeGestures()
        
        for element in self.elements! {
            self.containerView.addSubview(element.render())
        }
        
        self.scrollView.addSubview(self.containerView)
        self.addSubview(self.shadowView)
        self.addSubview(self.backgroundView)
        self.addSubview(self.scrollView)
        
        hideTexts()
        setupTransparentView()
        setupBackground()
        loadParallelElementState()
        
        TractBindings.addBindings(self)
        return self
    }
    
    override func elementListeners() -> [String]? {
        let properties = cardProperties()
        return properties.listeners == "" ? nil : properties.listeners.components(separatedBy: " ")
    }
    
    override func elementDismissListeners() -> [String]? {
        let properties = cardProperties()
        return properties.dismissListeners == "" ? nil : properties.dismissListeners.components(separatedBy: " ")
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0
        self.elementFrame.width = self.parentWidth()
        self.elementFrame.xMargin = TractCard.xMarginConstant
    }
    
    override func updateFrameHeight() {
        self.elementFrame.height = cardHeight()
        self.frame = self.elementFrame.getFrame()
    }
    
    override func loadParallelElementState() {
        guard let element = self.parallelElement else {
            return
        }
        
        let cardElement = element as! TractCard
        self.isHidden = cardElement.isHidden
        self.currentAnimation = cardElement.currentAnimation
        self.scrollView.isScrollEnabled = cardElement.scrollView.isScrollEnabled
        
        let currentProperties = cardElement.cardProperties()
        let properties = self.cardProperties()
        properties.cardState = currentProperties.cardState
        
        switch cardElement.currentAnimation {
        case .show:
            self.cardsParentView.lastCardOpened = self
            showCardWithoutAnimation()
            showTexts()
        case .hide:
            hideCardWithoutAnimation()
        default:
            break
        }
    }
    
    override func viewDidAppearOnTract() {
        guard let cardsElement = self.parent as? TractCards else {
            return
        }
        
        if self == cardsElement.elements?.first {
            loadFirstTimeAccessAnimation()
        }
    }
    
    // MARK - This method compiles the HeroAnalytics data and associates it with the TractCard that is its closet child element.
    // This was about the only solution since screens in the Tract are incremented by 1 and the XML is rendered 2 screens in advance.
    
    @objc func receiveHeroActionEvent(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let events = userInfo as? [String: String] else {
            return
        }
        
        let relay = AnalyticsRelay.shared
        
        // Parse out the card number so it can be offset to when the Hero is on screen
        let tractName = getTrackNamePrefix(screenName: relay.screenName)
        guard let cardNumber = separateLetterAndNumber(screenName: relay.screenName) else { return }
        let offsetCardNumber = setCardOffset(cardNumber: cardNumber)
        
        // Create a unique key that matches the screen name when only the Hero is shown
        let heroKey = "\(tractName)-\(offsetCardNumber)"
        
        // Assign the value to the HeroAnalyticsDictionary stored in the AnalyticsRelay
        relay.heroAnalyticsDictionary[heroKey] = events
    }
    
    // MARK: - Helpers
    
    func cardProperties() -> TractCardProperties {
        return self.properties as! TractCardProperties
    }
    
    func cardHeight() -> CGFloat {
        return self.getMaxHeight() - TractCard.yBottomMarginConstant - TractPage.navbarHeight - TractPage.statusbarHeight - TractPageContainer.marginBottom
    }
    
    func endCardEditing() {
        self.endEditing(true)
    }
    
    func loadFirstTimeAccessAnimation() {
        if TractConfigurations.isFirstTimeAccess() {
            TractConfigurations.didAccessToTract()
            openingAnimation()
        }
    }
    
    // Analytics Helpers
    
    func getTrackNamePrefix(screenName: String) -> String {
        let components = screenName.components(separatedBy: "-")
        return components.first ?? ""
    }
    
    func separateLetterAndNumber(screenName: String) -> Int? {
        let components = screenName.components(separatedBy: "-")
        guard let numberString = components.last, let number = Int(numberString) else { return nil }
        
        return number
    }
    
    func setCardOffset(cardNumber: Int) -> Int {
        return cardNumber + 2
    }

}
