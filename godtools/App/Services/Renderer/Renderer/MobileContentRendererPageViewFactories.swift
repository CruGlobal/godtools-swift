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
        
        let analytics: AnalyticsContainer = appDiContainer.dataLayer.getAnalytics()
        let mobileContentAnalytics: MobileContentRendererAnalytics = appDiContainer.getMobileContentRendererAnalytics()
        let fontService: FontService = appDiContainer.getFontService()
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        let followUpsService: FollowUpsService = appDiContainer.dataLayer.getFollowUpsService()
        let cardJumpService: CardJumpService = appDiContainer.getCardJumpService()
        
        let getTrainingTipCompletedUseCase = appDiContainer.domainLayer.getTrainingTipCompletedUseCase()
                
        switch type {
        
        case .chooseYourOwnAdventure:
            
            let chooseYourOwnAdventureViewFactory = ChooseYourOwnAdventurePageViewFactory(
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            pageViewFactories = [chooseYourOwnAdventureViewFactory]
            
        case .lesson:
            
            let lessonPageViewFactory = LessonPageViewFactory(
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let toolPageViewFactory = ToolPageViewFactory(
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
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
                analytics: analytics,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
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
            fontService: fontService,
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
