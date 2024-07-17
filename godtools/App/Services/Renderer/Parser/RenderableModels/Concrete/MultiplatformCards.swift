//
//  MultiplatformCards.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformCards {
    
    let cards: [TractPage.Card]
    
    init(cards: [TractPage.Card]) {
        
        self.cards = cards
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformCards: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
       
        let numberOfVisibleCards: Int = cards.filter({!$0.isHidden}).count
        
        let cards: [MultiplatformCard] = cards.map({MultiplatformCard(card: $0, numberOfVisibleCards: numberOfVisibleCards)})
        
        return cards
    }
}
