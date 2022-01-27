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
    
    required init(card: CardCollectionPage.Card) {
        
        self.card = card
    }
}
