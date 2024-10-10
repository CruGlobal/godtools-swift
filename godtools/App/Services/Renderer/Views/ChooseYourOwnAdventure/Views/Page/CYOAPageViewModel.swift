//
//  CYOAPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class CYOAPageViewModel: MobileContentContentPageViewModel {
     
    init(contentPage: Page, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
                
        super.init(contentPage: contentPage, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase, hidesBackgroundImage: false)
    }
    
    override var analyticsScreenName: String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let pageId: String = renderedPageContext.pageModel.id
        let separator: String = ":"
        
        let screenName: String = resource.abbreviation + separator + pageId
        
        return screenName
    }
}
