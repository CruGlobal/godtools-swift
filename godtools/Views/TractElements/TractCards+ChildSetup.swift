//
//  TractCards+ChildSetup.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

extension TractCards {
    
    func splitCardsByKind(data: [XMLIndexer]) -> (normal: [XMLIndexer], hidden: [XMLIndexer]) {
        var normalCards = [XMLIndexer]()
        var hiddenCards = [XMLIndexer]()
        
        for dictionary in data {
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
        var cardNumber = 0
        
        for dictionary in cards {
            let deltaChange = CGFloat(cards.count - cardNumber)
            let yPosition = self.initialCardPosition - (deltaChange * TractCards.constantYPaddingTop)
            let yDownPosition = self.elementFrame.y + (deltaChange * TractCards.constantYPaddingTop)
                - (deltaChange * TractCards.constantYPaddingBottom)
            
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self)
            element.yDownPosition = yDownPosition
            element.cardProperties().cardNumber = cardNumber
            self.elements?.append(element)
            
            cardNumber += 1
        }
    }
    
    func buildHiddenCards(_ cards: [XMLIndexer]) {
        for dictionary in cards {
            let yPosition = self.initialCardPosition
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self)
            self.elements?.append(element)
        }
    }
    
}
