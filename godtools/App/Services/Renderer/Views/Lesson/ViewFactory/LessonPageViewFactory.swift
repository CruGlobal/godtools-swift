//
//  LessonPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class LessonPageViewFactory: MobileContentPageViewFactoryType {
    
    private let analytics: AnalyticsContainer
    private let mobileContentAnalytics: MobileContentRendererAnalytics
        
    init(analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentRendererAnalytics) {
    
        self.analytics = analytics
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let pageModel = renderableModel as? Page {
                     
            let viewModel = LessonPageViewModel(
                pageModel: pageModel,
                renderedPageContext: renderedPageContext,
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LessonPageView(
                viewModel: viewModel,
                safeArea: renderedPageContext.safeArea
            )
            
            return view
        }
        
        return nil
    }
}
