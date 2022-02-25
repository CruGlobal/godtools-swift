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
    private let rendererPageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics) {
            
        self.pageModel = pageModel
        self.rendererPageModel = rendererPageModel
        self.analytics = analytics
        
        self.analyticsEventsObjects = MobileContentAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: pageModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            rendererPageModel: rendererPageModel
        )
        
        super.init(flowDelegate: flowDelegate, pageModel: pageModel, rendererPageModel: rendererPageModel, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:rendererPageModel:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
    
    var manifestDismissListeners: [EventId] {
        return Array(rendererPageModel.manifest.dismissListeners)
    }
    
    func pageDidAppear() {
        mobileContentDidAppear()
        
        let resource: ResourceModel = rendererPageModel.resource
        let page: Int = rendererPageModel.page
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: resource.abbreviation + "-" + String(page), siteSection: resource.abbreviation, siteSubSection: ""))
    }
}

// MARK: - MobileContentViewModelType

extension LessonPageViewModel: MobileContentViewModelType {
    
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
