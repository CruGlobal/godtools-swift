//
//  ToolPageHeroViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeroViewModel {
    
    private let heroNode: HeroNode
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    private let contentRenderer: ToolPageContentStackRenderer
    
    required init(heroNode: HeroNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColors) {
        
        self.heroNode = heroNode
        
        contentRenderer = ToolPageContentStackRenderer(
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

    }
    
    func heroWillAppear() -> MobileContentStackView? {
        return contentRenderer.render() as? MobileContentStackView
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
