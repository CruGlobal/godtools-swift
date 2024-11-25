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
    private let trainingTipsEnabled: Bool
    
    private weak var flowDelegate: FlowDelegate?
    private var renderer: MobileContentRenderer? = nil
    private var initialPageOrPreviousProgress: MobileContentPagesPage? = nil
    
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
        self.trainingTipsEnabled = trainingTipsEnabled
               
        let navigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            parentFlow: self,
            navigationDelegate: self,
            appLanguage: appLanguage
        )
        
        let renderer = appDiContainer.getMobileContentRenderer(
            type: .lesson,
            navigation: navigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations
        )
        self.renderer = renderer
        
        var lastViewedPageId: String? = nil
        if let page = initialPage {
            initialPageOrPreviousProgress = page
            
        } else if let lessonProgress = appDiContainer.dataLayer.getUserLessonProgressRepository().getLessonProgress(lessonId: renderer.resource.id) {
            
            lastViewedPageId = lessonProgress.lastViewedPageId
            initialPageOrPreviousProgress = .pageId(value: lessonProgress.lastViewedPageId)
        }
        
        if let lastViewedPageId = lastViewedPageId, let visiblePages = renderer.pageRenderers.first?.getVisiblePageModels() {
            
            let firstVisiblePage = visiblePages.first
            let lastVisiblePage = visiblePages.last
            
            if firstVisiblePage?.id == lastViewedPageId || lastVisiblePage?.id == lastViewedPageId {
                
                navigateToLesson()
                
            } else {
                
                let resumeLessonModal = getResumeLessonModal()
                
                navigationController.present(resumeLessonModal, animated: true)
            }
        } else {
            navigateToLesson()
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func configureNavigationBar(shouldAnimateNavigationBarHiddenState: Bool) {
        navigationController.setNavigationBarHidden(true, animated: shouldAnimateNavigationBarHiddenState)
    }
    
    func navigateToLesson(shouldStartOver: Bool = false) {
        guard let renderer = renderer else { return }
        
        let viewModel = LessonViewModel(
            flowDelegate: self,
            renderer: renderer,
            resource: renderer.resource,
            primaryLanguage: renderer.languages.primaryLanguage,
            initialPage: shouldStartOver ? nil : initialPageOrPreviousProgress,
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
                
        navigationController.pushViewController(view, animated: false)
        
        configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .deepLink( _):
            break
            
        case .startOverTappedFromResumeLessonModal:
            navigateToLesson(shouldStartOver: true)
            navigationController.dismissPresented(animated: true, completion: nil)
            
        case .continueTappedFromResumeLessonModal:
            navigateToLesson()
            navigationController.dismissPresented(animated: true, completion: nil)
            
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
    
    private func getResumeLessonModal() -> UIViewController {
        let viewModel = ResumeLessonProgressModalViewModel(
            flowDelegate: self,
            getInterfaceStringsUseCase: appDiContainer.feature.lessonProgress.domainLayer.getResumeLessonProgressModalInterfaceStringsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase()
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
