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
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    init(contentPage: Page, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.contentPage = contentPage
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        super.init(pageModel: contentPage, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, hidesBackgroundImage: false)
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
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: getPageAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.localeIdentifier,
            contentLanguageSecondary: nil
        )
    }
}
