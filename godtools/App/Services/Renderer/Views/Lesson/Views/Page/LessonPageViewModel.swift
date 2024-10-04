//
//  LessonPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class LessonPageViewModel: MobileContentPageViewModel {
    
    private let pageModel: Page
    
    init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics) {
            
        self.pageModel = pageModel
        
        super.init(pageModel: pageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase, hidesBackgroundImage: false)
    }
    
    override func pageDidAppear() {
            
        super.pageDidAppear()
    }
}
