//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: MobileContentPageViewModel, ToolPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
    
    let hidesCallToAction: Bool
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, analytics: AnalyticsContainer) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
        self.analytics = analytics
        self.hidesCallToAction = (pageNode.callToActionNode == nil && pageModel.pageNode.heroNode == nil) || pageModel.isLastPage
        
        super.init(pageNode: pageNode, pageModel: pageModel, hidesBackgroundImage: false)
    }
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, hidesBackgroundImage: Bool) {
        fatalError("init(pageNode:pageModel:hidesBackgroundImage:) has not been implemented")
    }
    
    var bottomViewColor: UIColor {
        
        let manifestAttributes: MobileContentXmlManifestAttributes = pageModel.manifest.attributes
        let color: UIColor = manifestAttributes.getNavBarColor()?.color ?? manifestAttributes.getPrimaryColor().color
        
        return color.withAlphaComponent(0.1)
    }
    
    var page: Int {
        return pageModel.page
    }
    
    func callToActionWillAppear() -> ToolPageCallToActionView? {
        
        if !hidesCallToAction && pageNode.callToActionNode == nil {
            
            for viewFactory in pageModel.pageViewFactories {
                if let toolPageViewFactory = viewFactory as? ToolPageViewFactory {
                    return toolPageViewFactory.getCallToActionView(callToActionNode: nil, pageModel: pageModel)
                }
            }
        }
        
        return nil
    }
    
    func pageDidAppear() {
        
        let resource: ResourceModel = pageModel.resource
        let page: Int = pageModel.page
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: resource.abbreviation + "-" + String(page),
            siteSection: resource.abbreviation,
            siteSubSection: ""
        )
    }
}
