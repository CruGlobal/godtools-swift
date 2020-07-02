//
//  TractCards.swift
//  godtools
//
//  Created by Devserker on 5/2/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class TractCards: BaseTractElement {
        
    // MARK: - Positions and Sizes
    
    static var minYPosition: CGFloat {
        return 110.0
    }
    static let constantYPaddingTop: CGFloat = 45
    static let constantYPaddingBottom: CGFloat = 16
    static let constantYBottomSpace: CGFloat = 6
    static let tapViewHeightConstant: CGFloat = 300
    
    override var height: CGFloat {
        get {
            return self.getMaxHeight() - TractPage.navbarHeight - TractPage.statusbarHeight - TractPageContainer.marginBottom
        }
        set { } // Unused
    }
    
    var initialCardPosition: CGFloat {
        return self.height - self.elementFrame.y + TractPage.navbarHeight - TractCards.constantYBottomSpace
    }
    
    // MARK: - Dynamic settings
    
    var tapView: UIView = UIView()
    var cardsData: [XMLIndexer]?
    var lastCard: BaseTractElement?
    var lastCardOpened: TractCard?
    var isOnInitialPosition = true
    var animationYPos: CGFloat {
        return self.isOnInitialPosition == true ? 0.0 : -self.elementFrame.y + TractPage.navbarHeight
    }
    
    // MARK: - Setup
    
    override func reset() {
        super.reset()
        
        changeToPreviewCards()
        
        lastCardOpened = nil
        
        if let elements = elements {
            for element in elements {
                if let tractCard = element as? TractCard {
                    tractCard.reset()
                }
            }
        }
    }
    
    override func propertiesKind() -> TractProperties.Type {
        return TractCardsProperties.self
    }
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.elementFrame.y = yPosition
        
        let contentElements = self.xmlManager.getContentElements(data)
        
        self.cardsData = contentElements.children
        loadElementProperties(contentElements.properties)
        loadFrameProperties()
        buildFrame()
        setupParallelElement()
        buildChildrenForData(contentElements.children)
        setupView(properties: contentElements.properties)
        setupSwipeGestures()
        setupPressGestures()
    }
    
    override func buildChildrenForData(_ data: [XMLIndexer]) {
        self.elements = [BaseTractElement]()
        let cards = splitCardsByKind()
        buildCards(cards.normal)
        buildHiddenCards(cards.hidden)
    }
    
    override func loadFrameProperties() {
        let yExternalPosition = self.elementFrame.y > TractCards.minYPosition ? self.elementFrame.y : TractCards.minYPosition
        
        setCardsYPosition()
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
        self.elementFrame.yMarginBottom = yExternalPosition
    }
    
    override func loadParallelElementState() {
        guard let element = self.parallelElement else {
            return
        }
        
        let cardsElement = element as! TractCards
        let cardsElementProperties = cardsElement.cardsProperties()
        let properties = self.cardsProperties()
        properties.cardsState = cardsElementProperties.cardsState
        
        if cardsElement.isOnInitialPosition == false {
            transformToOpenUpCardsWithouAnimation()
        }
    }
    
    // MARK: - Helpers
    
    func cardsProperties() -> TractCardsProperties {
        return self.properties as! TractCardsProperties
    }

}

// MARK: - Actions

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

// MARK: - Animations

extension TractCards {
    
    func transformToOpenUpCardsWithouAnimation() {
        self.isOnInitialPosition = false
        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos)
    }
    
    func transformToOpenUpCardsAnimation() {
        self.isOnInitialPosition = false
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: nil )
    }
    
    func transformToInitialPositionAnimation() {
        self.isOnInitialPosition = true
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: self.animationYPos) },
                       completion: nil )
    }
    
}

// MARK: - ChildSetup

extension TractCards {
    
    func splitCardsByKind() -> (normal: [XMLIndexer], hidden: [XMLIndexer]) {
        var normalCards = [XMLIndexer]()
        var hiddenCards = [XMLIndexer]()
        
        for dictionary in self.cardsData! {
            let contentElements = self.xmlManager.getContentElements(dictionary)
            let card = TractCardProperties()
            card.load(contentElements.properties)
            
            if card.hidden == true {
                hiddenCards.append(dictionary)
            } else {
                normalCards.append(dictionary)
            }
        }
        
        return (normal: normalCards, hidden: hiddenCards)
    }
    
    func buildCards(_ cards: [XMLIndexer]) {
        let relay = AnalyticsRelay.shared
        
        // These arrays keep track of what current cards are in a viewable stack.
        // This is used for preventing a false report being sent to analytics tracking.
        relay.tractCardCurrentLetterNames.removeAll()
        relay.tractCardCurrentLetterNames = relay.tractCardNextLetterNames
        relay.tractCardNextLetterNames.removeAll()
        
        if self.elements == nil {
            self.elements = [BaseTractElement]()
        }
        
        var elementNumber: Int = self.elements!.count
        var cardNumber: Int = 0
        
        for dictionary in cards {
            let deltaChange = CGFloat(cards.count - cardNumber)
            let yPosition = self.initialCardPosition - (deltaChange * TractCards.constantYPaddingTop)
            let yDownPosition = self.elementFrame.y + (deltaChange * TractCards.constantYPaddingTop)
                - (deltaChange * TractCards.constantYPaddingBottom)
            
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self, elementNumber: elementNumber, dependencyContainer: dependencyContainer, isPrimaryRightToLeft: isPrimaryRightToLeft)
            element.yDownPosition = yDownPosition - TractPage.navbarHeight
            element.cardProperties().cardNumber = cardNumber
            let letterName = cardNumber.convertToLetter()
            element.cardProperties().cardLetterName = letterName
            
            for child in dictionary.children {
                guard let childElement = child.element else { continue }
                if childElement.name.contains("analytics") {
                    element.cardProperties().analyticEventProperties = TractEventHelper.buildAnalyticsEvents(data: child)
                }
            }
            
            self.elements?.append(element)
            
            relay.tractCardNextLetterNames.append(letterName)
            
            cardNumber += 1
            elementNumber += 1
        }
        
        self.lastCard = self.elements?.last
    }
    
    func buildHiddenCards(_ cards: [XMLIndexer]) {
        if self.elements == nil {
            self.elements = [BaseTractElement]()
        }
        
        var elementNumber: Int = self.elements!.count
        
        for dictionary in cards {
            let yPosition = self.initialCardPosition
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self, elementNumber: elementNumber, dependencyContainer: dependencyContainer, isPrimaryRightToLeft: isPrimaryRightToLeft)
            self.elements?.append(element)
            elementNumber += 1
        }
    }
}

// MARK: - Gestures

extension TractCards {
    
    func setupSwipeGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
    }
    
    func setupPressGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePressGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        let frame = CGRect(x: 0.0,
                           y: self.height - TractCards.tapViewHeightConstant,
                           width: self.width,
                           height: TractCards.tapViewHeightConstant)
        self.tapView.frame = frame
        self.tapView.addGestureRecognizer(tapGesture)
        self.tapView.isUserInteractionEnabled = true
        self.addSubview(self.tapView)
    }
    
    @objc func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            self.lastCardOpened?.processSwipeUp()
        } else if sender.direction == .down {
            self.lastCardOpened?.processSwipeDown()
        }
    }
    
    @objc func handlePressGesture(sender: UITapGestureRecognizer) {
        self.lastCardOpened?.processSwipeUp()
    }
}

// MARK: - UI

extension TractCards {
    
    func getHeightOfClosedCards() -> CGFloat {
        let cards = splitCardsByKind()
        return CGFloat(cards.normal.count) * TractCards.constantYPaddingTop
    }
    
    func getMaxFreeHeight(hero previousElement: TractHero) -> CGFloat {
        let maxHeight = BaseTractElement.screenHeight - previousElement.elementFrame.y - TractHero.marginBottom
        return maxHeight - getHeightOfClosedCards()
    }
    
    func setCardsYPosition() {
        if let element = getPreviousElement() as? TractHero {
            let initialYPosition = getMaxFreeHeight(hero: element)
            if initialYPosition < self.elementFrame.y {
                self.elementFrame.y = (UIDevice.current.iPhoneWithNotch()) ? initialYPosition - TractPage.navbarHeight : initialYPosition + TractPage.navbarHeight
            }
        }
    }
}
