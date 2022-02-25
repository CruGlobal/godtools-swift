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
    private let rendererPageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    private var cardPosition: Int?
    
    let hidesCallToAction: Bool
    
    required init(flowDelegate: FlowDelegate, pageModel: TractPage, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics) {
                
        self.pageModel = pageModel
        self.rendererPageModel = rendererPageModel
        self.analytics = analytics
        self.hidesCallToAction = pageModel.isLastPage
        
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
    
    override var analyticsScreenName: String {
        
        let resource: ResourceModel = rendererPageModel.resource
        let page: Int = rendererPageModel.page
        
        let cardAnalyticsScreenName: String
        
        if let cardPosition = self.cardPosition {
            cardAnalyticsScreenName = ToolPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
        }
        else {
            cardAnalyticsScreenName = ""
        }
                        
        return resource.abbreviation + "-" + String(page) + cardAnalyticsScreenName
    }
    
    var bottomViewColor: UIColor {
        
        let manifest: Manifest = rendererPageModel.manifest
        let color: UIColor = manifest.navBarColor
        
        return color.withAlphaComponent(0.1)
    }
    
    var page: Int {
        return rendererPageModel.page
    }
    
    func callToActionWillAppear() -> ToolPageCallToActionView? {
        
        if !hidesCallToAction && pageModel.callToAction == nil {
            
            for viewFactory in rendererPageModel.pageViewFactories.factories {
                if let toolPageViewFactory = viewFactory as? ToolPageViewFactory {
                    return toolPageViewFactory.getCallToActionView(callToActionModel: nil, rendererPageModel: rendererPageModel)
                }
            }
        }
        
        return nil
    }
    
    func pageDidAppear() {
        mobileContentDidAppear()
        
        let resource: ResourceModel = rendererPageModel.resource
        let page: Int = rendererPageModel.page
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: resource.abbreviation + "-" + String(page), siteSection: resource.abbreviation, siteSubSection: ""))
    }
    
    func didChangeCardPosition(cardPosition: Int?) {
        self.cardPosition = cardPosition
    }
}

// MARK: - MobileContentViewModelType

extension ToolPageViewModel: MobileContentViewModelType {
    
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
