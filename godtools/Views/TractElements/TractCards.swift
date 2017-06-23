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
    
    override var height: CGFloat {
        get {
            return self.getMaxHeight() - TractPage.navbarHeight
        }
        set { } // Unused
    }
    
    var initialCardPosition: CGFloat {
        return self.height - self.elementFrame.y + TractPage.navbarHeight
    }
    
    // MARK: - Dynamic settings
    
    var isOnInitialPosition: Bool = true
    var animationYPos: CGFloat {
        return self.isOnInitialPosition == true ? 0.0 : -self.elementFrame.y + TractPage.navbarHeight
    }
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractCardsProperties.self
    }
    
    override func buildChildrenForData(_ data: [XMLIndexer]) {
        self.elements = [BaseTractElement]()
        let cards = splitCardsByKind(data: data)
        buildCards(cards.normal)
        buildHiddenCards(cards.hidden)
        loadParallelElements()
    }
    
    override func loadFrameProperties() {
        let yExternalPosition = self.elementFrame.y > TractCards.minYPosition ? self.elementFrame.y : TractCards.minYPosition
        
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
        self.elementFrame.yMarginBottom = yExternalPosition
    }
    
    override func loadParallelElementProperties() {
        guard let element = self.parallelElement else {
            return
        }
        
        let cardsElement = element as! TractCards
        if cardsElement.isOnInitialPosition == false {
            transformToOpenUpCardsAnimation()
        }
    }
    
    // MARK: - Helpers
    
    func cardsProperties() -> TractCardsProperties {
        return self.properties as! TractCardsProperties
    }

}
