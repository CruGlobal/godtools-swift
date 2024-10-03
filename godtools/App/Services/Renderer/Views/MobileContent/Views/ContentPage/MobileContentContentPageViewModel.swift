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
    
    let contentPage: Page
    let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    init(contentPage: Page, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, hidesBackgroundImage: Bool = false) {
        
        self.contentPage = contentPage
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        super.init(pageModel: contentPage, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, hidesBackgroundImage: hidesBackgroundImage)
    }
    
    override var analyticsScreenName: String {
        
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
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.localeId,
            contentLanguageSecondary: nil
        )
    }
}
