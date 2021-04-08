//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: ToolPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
    
    let hidesCallToAction: Bool
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, analytics: AnalyticsContainer) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
        self.analytics = analytics
        self.hidesCallToAction = (pageNode.callToActionNode == nil && pageModel.pageNode.heroNode == nil) || pageModel.isLastPage
    }
    
    var backgroundColor: UIColor {
        return pageModel.pageColors.backgroundColor
    }
    
    var bottomViewColor: UIColor {
        
        let manifestAttributes: MobileContentXmlManifestAttributes = pageModel.manifest.attributes
        let color: UIColor = manifestAttributes.getNavBarColor()?.color ?? manifestAttributes.getPrimaryColor().color
        
        return color.withAlphaComponent(0.1)
    }
    
    var page: Int {
        return pageModel.page
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
                    
        let manifestAttributes: MobileContentXmlManifestAttributes = pageModel.manifest.attributes
        
        let backgroundImageNode: BackgroundImageNodeType?
        
        if pageNode.backgroundImageExists {
            backgroundImageNode = pageNode
        }
        else if manifestAttributes.backgroundImageExists {
            backgroundImageNode = manifestAttributes
        }
        else {
            backgroundImageNode = nil
        }
        
        if let backgroundImageNode = backgroundImageNode {
            return MobileContentBackgroundImageViewModel(
                backgroundImageNode: backgroundImageNode,
                manifestResourcesCache: pageModel.resourcesCache,
                languageDirection: pageModel.language.languageDirection
            )
        }
        
        return nil
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
