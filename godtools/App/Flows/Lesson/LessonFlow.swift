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
    
    private var tool: ResourceModel {
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
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolTranslations = toolTranslations
        self.appLanguage = appLanguage
        self.trainingTipsEnabled = trainingTipsEnabled
              
        let lessonProgressLastViewedPageId: String? = getUserLessonProgress()?.lastViewedPageId
        
        let primaryLanguageManifest: Manifest? = toolTranslations.languageTranslationManifests.first?.manifest
        let visiblePages: [Page] = (primaryLanguageManifest?.pages ?? Array()).filter({!$0.isHidden})
        let hasLessonProgress: Bool = lessonProgressLastViewedPageId != nil
        let lessonProgressIsFirstPage: Bool = lessonProgressLastViewedPageId == visiblePages.first?.id
        let lessonProgressIsLastPage: Bool = lessonProgressLastViewedPageId == visiblePages.last?.id
        
        if let initialPage = initialPage {
            
            navigateToLesson(initialPage: initialPage, animated: true)
        }
        else if hasLessonProgress && !lessonProgressIsFirstPage && !lessonProgressIsLastPage {
            
            let resumeLessonModal = getResumeLessonModal()
            
            navigationController.present(resumeLessonModal, animated: true)
        }
        else {
            
            navigateToLesson(initialPage: initialPage, animated: true)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func getUserLessonProgress() -> UserLessonProgressDataModel? {
        return appDiContainer.dataLayer.getUserLessonProgressRepository().getLessonProgress(lessonId: tool.id)
    }
    
    private func getUserLessonProgressPage() -> MobileContentPagesPage? {
        
        guard let pageId = getUserLessonProgress()?.lastViewedPageId else {
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
            navigateToLesson(initialPage: nil, animated: false)
            navigationController.dismissPresented(animated: true, completion: nil)
            
        case .continueTappedFromResumeLessonModal:
            navigateToLesson(initialPage: getUserLessonProgressPage(), animated: false)
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
    
    private func navigateToLesson(initialPage: MobileContentPagesPage?, animated: Bool) {
        
        let lessonView = getLessonView(initialPage: initialPage)
                
        navigationController.pushViewController(lessonView, animated: animated)
        
        configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
    }
    
    private func closeTool(lessonId: String, highestPageNumberViewed: Int) {
                
        flowDelegate?.navigate(step: .lessonFlowCompleted(state: .userClosedLesson(lessonId: lessonId, highestPageNumberViewed: highestPageNumberViewed)))
    }
}

extension LessonFlow {
    
    private func getLessonView(initialPage: MobileContentPagesPage?) -> UIViewController {
        
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

extension LessonFlow: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        
        closeTool(lessonId: event.resource.id, highestPageNumberViewed: event.highestPageNumberViewed)
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
