//
//  ChooseYourOwnAdventurePageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ChooseYourOwnAdventurePageViewFactory: MobileContentPageViewFactoryType {
    
    private let analytics: AnalyticsContainer
        
    required init(analytics: AnalyticsContainer) {
        
        self.analytics = analytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let contentPage = renderableModel as? ContentPage {
            
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
                contentPage: contentPage,
                renderedPageContext: renderedPageContext,
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
            
            let view = MobileContentFlowView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
}
