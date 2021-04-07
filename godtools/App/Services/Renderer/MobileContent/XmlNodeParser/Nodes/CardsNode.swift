//
//  CardsNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class CardsNode: MobileContentXmlNode {
        
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    var cards: [CardNode] {
        return children as? [CardNode] ?? []
    }
    
    var visibleCards: [CardNode] {
        return cards.filter({!$0.isHidden})
    }
    
    var hiddenCards: [CardNode] {
        return cards.filter({$0.isHidden})
    }
    
    func getCardPosition(cardNode: CardNode) -> Int? {
        return cards.firstIndex(of: cardNode)
    }
    
    func getCardVisiblePosition(cardNode: CardNode) -> Int? {
        return visibleCards.firstIndex(of: cardNode)
    }
    
    func getCardHiddenPosition(cardNode: CardNode) -> Int? {
        return hiddenCards.firstIndex(of: cardNode)
    }
}

// MARK: - MobileContentRenderableNode

extension CardsNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
