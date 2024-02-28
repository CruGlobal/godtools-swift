//
//  ToolPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ToolPageViewFactory: MobileContentPageViewFactoryType {
        
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let mobileContentAnalytics: MobileContentRendererAnalytics
    private let localizationServices: LocalizationServices
    private let cardJumpService: CardJumpService
    private let followUpService: FollowUpsService
        
    init(trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics, localizationServices: LocalizationServices, cardJumpService: CardJumpService, followUpService: FollowUpsService) {
        
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.mobileContentAnalytics = mobileContentAnalytics
        self.localizationServices = localizationServices
        self.cardJumpService = cardJumpService
        self.followUpService = followUpService
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let cardModel = renderableModel as? MultiplatformCard {
            
            let viewModel = ToolPageCardViewModel(
                cardModel: cardModel.card,
                renderedPageContext: renderedPageContext,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics,
                localizationServices: localizationServices,
                numberOfVisbleCards: cardModel.numberOfVisibleCards,
                trainingTipsEnabled: renderedPageContext.trainingTipsEnabled
            )
            
            let view = ToolPageCardView(viewModel: viewModel)
            
            return view
        }
        else if let callToActionModel = renderableModel as? CallToAction {
            
            return getCallToActionView(
                callToActionModel: callToActionModel,
                renderedPageContext: renderedPageContext
            )
        }
        else if let headerModel = renderableModel as? Header {
            
            let viewModel = ToolPageHeaderViewModel(
                headerModel: headerModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )

            let view = ToolPageHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let heroModel = renderableModel as? Hero {
            
            let viewModel = ToolPageHeroViewModel(
                heroModel: heroModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = ToolPageHeroView(viewModel: viewModel)
            
            return view
        }
        else if let cardsModel = renderableModel as? MultiplatformCards {
            
            let viewModel = ToolPageCardsViewModel(
                cards: cardsModel.cards,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                cardJumpService: cardJumpService
            )
            
            let view = ToolPageCardsView(
                viewModel: viewModel,
                safeArea: renderedPageContext.safeArea
            )
            
            return view
        }
        else if let formModel = renderableModel as? Form {
            
            let viewModel = ToolPageFormViewModel(
                formModel: formModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                followUpService: followUpService,
                localizationServices: localizationServices
            )
            
            let view = ToolPageFormView(viewModel: viewModel)
            
            return view
        }
        else if let modalModel = renderableModel as? Modal {
            
            let viewModel = ToolPageModalViewModel(
                modalModel: modalModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = ToolPageModalView(viewModel: viewModel)
            
            return view
        }
        else if let modalsModel = renderableModel as? MultiplatformModals {
            
            let viewModel = ToolPageModalsViewModel(
                modals: modalsModel.modals,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = ToolPageModalsView(
                viewModel: viewModel,
                windowViewController: renderedPageContext.window
            )
            
            return view
        }
        else if let pageModel = renderableModel as? TractPage {
                    
            let viewModel = ToolPageViewModel(
                pageModel: pageModel,
                renderedPageContext: renderedPageContext,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = ToolPageView(
                viewModel: viewModel,
                safeArea: renderedPageContext.safeArea
            )
            
            return view
        }
        
        return nil
    }
    
    func getCallToActionView(callToActionModel: CallToAction?, renderedPageContext: MobileContentRenderedPageContext) -> ToolPageCallToActionView {
        
        let viewModel = ToolPageCallToActionViewModel(
            callToActionModel: callToActionModel,
            renderedPageContext: renderedPageContext,
            mobileContentAnalytics: mobileContentAnalytics
        )
        
        let view = ToolPageCallToActionView(viewModel: viewModel)
        
        return view
    }
}
