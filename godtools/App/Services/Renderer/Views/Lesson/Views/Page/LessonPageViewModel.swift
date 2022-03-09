//
//  LessonPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class LessonPageViewModel: MobileContentPageViewModel, LessonPageViewModelType {
    
    private let pageModel: Page
    private let renderedPageContext: MobileContentRenderedPageContext
    private let analytics: AnalyticsContainer
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics) {
            
        self.pageModel = pageModel
        self.renderedPageContext = renderedPageContext
        self.analytics = analytics
        
        self.analyticsEventsObjects = MobileContentAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: pageModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(flowDelegate: flowDelegate, pageModel: pageModel, renderedPageContext: renderedPageContext, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:renderedPageContext:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
    
    var manifestDismissListeners: [EventId] {
        return Array(renderedPageContext.manifest.dismissListeners)
    }
    
    func pageDidAppear() {
        mobileContentDidAppear()
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
}

// MARK: - MobileContentViewModelType

extension LessonPageViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return renderedPageContext.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
}
