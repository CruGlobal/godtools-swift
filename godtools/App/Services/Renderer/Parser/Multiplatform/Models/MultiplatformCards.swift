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
    
    let cards: [MultiplatformCard]
    
    required init(cards: [TractPage.Card]) {
        
        let numberOfVisibleCards: Int = cards.filter({!$0.isHidden}).count
        
        self.cards = cards.map({MultiplatformCard(card: $0, numberOfVisibleCards: numberOfVisibleCards)})
    }
    
    var visibleCards: [MultiplatformCard] {
        return cards.filter({!$0.isHidden})
    }
    
    var numberOfCards: Int {
        return cards.count
    }
    
    var numberOfVisibleCards: Int {
        return visibleCards.count
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformCards: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return cards
    }
}
