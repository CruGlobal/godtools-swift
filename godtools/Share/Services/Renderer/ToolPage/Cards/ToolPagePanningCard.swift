//
//  ToolPagePanningCard.swift
//  godtools
//
//  Created by Levi Eggert on 11/5/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolPagePanningCard {
    
    let card: ToolPageCardView
    let cardPosition: Int
    
    required init(card: ToolPageCardView, cardPosition: Int) {
        
        self.card = card
        self.cardPosition = cardPosition
    }
}
