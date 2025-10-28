//
//  TractPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class TractPageViewFactory: MobileContentPageViewFactoryType {
        
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let mobileContentAnalytics: MobileContentRendererAnalytics
    private let localizationServices: LocalizationServicesInterface
    private let cardJumpService: CardJumpService
    private let followUpService: FollowUpsService
        
    init(trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics, localizationServices: LocalizationServicesInterface, cardJumpService: CardJumpService, followUpService: FollowUpsService) {
        
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.mobileContentAnalytics = mobileContentAnalytics
        self.localizationServices = localizationServices
        self.cardJumpService = cardJumpService
        self.followUpService = followUpService
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let cardModel = renderableModel as? MultiplatformCard {
            
            let viewModel = TractPageCardViewModel(
                cardModel: cardModel.card,
                renderedPageContext: renderedPageContext,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics,
                localizationServices: localizationServices,
                numberOfVisbleCards: cardModel.numberOfVisibleCards,
                trainingTipsEnabled: renderedPageContext.trainingTipsEnabled
            )
            
            let view = TractPageCardView(viewModel: viewModel)
            
            return view
        }
        else if let callToActionModel = renderableModel as? CallToAction {
            
            return getCallToActionView(
                callToActionModel: callToActionModel,
                renderedPageContext: renderedPageContext
            )
        }
        else if let headerModel = renderableModel as? Header {
            
            let viewModel = TractPageHeaderViewModel(
                headerModel: headerModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )

            let view = TractPageHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let heroModel = renderableModel as? Hero {
            
            let viewModel = TractPageHeroViewModel(
                heroModel: heroModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = TractPageHeroView(viewModel: viewModel)
            
            return view
        }
        else if let cardsModel = renderableModel as? MultiplatformCards {
            
            let viewModel = TractPageCardsViewModel(
                cards: cardsModel.cards,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                cardJumpService: cardJumpService
            )
            
            let view = TractPageCardsView(
                viewModel: viewModel,
                safeArea: renderedPageContext.safeArea
            )
            
            return view
        }
        else if let formModel = renderableModel as? Form {
            
            let viewModel = TractPageFormViewModel(
                formModel: formModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                followUpService: followUpService,
                localizationServices: localizationServices
            )
            
            let view = TractPageFormView(viewModel: viewModel)
            
            return view
        }
        else if let modalModel = renderableModel as? Modal {
            
            let viewModel = TractPageModalViewModel(
                modalModel: modalModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = TractPageModalView(viewModel: viewModel)
            
            return view
        }
        else if let modalsModel = renderableModel as? MultiplatformModals {
            
            let viewModel = TractPageModalsViewModel(
                modals: modalsModel.modals,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = TractPageModalsView(
                viewModel: viewModel,
                windowViewController: renderedPageContext.window
            )
            
            return view
        }
        else if let pageModel = renderableModel as? TractPage {
                    
            let viewModel = TractPageViewModel(
                pageModel: pageModel,
                renderedPageContext: renderedPageContext,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = TractPageView(
                viewModel: viewModel,
                safeArea: renderedPageContext.safeArea
            )
            
            return view
        }
        
        return nil
    }
    
    func getCallToActionView(callToActionModel: CallToAction?, renderedPageContext: MobileContentRenderedPageContext) -> TractPageCallToActionView {
        
        let viewModel = TractPageCallToActionViewModel(
            callToActionModel: callToActionModel,
            renderedPageContext: renderedPageContext,
            mobileContentAnalytics: mobileContentAnalytics
        )
        
        let view = TractPageCallToActionView(viewModel: viewModel)
        
        return view
    }
}
