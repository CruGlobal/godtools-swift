//
//  MobileContentCardCollectionPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardCollectionPageCardViewModel: MobileContentCardCollectionPageCardViewModelType {
    
    private let card: CardCollectionPage.Card
    
    let pageNumber: String
    
    required init(card: CardCollectionPage.Card) {
                
        self.card = card
        pageNumber = "\(card.position + 1)/\(card.page.cards.count)"
    }
}
