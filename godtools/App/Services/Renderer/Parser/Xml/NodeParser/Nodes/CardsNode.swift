//
//  CardsNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class CardsNode: MobileContentXmlNode, CardsModelType {
        
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    var cardNodes: [CardNode] {
        return children as? [CardNode] ?? []
    }
    
    var visibleCardNodes: [CardNode] {
        return cardNodes.filter({!$0.isHidden})
    }
    
    var hiddenCardNodes: [CardNode] {
        return cardNodes.filter({$0.isHidden})
    }
    
    func getCardPosition(cardNode: CardNode) -> Int? {
        return cardNodes.firstIndex(of: cardNode)
    }
    
    func getCardVisiblePosition(cardNode: CardNode) -> Int? {
        return visibleCardNodes.firstIndex(of: cardNode)
    }
    
    func getCardHiddenPosition(cardNode: CardNode) -> Int? {
        return hiddenCardNodes.firstIndex(of: cardNode)
    }
    
    // MARK: - CardsModelType
    
    var numberOfCards: Int {
        return cardNodes.count
    }
    
    var numberOfVisibleCards: Int {
        return visibleCardNodes.count
    }
}
