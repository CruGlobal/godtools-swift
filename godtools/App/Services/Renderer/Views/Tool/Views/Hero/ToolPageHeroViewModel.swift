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
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    init(heroModel: Hero, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.heroModel = heroModel
                
        analyticsEventsObjects = MobileContentAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: heroModel.analyticsEvents,
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
        super.viewDidAppear(analyticsEvents: analyticsEventsObjects)
    }
    
    func heroDidDisappear() {
        super.viewDidDisappear(analyticsEvents: analyticsEventsObjects)
    }
}
