//
//  LegacyMobileContentCardCollectionPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class LegacyMobileContentCardCollectionPageCardViewModel: LegacyMobileContentViewModel {
    
    private let cardModel: CardCollectionPage.Card
    
    let pageNumber: String
    
    init(
        card: CardCollectionPage.Card,
        renderedPageContext: MobileContentRenderedPageContext,
        mobileContentAnalytics: MobileContentRendererAnalytics
    ) {
                
        self.cardModel = card
        pageNumber = "\(card.position + 1)/\(card.page.cards.count)"
        
        super.init(baseModel: card, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
