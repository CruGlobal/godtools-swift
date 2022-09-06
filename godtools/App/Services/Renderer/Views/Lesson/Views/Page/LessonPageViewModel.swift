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
    
    required init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics) {
            
        self.pageModel = pageModel
        self.renderedPageContext = renderedPageContext
        self.analytics = analytics
        
        self.analyticsEventsObjects = MobileContentAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: pageModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(pageModel: pageModel, renderedPageContext: renderedPageContext, hidesBackgroundImage: false)
    }
    
    required init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, hidesBackgroundImage: Bool) {
        fatalError("init(pageModel:renderedPageContext:hidesBackgroundImage:) has not been implemented")
    }
    
    func pageDidAppear() {
        mobileContentDidAppear()
        
        let trackScreenModel = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.code,
            secondaryContentLanguage: nil
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreenModel)
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
