//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageViewModel: MobileContentPageViewModel {
    
    private let pageModel: TractPage
    private let analytics: AnalyticsContainer
    private let visibleAnalyticsEventsObjects: [MobileContentRendererAnalyticsEvent]
    
    private var cardPosition: Int?
    
    let hidesCallToAction: Bool
    
    init(pageModel: TractPage, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentRendererAnalytics) {
                
        self.pageModel = pageModel
        self.analytics = analytics
        self.hidesCallToAction = pageModel.isLastPage
                
        self.visibleAnalyticsEventsObjects = MobileContentRendererAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: pageModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(pageModel: pageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, hidesBackgroundImage: false)
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
}

// MARK: - Inputs

extension ToolPageViewModel {
    
    func callToActionWillAppear() -> ToolPageCallToActionView? {

        guard !hidesCallToAction else {
            return nil
        }
        
        for viewFactory in renderedPageContext.pageViewFactories.factories {
            if let toolPageViewFactory = viewFactory as? ToolPageViewFactory {
                return toolPageViewFactory.getCallToActionView(callToActionModel: nil, renderedPageContext: renderedPageContext)
            }
        }
        
        return nil
    }
    
    func pageDidAppear() {
        
        super.viewDidAppear(visibleAnalyticsEvents: visibleAnalyticsEventsObjects)
                
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.localeIdentifier,
            secondaryContentLanguage: nil
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
    
    func didChangeCardPosition(cardPosition: Int?) {
        self.cardPosition = cardPosition
    }
}
