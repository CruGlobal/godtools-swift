//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageViewModel: MobileContentPageViewModel, ToolPageViewModelType {
    
    private let pageModel: TractPage
    private let renderedPageContext: MobileContentRenderedPageContext
    private let analytics: AnalyticsContainer
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    private var cardPosition: Int?
    
    let hidesCallToAction: Bool
    
    required init(pageModel: TractPage, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics) {
                
        self.pageModel = pageModel
        self.renderedPageContext = renderedPageContext
        self.analytics = analytics
        self.hidesCallToAction = pageModel.isLastPage
                
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
    
    override var analyticsScreenName: String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let page: Int = renderedPageContext.page
        
        let cardAnalyticsScreenName: String
        
        if let cardPosition = self.cardPosition {
            cardAnalyticsScreenName = ToolPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
        }
        else {
            cardAnalyticsScreenName = ""
        }
                        
        return resource.abbreviation + "-" + String(page) + cardAnalyticsScreenName
    }
    
    var numberOfVisibleCards: Int {
        return pageModel.visibleCards.count
    }
    
    var bottomViewColor: UIColor {
        
        let manifest: Manifest = renderedPageContext.manifest
        let color: UIColor = manifest.navBarColor
        
        return color.withAlphaComponent(0.1)
    }
    
    var page: Int {
        return renderedPageContext.page
    }
    
    func callToActionWillAppear() -> ToolPageCallToActionView? {
        
        if !hidesCallToAction && pageModel.callToAction == nil {
            
            for viewFactory in renderedPageContext.pageViewFactories.factories {
                if let toolPageViewFactory = viewFactory as? ToolPageViewFactory {
                    return toolPageViewFactory.getCallToActionView(callToActionModel: nil, renderedPageContext: renderedPageContext)
                }
            }
        }
        
        return nil
    }
    
    func pageDidAppear() {
        mobileContentDidAppear()
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection, contentLanguage: renderedPageContext.language.code, secondaryContentLanguage: nil))
    }
    
    func didChangeCardPosition(cardPosition: Int?) {
        self.cardPosition = cardPosition
    }
}

// MARK: - MobileContentViewModelType

extension ToolPageViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return renderedPageContext.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
}
