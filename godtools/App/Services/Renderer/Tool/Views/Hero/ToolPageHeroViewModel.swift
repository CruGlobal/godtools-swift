//
//  ToolPageHeroViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeroViewModel: ToolPageHeroViewModelType {
    
    private let pageModel: MobileContentRendererPageModel
    private let heroNode: HeroNode
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    required init(heroNode: HeroNode, pageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.heroNode = heroNode
        self.pageModel = pageModel
        
        if let analyticsEventsNode = heroNode.analyticsEventsNode {
            analyticsEventsObjects = MobileContentAnalyticsEvent.initEvents(eventsNode: analyticsEventsNode, mobileContentAnalytics: mobileContentAnalytics)
        }
        else {
            analyticsEventsObjects = []
        }
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
        return pageModel.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
    
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger {
        return .visible
    }
}
