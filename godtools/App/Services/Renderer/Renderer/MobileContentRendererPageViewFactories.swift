//
//  MobileContentRendererPageViewFactories.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentRendererPageViewFactories {
    
    let factories: [MobileContentPageViewFactoryType]
    
    required init(type: MobileContentRendererPageViewFactoriesType, flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, trainingTipsEnabled: Bool, deepLinkingService: DeepLinkingServiceType) {
        
        var pageViewFactories: [MobileContentPageViewFactoryType] = Array()
        
        let analytics: AnalyticsContainer = appDiContainer.analytics
        let mobileContentAnalytics: MobileContentAnalytics = appDiContainer.getMobileContentAnalytics()
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        let mobileContentNodeParser: MobileContentXmlNodeParser = appDiContainer.getMobileContentNodeParser()
        let viewedTrainingTipsService: ViewedTrainingTipsService = appDiContainer.getViewedTrainingTipsService()
        let fontService: FontService = appDiContainer.getFontService()
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        let followUpsService: FollowUpsService = appDiContainer.followUpsService
        let cardJumpService: CardJumpService = appDiContainer.getCardJumpService()
                
        switch type {
        
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
                mobileContentNodeParser: mobileContentNodeParser,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                flowDelegate: flowDelegate,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
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
                mobileContentNodeParser: mobileContentNodeParser,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                flowDelegate: flowDelegate,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            pageViewFactories = [toolPageViewFactory, trainingViewFactory]
        
        case .trainingTip:
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                flowDelegate: flowDelegate,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                viewedTrainingTipsService: viewedTrainingTipsService,
                deepLinkService: deepLinkingService,
                trainingTipsEnabled: false
            )
            
            pageViewFactories = [trainingViewFactory]
        }
        
        let mobileContentPageViewFactory = MobileContentPageViewFactory(
            flowDelegate: flowDelegate,
            mobileContentAnalytics: mobileContentAnalytics,
            fontService: fontService
        )
        
        pageViewFactories.append(mobileContentPageViewFactory)
        
        self.factories = pageViewFactories
    }
}
