//
//  MobileContentRendererPageViewFactories.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentRendererPageViewFactories: MobileContentPageViewFactoryType {
        
    let factories: [MobileContentPageViewFactoryType]
    
    required init(type: MobileContentRendererPageViewFactoriesType, flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, deepLinkingService: DeepLinkingServiceType) {
                
        var pageViewFactories: [MobileContentPageViewFactoryType] = Array()
        
        let analytics: AnalyticsContainer = appDiContainer.analytics
        let mobileContentAnalytics: MobileContentAnalytics = appDiContainer.getMobileContentAnalytics()
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        let viewedTrainingTipsService: ViewedTrainingTipsService = appDiContainer.getViewedTrainingTipsService()
        let fontService: FontService = appDiContainer.getFontService()
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        let followUpsService: FollowUpsService = appDiContainer.followUpsService
        let cardJumpService: CardJumpService = appDiContainer.getCardJumpService()
                
        switch type {
        
        case .chooseYourOwnAdventure:
            
            let chooseYourOwnAdventureViewFactory = ChooseYourOwnAdventurePageViewFactory(
                flowDelegate: flowDelegate,
                deepLinkingService: deepLinkingService,
                analytics: analytics
            )
            
            pageViewFactories = [chooseYourOwnAdventureViewFactory]
            
        case .lesson:
            
            let lessonPageViewFactory = LessonPageViewFactory(
                flowDelegate: flowDelegate,
                deepLinkService: deepLinkingService,
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let toolPageViewFactory = ToolPageViewFactory(
                flowDelegate: flowDelegate,
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
                localizationServices: localizationServices,
                cardJumpService: cardJumpService,
                followUpService: followUpsService,
                translationsFileCache: translationsFileCache,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService
            )
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                translationsFileCache: translationsFileCache,
                viewedTrainingTipsService: viewedTrainingTipsService
            )
            
            pageViewFactories = [lessonPageViewFactory, toolPageViewFactory, trainingViewFactory]
        
        case .tract:
            
            let toolPageViewFactory = ToolPageViewFactory(
                flowDelegate: flowDelegate,
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
                localizationServices: localizationServices,
                cardJumpService: cardJumpService,
                followUpService: followUpsService,
                translationsFileCache: translationsFileCache,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService
            )
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                translationsFileCache: translationsFileCache,
                viewedTrainingTipsService: viewedTrainingTipsService
            )
            
            pageViewFactories = [toolPageViewFactory, trainingViewFactory]
        
        case .trainingTip:
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                translationsFileCache: translationsFileCache,
                viewedTrainingTipsService: viewedTrainingTipsService
            )
            
            pageViewFactories = [trainingViewFactory]
        }
        
        let mobileContentPageViewFactory = MobileContentPageViewFactory(
            flowDelegate: flowDelegate,
            mobileContentAnalytics: mobileContentAnalytics,
            fontService: fontService,
            deepLinkingService: deepLinkingService,
            analytics: analytics
        )
        
        pageViewFactories.append(mobileContentPageViewFactory)
        
        self.factories = pageViewFactories
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        for pageViewFactory in factories {
            if let view = pageViewFactory.viewForRenderableModel(renderableModel: renderableModel, renderableModelParent: renderableModelParent, renderedPageContext: renderedPageContext) {
                return view
            }
        }

        return nil
    }
}
