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
    
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let mobileContentAnalytics: MobileContentRendererAnalytics
        
    init(trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let contentPage = renderableModel as? ContentPage {
            
            let contentInsets: UIEdgeInsets
            
            let isIntroPage: Bool = contentPage.id == "intro"
            let isCategoriesPage: Bool = contentPage.id == "categories"
            
            if isIntroPage {
                
                contentInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
            }
            else if isCategoriesPage {
                
                contentInsets = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
            }
            else {
                
                contentInsets = .zero
            }
            
            let viewModel = CYOAPageViewModel(
                contentPage: contentPage,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase
            )
            
            let view = CYOAPageView(
                viewModel: viewModel,
                contentInsets: contentInsets
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
