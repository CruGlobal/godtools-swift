//
//  MobileContentContentPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentContentPageViewModel: MobileContentPageViewModel {
    
    private let contentPage: Page
    private let analytics: AnalyticsContainer
    
    init(contentPage: Page, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer) {
        
        self.contentPage = contentPage
        self.analytics = analytics
        
        super.init(pageModel: contentPage, renderedPageContext: renderedPageContext, hidesBackgroundImage: false)
    }
    
    private func getPageAnalyticsScreenName() -> String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let pageId: String = renderedPageContext.pageModel.id
        let separator: String = ":"
        
        let screenName: String = resource.abbreviation + separator + pageId
        
        return screenName
    }
}

// MARK: - Inputs

extension MobileContentContentPageViewModel {
    
    func pageDidAppear() {
        
        let trackScreen = TrackScreenModel(
            screenName: getPageAnalyticsScreenName(),
            siteSection:analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.code,
            secondaryContentLanguage: nil
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
}
