//
//  LessonPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonPageViewModel: LessonPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, analytics: AnalyticsContainer) {
            
        self.pageNode = pageNode
        self.pageModel = pageModel
        self.analytics = analytics
    }
    
    var manifestDismissListeners: [String] {
        return pageModel.manifest.attributes.dismissListeners
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
