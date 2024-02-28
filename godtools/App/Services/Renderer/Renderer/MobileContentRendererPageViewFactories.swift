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
    
    init(type: MobileContentRendererPageViewFactoriesType, appDiContainer: AppDiContainer) {
                
        var pageViewFactories: [MobileContentPageViewFactoryType] = Array()
        
        let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase = appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        let mobileContentAnalytics: MobileContentRendererAnalytics = appDiContainer.getMobileContentRendererAnalytics()
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        let followUpsService: FollowUpsService = appDiContainer.dataLayer.getFollowUpsService()
        let cardJumpService: CardJumpService = appDiContainer.getCardJumpService()
        
        let getTrainingTipCompletedUseCase = appDiContainer.domainLayer.getTrainingTipCompletedUseCase()
                
        switch type {
        
        case .chooseYourOwnAdventure:
            
            let chooseYourOwnAdventureViewFactory = ChooseYourOwnAdventurePageViewFactory(
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            pageViewFactories = [chooseYourOwnAdventureViewFactory]
            
        case .lesson:
            
            let lessonPageViewFactory = LessonPageViewFactory(
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let toolPageViewFactory = ToolPageViewFactory(
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics,
                localizationServices: localizationServices,
                cardJumpService: cardJumpService,
                followUpService: followUpsService
            )
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                mobileContentAnalytics: mobileContentAnalytics,
                getTrainingTipCompletedUseCase: getTrainingTipCompletedUseCase
            )
            
            pageViewFactories = [lessonPageViewFactory, toolPageViewFactory, trainingViewFactory]
        
        case .tract:
            
            let toolPageViewFactory = ToolPageViewFactory(
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics,
                localizationServices: localizationServices,
                cardJumpService: cardJumpService,
                followUpService: followUpsService
            )
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                mobileContentAnalytics: mobileContentAnalytics,
                getTrainingTipCompletedUseCase: getTrainingTipCompletedUseCase
            )
            
            pageViewFactories = [toolPageViewFactory, trainingViewFactory]
        
        case .trainingTip:
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                mobileContentAnalytics: mobileContentAnalytics,
                getTrainingTipCompletedUseCase: getTrainingTipCompletedUseCase
            )
            
            pageViewFactories = [trainingViewFactory]
        }
        
        let mobileContentPageViewFactory = MobileContentPageViewFactory(
            mobileContentAnalytics: mobileContentAnalytics,
            trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase
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
