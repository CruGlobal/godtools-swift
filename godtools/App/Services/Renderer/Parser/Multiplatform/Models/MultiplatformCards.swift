//
//  MultiplatformCards.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformCards: CardsModelType {
    
    let cards: [CardModelType]
    
    required init(cards: [TractPage.Card]) {
        
        let numberOfVisibleCards: Int = cards.filter({!$0.isHidden}).count
        
        self.cards = cards.map({MultiplatformCard(card: $0, numberOfVisibleCards: numberOfVisibleCards)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformCards {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return cards
    }
}
