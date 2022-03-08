//
//  MobileContentCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardViewModel: MobileContentCardViewModelType {
    
    private let contentCard: Card
    private let renderedPageContext: MobileContentRenderedPageContext
    
    required init(contentCard: Card, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.contentCard = contentCard
        self.renderedPageContext = renderedPageContext
    }
    
    var events: [EventId] {
        return contentCard.events
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
}
