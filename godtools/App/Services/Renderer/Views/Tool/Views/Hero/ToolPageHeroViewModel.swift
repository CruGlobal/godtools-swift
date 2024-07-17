//
//  ToolPageHeroViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageHeroViewModel: MobileContentViewModel {
    
    private let heroModel: Hero
    private let visibleAnalyticsEventsObjects: [MobileContentRendererAnalyticsEvent]
    
    init(heroModel: Hero, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.heroModel = heroModel
                
        visibleAnalyticsEventsObjects = MobileContentRendererAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: heroModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(baseModel: heroModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    deinit {

    }
}

// MARK: - Inputs

extension ToolPageHeroViewModel {
    
    func heroDidAppear() {
        super.viewDidAppear(visibleAnalyticsEvents: visibleAnalyticsEventsObjects)
    }
    
    func heroDidDisappear() {
        super.viewDidDisappear(visibleAnalyticsEvents: visibleAnalyticsEventsObjects)
    }
}
