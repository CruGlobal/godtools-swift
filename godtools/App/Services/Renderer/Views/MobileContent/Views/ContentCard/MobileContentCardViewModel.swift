//
//  MobileContentCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardViewModel: MobileContentViewModel, ClickableMobileContentViewModel {
    
    private let cardModel: Card
    private let renderedPageContext: MobileContentRenderedPageContext
    private let mobileContentAnalytics: MobileContentAnalytics
    
    init(cardModel: Card, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.cardModel = cardModel
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
        
        super.init(baseModel: cardModel)
    }
    
    var events: [EventId] {
        return cardModel.events
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
    
    func getClickableUrl() -> URL? {
        return getClickableUrl(model: cardModel)
    }
}

// MARK: - Inputs

extension MobileContentCardViewModel {
    
    func cardTapped() {
        trackClickableEvents(model: cardModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
