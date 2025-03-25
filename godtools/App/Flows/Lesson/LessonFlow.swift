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

    private let toolTranslations: ToolTranslationsDomainModel
    private let appLanguage: AppLanguageDomainModel
    private let trainingTipsEnabled: Bool
    private let initialPageSubIndex: Int?
    
    private var lesson: ResourceModel {
        return toolTranslations.tool
    }
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel, trainingTipsEnabled: Bool, initialPage: MobileContentRendererInitialPage?, initialPageSubIndex: Int?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolTranslations = toolTranslations
        self.appLanguage = appLanguage
        self.trainingTipsEnabled = trainingTipsEnabled
        self.initialPageSubIndex = initialPageSubIndex
                
        if let initialPage = initialPage {
            
            navigateToLesson(isNavigatingFromResumeLessonModal: false, initialPage: initialPage, initialPageSubIndex: initialPageSubIndex, animated: true)
        }
        else if shouldNavigateToResumeLesson {
            
            let resumeLessonModal = getResumeLessonModal()
            
            navigationController.present(resumeLessonModal, animated: true)
        }
        else {
            
            navigateToLesson(isNavigatingFromResumeLessonModal: false, initialPage: initialPage, initialPageSubIndex: initialPageSubIndex, animated: true)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var shouldNavigateToResumeLesson:  Bool {
        
        let lessonProgressLastViewedPageId: String? = userLessonProgress?.lastViewedPageId
        
        let primaryLanguageManifest: Manifest? = toolTranslations.languageTranslationManifests.first?.manifest
        let visiblePages: [Page] = (primaryLanguageManifest?.pages ?? Array()).filter({!$0.isHidden})
        let hasLessonProgress: Bool = lessonProgressLastViewedPageId != nil
        let lessonProgressIsFirstPage: Bool = lessonProgressLastViewedPageId == visiblePages.first?.id
        let lessonProgressIsLastPage: Bool = lessonProgressLastViewedPageId == visiblePages.last?.id
        
        return hasLessonProgress && !lessonProgressIsFirstPage && !lessonProgressIsLastPage
    }
    
    private var userLessonProgress: UserLessonProgressDataModel? {
        return appDiContainer.dataLayer.getUserLessonProgressRepository().getLessonProgress(lessonId: lesson.id)
    }
    
    private var userLessonProgressPage: MobileContentRendererInitialPage? {
        
        guard let pageId = userLessonProgress?.lastViewedPageId else {
            return nil
        }
        
        return .pageId(value: pageId)
    }
    
    private func configureNavigationBar(shouldAnimateNavigationBarHiddenState: Bool) {
        navigationController.setNavigationBarHidden(true, animated: shouldAnimateNavigationBarHiddenState)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .deepLink( _):
            break
            
        case .startOverTappedFromResumeLessonModal:
            navigateToLesson(isNavigatingFromResumeLessonModal: true, initialPage: nil, initialPageSubIndex: initialPageSubIndex, animated: false)
            navigationController.dismissPresented(animated: true, completion: nil)
            
        case .continueTappedFromResumeLessonModal:
            navigateToLesson(isNavigatingFromResumeLessonModal: true, initialPage: userLessonProgressPage, initialPageSubIndex: initialPageSubIndex, animated: false)
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
    
    private func navigateToLesson(isNavigatingFromResumeLessonModal: Bool, initialPage: MobileContentRendererInitialPage?, initialPageSubIndex: Int?, animated: Bool) {
        
        let lessonView = getLessonView(
            initialPage: initialPage,
            initialPageSubIndex: initialPageSubIndex,
            isNavigatingFromResumeLessonModal: isNavigatingFromResumeLessonModal
        )
                
        navigationController.pushViewController(lessonView, animated: animated)
        
        configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
    }
    
    private func closeTool(lessonId: String, highestPageNumberViewed: Int) {
                
        flowDelegate?.navigate(step: .lessonFlowCompleted(state: .userClosedLesson(lessonId: lessonId, highestPageNumberViewed: highestPageNumberViewed)))
    }
}

// MARK: - Views

extension LessonFlow {
    
    private func getLessonView(initialPage: MobileContentRendererInitialPage?, initialPageSubIndex: Int?, isNavigatingFromResumeLessonModal: Bool) -> UIViewController {
        
        let initialPageConfig: MobileContentRendererInitialPageConfig?
        
        if isNavigatingFromResumeLessonModal {
            initialPageConfig = MobileContentRendererInitialPageConfig(shouldNavigateToStartPageIfLastPage: true, shouldNavigateToPreviousVisiblePageIfHiddenPage: true)
        }
        else {
            initialPageConfig = nil
        }
        
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
        
        let viewModel = LessonViewModel(
            flowDelegate: self,
            renderer: renderer,
            resource: renderer.resource,
            primaryLanguage: renderer.languages.primaryLanguage,
            initialPage: initialPage,
            initialPageConfig: initialPageConfig,
            initialPageSubIndex: initialPageSubIndex,
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
        
        return view
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
}

// MARK: - MobileContentRendererNavigationDelegate

extension LessonFlow: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        
        closeTool(lessonId: event.resource.id, highestPageNumberViewed: event.highestPageNumberViewed)
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
