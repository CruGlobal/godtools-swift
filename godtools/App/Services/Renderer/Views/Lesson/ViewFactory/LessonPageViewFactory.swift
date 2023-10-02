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
    
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let mobileContentAnalytics: MobileContentRendererAnalytics
        
    init(trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics) {
    
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let pageModel = renderableModel as? Page {
                     
            let viewModel = LessonPageViewModel(
                pageModel: pageModel,
                renderedPageContext: renderedPageContext,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
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
