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
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColors
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    private var contentRenderer: MobileContentRenderer?
    
    required init(heroNode: HeroNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColors) {
        
        self.heroNode = heroNode
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        
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
        
        let viewFactory = ToolPageRendererViewFactory(
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: nil,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil,
            delegate: nil
        )
        
        let contentRenderer = MobileContentRenderer(
            node: heroNode,
            viewFactory: viewFactory
        )
        
        self.contentRenderer = contentRenderer
        
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
