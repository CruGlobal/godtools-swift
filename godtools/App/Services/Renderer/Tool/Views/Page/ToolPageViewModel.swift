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
    private let toolPageColors: ToolPageColors
    private let analytics: AnalyticsContainer
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, toolPageColors: ToolPageColors, analytics: AnalyticsContainer) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
        self.toolPageColors = toolPageColors
        self.analytics = analytics
    }
    
    var backgroundColor: UIColor {
        return toolPageColors.backgroundColor
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
