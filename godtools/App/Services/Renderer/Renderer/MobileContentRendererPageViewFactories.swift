//
//  MobileContentRendererPageViewFactories.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class MobileContentRendererPageViewFactories: MobileContentPageViewFactoryType {
        
    let factories: [MobileContentPageViewFactoryType]
    
    init(type: MobileContentRendererPageViewFactoriesType, appDiContainer: AppDiContainer) {
                
        var pageViewFactories: [MobileContentPageViewFactoryType] = Array()
        
        let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase = appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        let mobileContentAnalytics: MobileContentRendererAnalytics = appDiContainer.getMobileContentRendererAnalytics()
        let localizationServices: LocalizationServicesInterface = appDiContainer.dataLayer.getLocalizationServices()
        let followUpsService: FollowUpsService = appDiContainer.dataLayer.getFollowUpsService()
        let cardJumpService: CardJumpService = appDiContainer.getCardJumpService()
        
        let getTrainingTipCompletedUseCase = appDiContainer.domainLayer.getTrainingTipCompletedUseCase()
                
        switch type {
        
        case .chooseYourOwnAdventure:
            
            let trainingViewFactory: TrainingViewFactory = TrainingViewFactory(
                mobileContentAnalytics: mobileContentAnalytics,
                getTrainingTipCompletedUseCase: getTrainingTipCompletedUseCase
            )
            
            pageViewFactories = [trainingViewFactory]
            
        case .lesson:
            
            let lessonPageViewFactory = LessonPageViewFactory(
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let tractPageViewFactory = TractPageViewFactory(
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
            
            pageViewFactories = [lessonPageViewFactory, tractPageViewFactory, trainingViewFactory]
        
        case .tract:
            
            let tractPageViewFactory = TractPageViewFactory(
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
            
            pageViewFactories = [tractPageViewFactory, trainingViewFactory]
        
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
