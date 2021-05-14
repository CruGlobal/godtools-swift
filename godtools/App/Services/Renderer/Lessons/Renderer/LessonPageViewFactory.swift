//
//  LessonPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonPageViewFactory: MobileContentPageViewFactoryType {
    
    private let analytics: AnalyticsContainer
    
    required init(analytics: AnalyticsContainer) {
    
        self.analytics = analytics
    }
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode, pageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?) -> MobileContentView? {
        
        if let pageNode = renderableNode as? PageNode {
                        
            let viewModel = LessonPageViewModel(
                pageNode: pageNode,
                pageModel: pageModel,
                analytics: analytics
            )
            
            let view = LessonPageView(
                viewModel: viewModel,
                safeArea: pageModel.safeArea
            )
            
            return view
        }
        else if let contentNode = renderableNode as? ContentNode {
            
            let viewModel = LessonContentViewModel(
                contentNode: contentNode,
                pageModel: pageModel
            )
            
            let view = LessonContentView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
}
