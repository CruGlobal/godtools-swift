//
//  ChooseYourOwnAdventurePageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ChooseYourOwnAdventurePageViewFactory: MobileContentPageViewFactoryType {
    
    private let deepLinkingService: DeepLinkingServiceType
    private let analytics: AnalyticsContainer
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, deepLinkingService: DeepLinkingServiceType, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.deepLinkingService = deepLinkingService
        self.analytics = analytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let contentPage = renderableModel as? ContentPage {
            
            guard let flowDelegate = self.flowDelegate else {
                return nil
            }
            
            let page: Int = renderedPageContext.page
            let contentInsets: UIEdgeInsets
            let itemSpacing: CGFloat
            
            if page == 0 {
                
                contentInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
                itemSpacing = 28
            }
            else if page == 1 {
                
                contentInsets = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
                itemSpacing = 30
            }
            else {
                
                contentInsets = .zero
                itemSpacing = 20
            }
            
            let viewModel = MobileContentContentPageViewModel(
                flowDelegate: flowDelegate,
                contentPage: contentPage,
                renderedPageContext: renderedPageContext,
                deepLinkService: deepLinkingService,
                analytics: analytics
            )
            
            let view = MobileContentContentPageView(
                viewModel: viewModel,
                contentInsets: contentInsets,
                itemSpacing: itemSpacing
            )
            
            return view
        }
        else if let contentFlow = renderableModel as? GodToolsToolParser.Flow {
            
            let viewModel = MobileContentFlowViewModel(
                contentFlow: contentFlow,
                renderedPageContext: renderedPageContext
            )
            
            let view = MobileContentFlowView(viewModel: viewModel, itemSpacing: 16)
            
            return view
        }
        
        return nil
    }
}
