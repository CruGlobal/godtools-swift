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
    private let mobileContentAnalytics: MobileContentRendererAnalytics
        
    init(analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.analytics = analytics
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let contentPage = renderableModel as? ContentPage {
            
            let contentInsets: UIEdgeInsets
            let itemSpacing: CGFloat
            
            let isIntroPage: Bool = contentPage.id == "intro"
            let isCategoriesPage: Bool = contentPage.id == "categories"
            
            if isIntroPage {
                
                contentInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
                itemSpacing = 28
            }
            else if isCategoriesPage {
                
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
                mobileContentAnalytics: mobileContentAnalytics,
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
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentFlowView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
}
