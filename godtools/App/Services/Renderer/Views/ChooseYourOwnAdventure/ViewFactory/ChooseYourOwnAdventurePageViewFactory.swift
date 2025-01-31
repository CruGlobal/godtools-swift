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
    
    private static let introPageId: String = "intro"
    private static let categoriesPageId: String = "categories"
    
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let mobileContentAnalytics: MobileContentRendererAnalytics
        
    init(trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let contentPage = renderableModel as? ContentPage {
            
            let contentInsets: UIEdgeInsets
                        
            if contentPage.id == Self.introPageId {
                
                contentInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
            }
            else if contentPage.id == Self.categoriesPageId {
                
                contentInsets = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
            }
            else {
                
                contentInsets = .zero
            }
            
            let viewModel = MobileContentContentPageViewModel(
                contentPage: contentPage,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase
            )
            
            let view = MobileContentContentPageView(
                viewModel: viewModel,
                contentInsets: contentInsets
            )
            
            return view
        }
        
        return nil
    }
}
