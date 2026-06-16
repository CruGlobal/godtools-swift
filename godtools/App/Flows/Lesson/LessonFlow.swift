//
//  LessonFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared
import Combine

final class LessonFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case userClosedLesson(lessonId: String, highestPageNumberViewed: Int)
    }
    
    private let toolTranslations: ToolTranslationsDomainModel
    private let appLanguage: AppLanguageDomainModel
    private let trainingTipsEnabled: Bool
    private let initialPageSubIndex: Int?
    private let initialPage: MobileContentRendererInitialPage?
    private let toolOpenedFrom: ToolOpenedFrom
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var lesson: ResourceDataModel {
        return toolTranslations.tool
    }
    
    init(
        appDiContainer: AppDiContainer,
        appLanguage: AppLanguageDomainModel,
        toolTranslations: ToolTranslationsDomainModel,
        trainingTipsEnabled: Bool,
        initialPage: MobileContentRendererInitialPage?,
        initialPageSubIndex: Int?,
        toolOpenedFrom: ToolOpenedFrom
    ) {
        
        self.toolTranslations = toolTranslations
        self.appLanguage = appLanguage
        self.trainingTipsEnabled = trainingTipsEnabled
        self.initialPageSubIndex = initialPageSubIndex
        self.initialPage = initialPage
        self.toolOpenedFrom = toolOpenedFrom
        
        super.init(appDiContainer: appDiContainer)
    }
    
    private var userLessonProgress: UserLessonProgressDataModel? {
        return appDiContainer.core.dataLayer.getUserLessonProgressRepository().getLessonProgress(lessonId: lesson.id)
    }
    
    private var userLessonProgressPage: MobileContentRendererInitialPage? {
        
        guard let pageId = userLessonProgress?.lastViewedPageId else {
            return nil
        }
        
        return .pageId(value: pageId)
    }
    
    private func shouldNavigateToResumeLesson(toolOpenedFrom: ToolOpenedFrom) -> Bool {
        
        switch toolOpenedFrom {
        case .dashboardLessons, .dashboardFavoritesFeaturedLesson:
            break
            
        default:
            return false
        }
        
        let lessonProgressLastViewedPageId: String? = userLessonProgress?.lastViewedPageId
        
        let primaryLanguageManifest: Manifest? = toolTranslations.languageTranslationManifests.first?.manifest
        let visiblePages: [Page] = (primaryLanguageManifest?.pages ?? Array()).filter({!$0.isHidden})
        let hasLessonProgress: Bool = lessonProgressLastViewedPageId != nil
        let lessonProgressIsFirstPage: Bool = lessonProgressLastViewedPageId == visiblePages.first?.id
        let lessonProgressIsLastPage: Bool = lessonProgressLastViewedPageId == visiblePages.last?.id
        
        return hasLessonProgress && !lessonProgressIsFirstPage && !lessonProgressIsLastPage
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
        
        case .deepLink( _):
            break
            
        case .closeLessonSwipeTutorial:
            dismissView(animated: true)
            trackSwipeTutorialViewed()
            
        case .startOverTappedFromResumeLessonModal:
            
            navigateToLesson(
                isNavigatingFromResumeLessonModal: true,
                initialPage: nil,
                initialPageSubIndex: initialPageSubIndex,
                animated: false
            )
            
            dismissView(animated: true)
            
        case .continueTappedFromResumeLessonModal:
            
            navigateToLesson(
                isNavigatingFromResumeLessonModal: true,
                initialPage: userLessonProgressPage,
                initialPageSubIndex: initialPageSubIndex,
                animated: false
            )
            
            dismissView(animated: true)
            
            
        case .shareLessonTappedFromLesson(let pageNumber, let languageId):
            presentFlow(
                flow: ShareToolFlow(
                    appDiContainer: appDiContainer,
                    toolId: lesson.id,
                    toolLanguageId: languageId,
                    pageNumber: pageNumber,
                    appLanguage: appLanguage,
                    toolAnalyticsAbbreviation: lesson.abbreviation
                )
            )
            
        case .shareToolFlowCompleted( _):
            dismissFlow()
            
        case .closeTappedFromLesson(let lessonId, let highestPageNumberViewed):
            completeFlow(state: .userClosedLesson(lessonId: lessonId, highestPageNumberViewed: highestPageNumberViewed))
                                                
                        
        case .toolNavigationFlowCompleted( _):
            popFlow(animated: true, popToViewController: initialView)
               
        default:
            break
        }
    }
    
    override func onPushed(animated: Bool) {
        
        if let initialPage = initialPage {
            
            navigateToLesson(
                isNavigatingFromResumeLessonModal: false,
                initialPage: initialPage,
                initialPageSubIndex: initialPageSubIndex,
                animated: true
            )
        }
        else if shouldNavigateToResumeLesson(toolOpenedFrom: toolOpenedFrom) {
            
            presentView(
                view: getResumeLessonModal(),
                animated: true
            )
        }
        else {
            
            navigateToLesson(
                isNavigatingFromResumeLessonModal: false,
                initialPage: initialPage,
                initialPageSubIndex: initialPageSubIndex,
                animated: true
            )
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.lessonFlowCompleted(state: state))
    }
    
    private func navigateToLesson(isNavigatingFromResumeLessonModal: Bool, initialPage: MobileContentRendererInitialPage?, initialPageSubIndex: Int?, animated: Bool) {
        
        let lessonView = getLessonView(
            initialPage: initialPage,
            initialPageSubIndex: initialPageSubIndex,
            isNavigatingFromResumeLessonModal: isNavigatingFromResumeLessonModal
        )
                
        navigationController.pushViewController(lessonView, animated: animated)
                
        showSwipeTutorialIfNeeded()
    }
    
    private func showSwipeTutorialIfNeeded() {
        
        let shouldShow: Bool = appDiContainer.feature.lessonSwipeTutorial.domainlayer
            .getShouldShowLessonSwipeTutorialUseCase()
            .execute()
        
        if shouldShow {
            
            Task {
                
                try await Task.sleep(nanoseconds: 800)
                
                presentView(
                    view: getLessonSwipeTutorial(),
                    animated: true
                )
            }
        }
    }
    
    private func trackSwipeTutorialViewed() {
        
        appDiContainer.feature.lessonSwipeTutorial.domainlayer
            .getTrackViewedLessonSwipeTutorialUseCase()
            .execute()
            .sink { _ in
                
            }
            .store(in: &cancellables)
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
            appLanguage: appLanguage
        )
        
        navigation.setDelegate(delegate: self)
        navigation.setToolFlow(toolFlow: self)
        
        let renderer = appDiContainer.getMobileContentRenderer(
            type: .lesson,
            navigation: navigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations
        )
        
        let viewModel = LessonViewModel(
            stepEmitter: stepEmitter,
            renderer: renderer,
            resource: renderer.resource,
            primaryLanguage: renderer.languages.primaryLanguage,
            initialPage: initialPage,
            initialPageConfig: initialPageConfig,
            initialPageSubIndex: initialPageSubIndex,
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.core.dataLayer.getTranslationsRepository(),
            mobileContentEventAnalytics: appDiContainer.getMobileContentRendererEventAnalyticsTracking(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getTranslatedLanguageName: appDiContainer.core.domainLayer.supporting.getTranslatedLanguageName(),
            storeLessonProgressUseCase: appDiContainer.feature.lessonProgress.domainLayer.getStoreUserLessonProgressUseCase(),
            trainingTipsEnabled: trainingTipsEnabled,
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase()
        )
        
        let view = LessonView(viewModel: viewModel, navigationBar: nil)
        
        return view
    }
    
    private func getLessonSwipeTutorial() -> UIViewController {
        
        let viewModel = LessonSwipeTutorialViewModel(
            stepEmitter: stepEmitter,
            getStringsUseCase: appDiContainer.feature.lessonSwipeTutorial.domainlayer.getLessonSwipeTutorialStringsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase()
        )
        
        let swipeTutorialView = LessonSwipeTutorialView(viewModel: viewModel)
        
        let hostingView = AppHostingController<LessonSwipeTutorialView>(
            rootView: swipeTutorialView,
            navigationBar: nil
        )
        
        hostingView.view.backgroundColor = .clear
        hostingView.modalPresentationStyle = .overFullScreen
        hostingView.modalTransitionStyle = .crossDissolve
        
        return hostingView
    }
    
    private func getResumeLessonModal() -> UIViewController {
        
        let viewModel = ResumeLessonProgressModalViewModel(
            stepEmitter: stepEmitter,
            getResumeLessonProgressStringsUseCase: appDiContainer.feature.lessonProgress.domainLayer.getResumeLessonProgressStringsUseCase(),
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
        completeFlow(state: .userClosedLesson(lessonId: event.resource.id, highestPageNumberViewed: event.highestPageNumberViewed))
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
