//
//  MultiplatformCard.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformCard {
    
    let card: TractPage.Card
    let numberOfVisibleCards: Int
    
    init(card: TractPage.Card, numberOfVisibleCards: Int) {
        
        self.card = card
        self.numberOfVisibleCards = numberOfVisibleCards
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformCard: MobileContentRenderableModel {
        
    func getRenderableChildModels() -> [AnyObject] {
        
        return card.content
    }
}
