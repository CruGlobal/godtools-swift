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
    private let trainingTipsEnabled: Bool
    
    required init(analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, localizationServices: LocalizationServices, cardJumpService: CardJumpService, followUpService: FollowUpsService, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService, trainingTipsEnabled: Bool) {
        
        self.analytics = analytics
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.cardJumpService = cardJumpService
        self.followUpService = followUpService
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.viewedTrainingTipsService = viewedTrainingTipsService
        self.trainingTipsEnabled = trainingTipsEnabled
    }
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode, pageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        if let cardNode = renderableNode as? CardNode, let cardsNode = cardNode.parent as? CardsNode {
            
            let viewModel = ToolPageCardViewModel(
                cardNode: cardNode,
                cardsNode: cardsNode,
                pageModel: pageModel,
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
                localizationServices: localizationServices,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            let view = ToolPageCardView(viewModel: viewModel)
            
            return view
        }
        else if let callToActionNode = renderableNode as? CallToActionNode {
            
            return getCallToActionView(
                callToActionNode: callToActionNode,
                pageModel: pageModel
            )
        }
        else if let headerNode = renderableNode as? HeaderNode {
            
            let viewModel = ToolPageHeaderViewModel(
                headerNode: headerNode,
                pageModel: pageModel,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                viewedTrainingTipsService: viewedTrainingTipsService,
                trainingTipsEnabled: trainingTipsEnabled
            )

            let view = ToolPageHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let heroNode = renderableNode as? HeroNode {
            
            let viewModel = ToolPageHeroViewModel(
                heroNode: heroNode,
                pageModel: pageModel,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = ToolPageHeroView(viewModel: viewModel)
            
            return view
        }
        else if let cardsNode = renderableNode as? CardsNode {
            
            let viewModel = ToolPageCardsViewModel(
                cardsNode: cardsNode,
                pageModel: pageModel,
                cardJumpService: cardJumpService
            )
            
            let view = ToolPageCardsView(
                viewModel: viewModel,
                safeArea: pageModel.safeArea
            )
            
            return view
        }
        else if let formNode = renderableNode as? ContentFormNode {
            
            let viewModel = ToolPageFormViewModel(
                formNode: formNode,
                pageModel: pageModel,
                followUpService: followUpService,
                localizationServices: localizationServices
            )
            
            let view = ToolPageFormView(viewModel: viewModel)
            
            return view
        }
        else if let modalNode = renderableNode as? ModalNode {
            
            let viewModel = ToolPageModalViewModel(
                modalNode: modalNode,
                pageModel: pageModel
            )
            
            let view = ToolPageModalView(viewModel: viewModel)
            
            return view
        }
        else if let modalsNode = renderableNode as? ModalsNode {
            
            let viewModel = ToolPageModalsViewModel(
                modalsNode: modalsNode,
                pageModel: pageModel
            )
            
            let view = ToolPageModalsView(
                viewModel: viewModel,
                windowViewController: pageModel.window
            )
            
            return view
        }
        else if let pageNode = renderableNode as? PageNode {
            
            // TODO: I need to fix initial positions. ~Levi
            
            let viewModel = ToolPageViewModel(
                pageNode: pageNode,
                pageModel: pageModel,
                analytics: analytics
            )
            
            let view = ToolPageView(
                viewModel: viewModel,
                safeArea: pageModel.safeArea
            )
            
            return view
        }
        
        return nil
    }
    
    func getCallToActionView(callToActionNode: CallToActionNode?, pageModel: MobileContentRendererPageModel) -> ToolPageCallToActionView {
        
        let viewModel = ToolPageCallToActionViewModel(
            callToActionNode: callToActionNode,
            pageModel: pageModel,
            fontService: fontService
        )
        
        let view = ToolPageCallToActionView(viewModel: viewModel)
        
        return view
    }
}
