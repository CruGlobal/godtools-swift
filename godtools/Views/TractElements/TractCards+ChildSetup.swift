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
        relay.tractCardCurrentNames.removeAll()
        relay.tractCardCurrentNames = relay.tractCardNextNames
        relay.tractCardNextNames.removeAll()
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
            
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self, elementNumber: elementNumber)
            element.yDownPosition = yDownPosition - TractPage.navbarHeight
            element.cardProperties().cardNumber = cardNumber
            let alphaCode = element.cardProperties().cardNumber.convertToLetter()
            element.cardProperties().cardIdName = "\(relay.tractName)\(alphaCode)"
            self.elements?.append(element)
            
            relay.tractCardNextNames.append(alphaCode)

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
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self, elementNumber: elementNumber)
            self.elements?.append(element)
            elementNumber += 1
        }
    }
    
}
