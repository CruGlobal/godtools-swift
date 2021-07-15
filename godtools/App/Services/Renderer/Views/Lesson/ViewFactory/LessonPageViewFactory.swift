//
//  LessonPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonPageViewFactory: MobileContentPageViewFactoryType {
    
    private let deepLinkService: DeepLinkingServiceType
    private let analytics: AnalyticsContainer
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer) {
    
        self.flowDelegate = flowDelegate
        self.deepLinkService = deepLinkService
        self.analytics = analytics
    }
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode, rendererPageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?) -> MobileContentView? {
        
        if let pageModel = renderableNode as? PageModelType {
                        
            let viewModel = LessonPageViewModel(
                flowDelegate: getFlowDelegate(),
                pageModel: pageModel,
                rendererPageModel: rendererPageModel,
                deepLinkService: deepLinkService,
                analytics: analytics
            )
            
            let view = LessonPageView(
                viewModel: viewModel,
                safeArea: rendererPageModel.safeArea
            )
            
            return view
        }
        else if let contentNode = renderableNode as? ContentNode {
            
            let viewModel = LessonContentViewModel(
                contentNode: contentNode,
                rendererPageModel: rendererPageModel
            )
            
            let view = LessonContentView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
}
