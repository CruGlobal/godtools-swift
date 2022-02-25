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
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    let factories: [MobileContentPageViewFactoryType]
    
    required init(type: MobileContentRendererPageViewFactoriesType, flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, trainingTipsEnabled: Bool, deepLinkingService: DeepLinkingServiceType) {
        
        self.flowDelegate = flowDelegate
        
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
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                flowDelegate: flowDelegate,
                translationsFileCache: translationsFileCache,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: trainingTipsEnabled
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
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                flowDelegate: flowDelegate,
                translationsFileCache: translationsFileCache,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            pageViewFactories = [toolPageViewFactory, trainingViewFactory]
        
        case .trainingTip:
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                flowDelegate: flowDelegate,
                translationsFileCache: translationsFileCache,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: false
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
    
    func viewForRenderableModel(renderableModel: Any, rendererPageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        for pageViewFactory in factories {
            if let view = pageViewFactory.viewForRenderableModel(renderableModel: renderableModel, rendererPageModel: rendererPageModel) {
                return view
            }
        }

        return nil
    }
}
