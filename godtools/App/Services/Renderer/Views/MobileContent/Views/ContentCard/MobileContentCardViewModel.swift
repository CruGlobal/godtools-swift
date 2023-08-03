//
//  MobileContentCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardViewModel: MobileContentViewModel {
    
    private let cardModel: Card
    
    let mobileContentAnalytics: MobileContentRendererAnalytics
    
    init(cardModel: Card, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.cardModel = cardModel
        self.mobileContentAnalytics = mobileContentAnalytics
        
        super.init(baseModel: cardModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
