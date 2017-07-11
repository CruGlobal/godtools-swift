//
//  TractCards.swift
//  godtools
//
//  Created by Devserker on 5/2/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractCards: BaseTractElement {
        
    // MARK: - Positions and Sizes
    
    static let minYPosition: CGFloat = 110.0
    static let constantYPaddingTop: CGFloat = 45
    static let constantYPaddingBottom: CGFloat = 16
    static let constantYBottomSpace: CGFloat = 6
    static let tapViewHeightConstant: CGFloat = 300
    
    override var height: CGFloat {
        get {
            return self.getMaxHeight() - TractPage.navbarHeight
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
