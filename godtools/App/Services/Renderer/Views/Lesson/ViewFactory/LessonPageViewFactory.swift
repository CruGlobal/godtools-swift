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
    
    private let deepLinkService: DeepLinkingServiceType
    private let analytics: AnalyticsContainer
    private let mobileContentAnalytics: MobileContentAnalytics
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics) {
    
        self.flowDelegate = flowDelegate
        self.deepLinkService = deepLinkService
        self.analytics = analytics
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, rendererPageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        if let pageModel = renderableModel as? Page {
                    
            guard let flowDelegate = self.flowDelegate else {
                return nil
            }
            
            let viewModel = LessonPageViewModel(
                flowDelegate: flowDelegate,
                pageModel: pageModel,
                rendererPageModel: rendererPageModel,
                deepLinkService: deepLinkService,
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LessonPageView(
                viewModel: viewModel,
                safeArea: rendererPageModel.safeArea
            )
            
            return view
        }
        
        return nil
    }
}
