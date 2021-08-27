//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: MobileContentPageViewModel, ToolPageViewModelType {
    
    private let pageModel: PageModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
    
    private var cardPosition: Int?
    
    let hidesCallToAction: Bool
    
    required init(flowDelegate: FlowDelegate, pageModel: PageModelType, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer) {
        
        self.pageModel = pageModel
        self.rendererPageModel = rendererPageModel
        self.analytics = analytics
        self.hidesCallToAction = (pageModel.callToAction == nil && rendererPageModel.pageModel.hero == nil) || rendererPageModel.isLastPage
        
        super.init(flowDelegate: flowDelegate, pageModel: pageModel, rendererPageModel: rendererPageModel, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: PageModelType, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
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
        
        let manifestAttributes: MobileContentManifestAttributesType = rendererPageModel.manifest.attributes
        let color: UIColor = manifestAttributes.navbarColor?.uiColor ?? manifestAttributes.primaryColor.uiColor
        
        return color.withAlphaComponent(0.1)
    }
    
    var page: Int {
        return rendererPageModel.page
    }
    
    func callToActionWillAppear() -> ToolPageCallToActionView? {
        
        if !hidesCallToAction && pageModel.callToAction == nil {
            
            for viewFactory in rendererPageModel.pageViewFactories {
                if let toolPageViewFactory = viewFactory as? ToolPageViewFactory {
                    return toolPageViewFactory.getCallToActionView(callToActionModel: nil, rendererPageModel: rendererPageModel)
                }
            }
        }
        
        return nil
    }
    
    func pageDidAppear() {
        
        let resource: ResourceModel = rendererPageModel.resource
        let page: Int = rendererPageModel.page
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: resource.abbreviation + "-" + String(page), siteSection: resource.abbreviation, siteSubSection: ""))
        
        if page == 0 {
            analytics.appsFlyerAnalytics.trackAction(actionName: analyticsScreenName, data: nil)
        }
    }
    
    func didChangeCardPosition(cardPosition: Int?) {
        self.cardPosition = cardPosition
    }
}
