//
//  ToolPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolPageViewFactory: MobileContentPageViewFactoryType {
        
    private let analytics: AnalyticsContainer
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let cardJumpService: CardJumpService
    private let followUpService: FollowUpsService
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    private let viewedTrainingTipsService: ViewedTrainingTipsService
    private let deepLinkService: DeepLinkingServiceType
    private let trainingTipsEnabled: Bool
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, localizationServices: LocalizationServices, cardJumpService: CardJumpService, followUpService: FollowUpsService, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService, deepLinkService: DeepLinkingServiceType, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.cardJumpService = cardJumpService
        self.followUpService = followUpService
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.viewedTrainingTipsService = viewedTrainingTipsService
        self.deepLinkService = deepLinkService
        self.trainingTipsEnabled = trainingTipsEnabled
    }
    
    func viewForRenderableModel(renderableModel: MobileContentRenderableModel, renderableModelParent: MobileContentRenderableModel?, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?, primaryLanguage: LanguageModel) -> MobileContentView? {
        
        if let cardModel = renderableModel as? CardModelType {
            
            let viewModel = ToolPageCardViewModel(
                cardModel: cardModel,
                rendererPageModel: rendererPageModel,
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
                localizationServices: localizationServices,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            let view = ToolPageCardView(viewModel: viewModel)
            
            return view
        }
        else if let callToActionModel = renderableModel as? CallToActionModelType {
            
            return getCallToActionView(
                callToActionModel: callToActionModel,
                rendererPageModel: rendererPageModel
            )
        }
        else if let headerModel = renderableModel as? HeaderModelType {
            
            let viewModel = ToolPageHeaderViewModel(
                headerModel: headerModel,
                rendererPageModel: rendererPageModel,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                viewedTrainingTipsService: viewedTrainingTipsService
            )

            let view = ToolPageHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let heroModel = renderableModel as? HeroModelType {
            
            let viewModel = ToolPageHeroViewModel(
                heroModel: heroModel,
                rendererPageModel: rendererPageModel,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = ToolPageHeroView(viewModel: viewModel)
            
            return view
        }
        else if let cardsModel = renderableModel as? CardsModelType {
            
            let viewModel = ToolPageCardsViewModel(
                cardsModel: cardsModel,
                rendererPageModel: rendererPageModel,
                cardJumpService: cardJumpService
            )
            
            let view = ToolPageCardsView(
                viewModel: viewModel,
                safeArea: rendererPageModel.safeArea
            )
            
            return view
        }
        else if let formModel = renderableModel as? ContentFormModelType {
            
            let viewModel = ToolPageFormViewModel(
                formModel: formModel,
                rendererPageModel: rendererPageModel,
                followUpService: followUpService,
                localizationServices: localizationServices
            )
            
            let view = ToolPageFormView(viewModel: viewModel)
            
            return view
        }
        else if let modalModel = renderableModel as? ModalModelType {
            
            let viewModel = ToolPageModalViewModel(
                modalModel: modalModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = ToolPageModalView(viewModel: viewModel)
            
            return view
        }
        else if let modalsModel = renderableModel as? ModalsModelType {
            
            let viewModel = ToolPageModalsViewModel(
                modalsModel: modalsModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = ToolPageModalsView(
                viewModel: viewModel,
                windowViewController: rendererPageModel.window
            )
            
            return view
        }
        else if let pageModel = renderableModel as? PageModelType {
                        
            let viewModel = ToolPageViewModel(
                flowDelegate: getFlowDelegate(),
                pageModel: pageModel,
                rendererPageModel: rendererPageModel,
                deepLinkService: deepLinkService,
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = ToolPageView(
                viewModel: viewModel,
                safeArea: rendererPageModel.safeArea
            )
            
            return view
        }
        
        return nil
    }
    
    func getCallToActionView(callToActionModel: CallToActionModelType?, rendererPageModel: MobileContentRendererPageModel) -> ToolPageCallToActionView {
        
        let viewModel = ToolPageCallToActionViewModel(
            callToActionModel: callToActionModel,
            rendererPageModel: rendererPageModel,
            fontService: fontService
        )
        
        let view = ToolPageCallToActionView(viewModel: viewModel)
        
        return view
    }
}
