//
//  MobileContentCardCollectionPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardCollectionPageCardViewModel: MobileContentViewModel {
    
    private let cardModel: CardCollectionPage.Card
    
    let pageNumber: String
    
    init(card: CardCollectionPage.Card) {
                
        self.cardModel = card
        pageNumber = "\(card.position + 1)/\(card.page.cards.count)"
        
        super.init(baseModel: card)
    }
}
