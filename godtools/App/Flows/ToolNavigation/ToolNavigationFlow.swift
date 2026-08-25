//
//  ToolNavigationFlow.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Flow

final class ToolNavigationFlow: GTFlow {
    
    enum CompletedState {
        case articleCategoriesFlowCompleted(state: ArticleCategoriesFlow.CompletedState)
        case tractFlowCompleted(state: TractFlow.CompletedState)
        case lessonFlowCompleted(state: LessonFlow.CompletedState)
        case chooseYourOwnAdventureFlowCompleted(state: ChooseYourOwnAdventureFlow.CompletedState)
        case downloadFailed(error: Error)
        case userClosedDownloadTool
    }
    
    private let toolNavigation: ToolNavigation
    private let determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface
        
    convenience init(
        appDiContainer: AppDiContainer,
        appLanguage: AppLanguageDomainModel,
        toolDeepLink: ToolDeepLink
    ) {
        
        let determineDeepLinkedToolTranslationsToDownload = DetermineDeepLinkedToolTranslationsToDownload(
            toolDeepLink: toolDeepLink,
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            languagesRepository: appDiContainer.core.dataLayer.getLanguagesRepository(),
            translationsRepository: appDiContainer.core.dataLayer.getTranslationsRepository(),
            userAppLanguageRepository: appDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository()
        )
        
        let toolNavigation = ToolNavigation(
            appLanguage: appLanguage,
            liveShareStream: toolDeepLink.liveShareStream,
            selectedLanguageIndex: toolDeepLink.selectedLanguageIndex,
            trainingTipsEnabled: false,
            initialPage: toolDeepLink.mobileContentPage,
            initialPageSubIndex: toolDeepLink.pageSubIndex,
            toolOpenedFrom: .deepLink,
            persistToolLanguageSettings: nil
        )
     
        self.init(
            appDiContainer: appDiContainer,
            toolNavigation: toolNavigation,
            determineToolTranslationsToDownload: determineDeepLinkedToolTranslationsToDownload
        )
    }
    
    convenience init(
        appDiContainer: AppDiContainer,
        appLanguage: AppLanguageDomainModel,
        resourceId: String,
        languageIds: [String],
        liveShareStream: String?,
        selectedLanguageIndex: Int?,
        trainingTipsEnabled: Bool,
        initialPage: MobileContentRendererInitialPage?,
        initialPageSubIndex: Int?,
        toolOpenedFrom: ToolOpenedFrom,
        persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    ) {
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: resourceId,
            languageIds: languageIds,
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.core.dataLayer.getTranslationsRepository()
        )
        
        let toolNavigation = ToolNavigation(
            appLanguage: appLanguage,
            liveShareStream: liveShareStream,
            selectedLanguageIndex: selectedLanguageIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            initialPage: initialPage,
            initialPageSubIndex: initialPageSubIndex,
            toolOpenedFrom: toolOpenedFrom,
            persistToolLanguageSettings: persistToolLanguageSettings
        )
     
        self.init(
            appDiContainer: appDiContainer,
            toolNavigation: toolNavigation,
            determineToolTranslationsToDownload: determineToolTranslationsToDownload
        )
    }
    
    init(
        appDiContainer: AppDiContainer,
        toolNavigation: ToolNavigation,
        determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface
    ) {
        
        self.toolNavigation = toolNavigation
        self.determineToolTranslationsToDownload = determineToolTranslationsToDownload
        
        super.init(appDiContainer: appDiContainer)
    }
    
    override func onPushed(animated: Bool) {
        
        let downloadToolUseCase = appDiContainer.core.domainLayer.getDownloadToolUseCase()
        
        Task {
            
            let toolTranslations = try await downloadToolUseCase
                .execute(
                    filter: .downloadManifestAndRelatedFilesForRenderer,
                    determineToolTranslationsToDownload: determineToolTranslationsToDownload,
                    downloadType: .cache
                )
            
            if let toolTranslations = toolTranslations {
                
                navigate(step: AppFlowStep.downloadToolFlowCompleted(state: .downloadSuccess(toolTranslations: toolTranslations)))
            }
            else {
                
                presentFlow(
                    flow: DownloadToolFlow(
                        appDiContainer: appDiContainer,
                        appLanguage: toolNavigation.appLanguage,
                        determineToolTranslationsToDownload: determineToolTranslationsToDownload
                    )
                )
            }
        }
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }
        
        switch appStep {
            
        case .downloadToolFlowCompleted(let state):
            
            switch state {
                
            case .downloadSuccess(toolTranslations: let toolTranslations):
                navigateToTool(toolNavigation: toolNavigation, toolTranslations: toolTranslations, isNavigatingFromResumeLessonModal: false)
                dismissFlow()
            
            case .downloadFailed(let error):
                dismissFlow(animated: true, completion: { [weak self] in
                    self?.completeFlow(state: .downloadFailed(error: error))
                })

            
            case .userClosed:
                dismissFlow(animated: true, completion: { [weak self] in
                    self?.completeFlow(state: .userClosedDownloadTool)
                })
            }
            
        case .articleCategoriesFlowCompleted(let state):
            completeFlow(state: .articleCategoriesFlowCompleted(state: state))
            
        case .tractFlowCompleted(let state):
            completeFlow(state: .tractFlowCompleted(state: state))
            
        case .lessonFlowCompleted(let state):
            completeFlow(state: .lessonFlowCompleted(state: state))
            
        case .chooseYourOwnAdventureFlowCompleted(let state):
            completeFlow(state: .chooseYourOwnAdventureFlowCompleted(state: state))
            
        case .startOverTappedFromResumeLessonModal(let toolTranslations):
            
            navigateToTool(
                toolNavigation: toolNavigation.copy(initialPage: nil),
                toolTranslations: toolTranslations,
                isNavigatingFromResumeLessonModal: true
            )

            dismissView(animated: true)
            
        case .continueTappedFromResumeLessonModal(let toolTranslations):
                        
            navigateToTool(
                toolNavigation: toolNavigation.copy(
                    initialPage: getUserLessonProgressPage(lessonId: toolTranslations.tool.id)
                ),
                toolTranslations: toolTranslations,
                isNavigatingFromResumeLessonModal: true
            )
            
            dismissView(animated: true)

        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.toolNavigationFlowCompleted(state: state))
    }
}

// MARK: - Tool Navigation

extension ToolNavigationFlow {
    
    private func navigateToTool(toolNavigation: ToolNavigation, toolTranslations: ToolTranslationsDomainModel, isNavigatingFromResumeLessonModal: Bool) {
        
        guard toolTranslations.languageTranslationManifests.count > 0 else {
            
            let error: Error = NSError.errorWithDescription(description: "Error navigating to tool. Found 0 translations downloaded for app language \(toolNavigation.appLanguage) and tool abbreviation: \(toolTranslations.tool.abbreviation)")
            
            appDiContainer
                .core
                .dataLayer
                .getErrorReporting()
                .reportError(error: error)
            
            let view = AlertMessageView(
                title: "Internal Error",
                message: "Found 0 translations downloaded.  Ensure you have a network connection and try again.",
                acceptTitle: "OK",
                cancelTitle: nil,
                acceptTapped: nil,
                cancelTapped: nil
            )
            
            presentView(view: view.controller, animated: true, completion: nil)
            
            return
        }
        
        let resourceType: ResourceType = toolTranslations.tool.resourceTypeEnum
        
        switch resourceType {
            
        case .article:
            
            pushFlow(
                flow: ArticleCategoriesFlow(
                    appDiContainer: appDiContainer,
                    toolTranslations: toolTranslations
                )
            )
            
        case .lesson:
            
            let shouldOpenResumeLessonModal: Bool = getShouldNavigateToResumeLesson(
                toolTranslations: toolTranslations,
                toolOpenedFrom: toolNavigation.toolOpenedFrom
            ) && !isNavigatingFromResumeLessonModal
            
            if shouldOpenResumeLessonModal {
                
                presentView(
                    view: getResumeLessonModal(toolTranslations: toolTranslations),
                    animated: true
                )
            }
            else {
                
                pushFlow(
                    flow: LessonFlow(
                        appDiContainer: appDiContainer,
                        appLanguage: toolNavigation.appLanguage,
                        toolTranslations: toolTranslations,
                        trainingTipsEnabled: toolNavigation.trainingTipsEnabled,
                        initialPage: toolNavigation.initialPage,
                        initialPageSubIndex: toolNavigation.initialPageSubIndex,
                        toolOpenedFrom: toolNavigation.toolOpenedFrom,
                        isNavigatingFromResumeLessonModal: isNavigatingFromResumeLessonModal
                    )
                )
            }
            
        case .tract:
            
            pushFlow(
                flow: TractFlow(
                    appDiContainer: appDiContainer,
                    appLanguage: toolNavigation.appLanguage,
                    toolTranslations: toolTranslations,
                    parentFlowIsDashboard: parent is DashboardFlow,
                    liveShareStream: toolNavigation.liveShareStream,
                    selectedLanguageIndex: toolNavigation.selectedLanguageIndex,
                    trainingTipsEnabled: toolNavigation.trainingTipsEnabled,
                    initialPage: toolNavigation.initialPage,
                    initialPageSubIndex: toolNavigation.initialPageSubIndex,
                    persistToolLanguageSettings: toolNavigation.persistToolLanguageSettings
                )
            )
            
        case .chooseYourOwnAdventure:
            
            pushFlow(
                flow: ChooseYourOwnAdventureFlow(
                    appDiContainer: appDiContainer,
                    appLanguage: toolNavigation.appLanguage,
                    toolTranslations: toolTranslations,
                    initialPage: toolNavigation.initialPage,
                    initialPageSubIndex: toolNavigation.initialPageSubIndex,
                    selectedLanguageIndex: toolNavigation.selectedLanguageIndex,
                    trainingTipsEnabled: toolNavigation.trainingTipsEnabled
                )
            )
            
        case .metaTool:
            // NOTE: Navigation is not needed here because MetaTools are not visible in the app (All Tools).
            break
            
        case .unknown:
            
            let view = AlertMessageView(
                title: "Internal Error",
                message: "Attempted to navigate to a tool with an unknown resource type.",
                acceptTitle: "OK",
                cancelTitle: nil,
                acceptTapped: nil,
                cancelTapped: nil
            )
            
            presentView(view: view.controller, animated: true, completion: nil)
            
        }
    }
}
