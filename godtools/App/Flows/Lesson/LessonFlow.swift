//
//  LessonFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Combine

final class LessonFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case userClosedLesson(lessonId: String, lessonLanguage: AppLanguageDomainModel, highestPageNumberViewed: Int, toolOpenedFrom: ToolOpenedFrom)
    }
    
    private let toolTranslations: ToolTranslationsDomainModel
    private let appLanguage: AppLanguageDomainModel
    private let trainingTipsEnabled: Bool
    private let initialPageSubIndex: Int?
    private let initialPage: MobileContentRendererInitialPage?
    private let toolOpenedFrom: ToolOpenedFrom

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
        toolOpenedFrom: ToolOpenedFrom,
        isNavigatingFromResumeLessonModal: Bool
    ) {
        
        self.toolTranslations = toolTranslations
        self.appLanguage = appLanguage
        self.trainingTipsEnabled = trainingTipsEnabled
        self.initialPageSubIndex = initialPageSubIndex
        self.initialPage = initialPage
        self.toolOpenedFrom = toolOpenedFrom
        
        let stepEmitter = FlowStepEmitter()
        
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
        
        let lessonView = LessonView(viewModel: viewModel, navigationBar: nil)

        super.init(
            appDiContainer: appDiContainer,
            initialView: lessonView,
            stepEmitter: stepEmitter
        )
        
        navigation.setDelegate(delegate: self)
        navigation.setToolFlow(toolFlow: self)
        
        showSwipeTutorialIfNeeded()
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
            
        case .closeTappedFromLesson(let lessonId, let lessonLanguage, let highestPageNumberViewed):
            completeFlow(
                state: .userClosedLesson(
                    lessonId: lessonId,
                    lessonLanguage: lessonLanguage,
                    highestPageNumberViewed: highestPageNumberViewed,
                    toolOpenedFrom: toolOpenedFrom
                )
            )
                                                
                        
        case .toolNavigationFlowCompleted( _):
            popFlow(animated: true, popToViewController: initialView)
               
        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.lessonFlowCompleted(state: state))
    }
    
    private func showSwipeTutorialIfNeeded() {
        
        Task {
            
            let shouldShow: Bool = await appDiContainer.feature.lessonSwipeTutorial.domainlayer
                .getShouldShowLessonSwipeTutorialUseCase()
                .execute()
            
            guard shouldShow else {
                return
            }
            
            try await Task.sleep(nanoseconds: 800)
            
            presentView(
                view: getLessonSwipeTutorial(),
                animated: true
            )
        }
    }
    
    private func trackSwipeTutorialViewed() {
        
        Task {
            await appDiContainer.feature.lessonSwipeTutorial.domainlayer
                .getTrackViewedLessonSwipeTutorialUseCase()
                .execute()
        }
    }
}

// MARK: - Views

extension LessonFlow {
    
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
}

// MARK: - MobileContentRendererNavigationDelegate

extension LessonFlow: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        completeFlow(
            state: .userClosedLesson(
                lessonId: event.resource.id,
                lessonLanguage: event.language,
                highestPageNumberViewed: event.highestPageNumberViewed,
                toolOpenedFrom: toolOpenedFrom
            )
        )
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
