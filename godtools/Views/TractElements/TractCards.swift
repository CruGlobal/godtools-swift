//
//  TractCards.swift
//  godtools
//
//  Created by Devserker on 5/2/17.
//  Copyright © 2017 Cru. All rights reserved.
//

//  NOTES ABOUT THE COMPONENT
//  * Cards is a component that is not present on the XML. The component was generate
//  because of the need to have a container to store all the cards. The cards container
//  will only store elements of the kind Card.
//  * Following the XML structure, the Cards container will always be a children of
//  TractPage container. Also, the Cards container will always be at the same level of a
//  Header component.
//  * The height size of this component will always be the same of TractPage.height

import Foundation
import UIKit
import SWXMLHash

class TractCards: BaseTractElement {
        
    // MARK: - Positions and Sizes
    
    static let minYPosition: CGFloat = 110.0
    static let constantYPaddingTop: CGFloat = 60
    static let constantYPaddingBottom: CGFloat = 30
    
    override var height: CGFloat {
        get {
            return self.getMaxHeight()
        }
        set { } // Unused
    }
    
    var initialCardPosition: CGFloat {
        return self.height - self.elementFrame.y
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
    }
    
    override func loadStyles() {
        setupBackground()
    }
    
    override func loadFrameProperties() {
        let yExternalPosition = self.elementFrame.y > TractCards.minYPosition ? self.elementFrame.y : TractCards.minYPosition
        
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
        self.elementFrame.yMarginBottom = yExternalPosition
    }
    
    // MARK: - Helpers
    
    func cardsProperties() -> TractCardsProperties {
        return self.properties as! TractCardsProperties
    }

}
