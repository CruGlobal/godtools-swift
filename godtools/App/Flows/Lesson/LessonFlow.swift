//
//  LessonFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class LessonFlow: ToolNavigationFlow, Flow {
                
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, toolTranslations: ToolTranslationsDomainModel, trainingTipsEnabled: Bool, page: Int?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
               
        let navigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            parentFlow: self,
            navigationDelegate: self
        )
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            type: .lesson,
            navigation: navigation,
            toolTranslations: toolTranslations
        )
              
        let viewModel = LessonViewModel(
            flowDelegate: self,
            renderer: renderer,
            resource: renderer.resource,
            primaryLanguage: renderer.primaryLanguage,
            page: page,
            mobileContentEventAnalytics: appDiContainer.getMobileContentEventAnalyticsTracking(),
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        let view = LessonView(viewModel: viewModel)
                
        navigationController.pushViewController(view, animated: true)
        
        configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func configureNavigationBar(shouldAnimateNavigationBarHiddenState: Bool) {
        navigationController.setNavigationBarHidden(true, animated: shouldAnimateNavigationBarHiddenState)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .deepLink(let deepLink):
            break
        
        case .closeTappedFromLesson(let lesson, let highestPageNumberViewed):
            closeTool(lesson: lesson, highestPageNumberViewed: highestPageNumberViewed)
                                                
        case .articleFlowCompleted(let state):
            
            guard articleFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            articleFlow = nil
            
        case .tractFlowCompleted(_):
            
            guard tractFlow != nil else {
                return
            }

            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            tractFlow = nil
            
        case .lessonFlowCompleted(_):
            
            guard lessonFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            lessonFlow = nil
                    
        default:
            break
        }
    }
    
    private func closeTool(lesson: ResourceModel, highestPageNumberViewed: Int) {
        flowDelegate?.navigate(step: .lessonFlowCompleted(state: .userClosedLesson(lesson: lesson, highestPageNumberViewed: highestPageNumberViewed)))
    }
}

extension LessonFlow: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        
        closeTool(lesson: event.resource, highestPageNumberViewed: event.highestPageNumberViewed)
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
