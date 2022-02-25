//
//  ToolPageHeroViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageHeroViewModel: ToolPageHeroViewModelType {
    
    private let heroModel: Hero
    private let rendererPageModel: MobileContentRendererPageModel
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    required init(heroModel: Hero, rendererPageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.heroModel = heroModel
        self.rendererPageModel = rendererPageModel
                
        analyticsEventsObjects = MobileContentAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: heroModel.analyticsEvents,
            mobileContentAnalytics: mobileContentAnalytics,
            rendererPageModel: rendererPageModel
        )
    }
    
    deinit {

    }
    
    func heroDidAppear() {
        mobileContentDidAppear()
    }
    
    func heroDidDisappear() {
        mobileContentDidDisappear()
    }
}

// MARK: - MobileContentViewModelType

extension ToolPageHeroViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return rendererPageModel.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
    
    var defaultAnalyticsEventsTrigger: MobileContentAnalyticsEventTrigger {
        return .visible
    }
}
