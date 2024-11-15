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
    
    private let appLanguage: AppLanguageDomainModel
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.appLanguage = appLanguage
               
        let navigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            parentFlow: self,
            navigationDelegate: self,
            appLanguage: appLanguage
        )
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            type: .lesson,
            navigation: navigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations
        )
        
        let initialPageOrPreviousProgress: MobileContentPagesPage?
        if let page = initialPage {
            initialPageOrPreviousProgress = page
            
        } else if let lessonProgress = appDiContainer.dataLayer.getUserLessonProgressRepository().getLessonProgress(lessonId: renderer.resource.id) {
            
            initialPageOrPreviousProgress = .pageId(value: lessonProgress.lastViewedPageId)
            
        } else {
            initialPageOrPreviousProgress = nil
        }
        
        let viewModel = LessonViewModel(
            flowDelegate: self,
            renderer: renderer,
            resource: renderer.resource,
            primaryLanguage: renderer.languages.primaryLanguage,
            initialPage: initialPageOrPreviousProgress,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            mobileContentEventAnalytics: appDiContainer.getMobileContentRendererEventAnalyticsTracking(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getTranslatedLanguageName: appDiContainer.dataLayer.getTranslatedLanguageName(),
            storeLessonProgressUseCase: appDiContainer.feature.lessonProgress.domainLayer.getStoreUserLessonProgressUseCase(),
            trainingTipsEnabled: trainingTipsEnabled,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase()
        )
        
        let view = LessonView(viewModel: viewModel, navigationBar: nil)
                
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
        
        case .deepLink( _):
            break
        
        case .presentResumeLessonModal(let startOverClosure):
            let resumeLessonModal = getResumeLessonModal(startOverClosure: {
                startOverClosure()
                self.navigationController.dismissPresented(animated: true, completion: nil)
                
            }, continueClosure: {
                self.navigationController.dismissPresented(animated: true, completion: nil)
            })
            
            navigationController.present(resumeLessonModal, animated: true)
            
        case .closeTappedFromLesson(let lessonId, let highestPageNumberViewed):
            closeTool(lessonId: lessonId, highestPageNumberViewed: highestPageNumberViewed)
                                                
        case .articleFlowCompleted( _):
            
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
    
    private func getResumeLessonModal(startOverClosure: @escaping () -> Void, continueClosure: @escaping () -> Void) -> UIViewController {
        let viewModel = ResumeLessonProgressModalViewModel(
            getInterfaceStringsUseCase: appDiContainer.feature.lessonProgress.domainLayer.getResumeLessonProgressModalInterfaceStringsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            startOverClosure: startOverClosure,
            continueClosure: continueClosure
        )
        
        let resumeLessonModal = ResumeLessonProgressModal(viewModel: viewModel)
        
        let hostingView = AppHostingController<ResumeLessonProgressModal>(
            rootView: resumeLessonModal,
            navigationBar: nil
        )
        
        hostingView.view.backgroundColor = .clear
        hostingView.modalPresentationStyle = .overFullScreen
        hostingView.modalTransitionStyle = .crossDissolve
        
        return hostingView
    }
    
    private func closeTool(lessonId: String, highestPageNumberViewed: Int) {
                
        flowDelegate?.navigate(step: .lessonFlowCompleted(state: .userClosedLesson(lessonId: lessonId, highestPageNumberViewed: highestPageNumberViewed)))
    }
}

extension LessonFlow: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        
        closeTool(lessonId: event.resource.id, highestPageNumberViewed: event.highestPageNumberViewed)
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
