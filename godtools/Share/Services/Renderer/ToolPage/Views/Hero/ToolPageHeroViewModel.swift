//
//  ToolPageHeroViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeroViewModel: ToolPageContentStackContainerViewModelType {
    
    private let heroNode: HeroNode
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
        
    let contentStackRenderer: ToolPageContentStackRenderer
    
    required init(heroNode: HeroNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColors) {
        
        self.heroNode = heroNode
        self.contentStackRenderer = ToolPageContentStackRenderer(
            rootContentStackRenderer: nil,
            diContainer: diContainer,
            node: heroNode,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: nil,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil
        )
        
        if let analyticsEventsNode = heroNode.analyticsEventsNode {
            analyticsEventsObjects = MobileContentAnalyticsEvent.initEvents(eventsNode: analyticsEventsNode, mobileContentAnalytics: diContainer.mobileContentAnalytics)
        }
        else {
            analyticsEventsObjects = []
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func heroDidAppear() {
        mobileContentDidAppear()
    }
    
    func heroDidDisappear() {
        mobileContentDidDisappear()
    }
}

// MARK: - MobileContentViewModel

extension ToolPageHeroViewModel: MobileContentViewModel {
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
    
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger {
        return .visible
    }
}
