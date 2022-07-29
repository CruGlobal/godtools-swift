//
//  ToolNavigationFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol ToolNavigationFlow: Flow {
    
    var articleFlow: ArticleFlow? { get set }
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow? { get set }
    var lessonFlow: LessonFlow? { get set }
    var tractFlow: TractFlow? { get set }
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow? { get set }
}

extension ToolNavigationFlow {
        
    func navigateToToolFromToolDeepLink(toolDeepLink: ToolDeepLink, didCompleteToolNavigation: ((_ resource: ResourceModel) -> Void)?) {
        
        let determineDeepLinkedToolTranslationsToDownload = DetermineDeepLinkedToolTranslationsToDownload(
            toolDeepLink: toolDeepLink,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: appDiContainer.dataLayer.getLanguagesRepository(),
            languageSettingsService: appDiContainer.languageSettingsService
        )
        
        navigateToToolAndDetermineToolTranslationsToDownload(
            determineToolTranslationsToDownload: determineDeepLinkedToolTranslationsToDownload,
            liveShareStream: toolDeepLink.liveShareStream,
            trainingTipsEnabled: false,
            page: toolDeepLink.page
        )
    }
    
    func navigateToTool(resourceId: String, trainingTipsEnabled: Bool) {
        
        let languageSettingsService: LanguageSettingsService = appDiContainer.languageSettingsService
        
        var languageIds: [String] = Array()
        
        if let primaryLanguageId = languageSettingsService.primaryLanguage.value?.id {
            languageIds.append(primaryLanguageId)
        }
        
        if let parallelLanguageId = languageSettingsService.parallelLanguage.value?.id {
            languageIds.append(parallelLanguageId)
        }
                        
        navigateToTool(
            resourceId: resourceId,
            languageIds: languageIds,
            liveShareStream: nil,
            trainingTipsEnabled: trainingTipsEnabled,
            page: nil
        )
    }
    
    func navigateToTool(resourceId: String, languageIds: [String], liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: resourceId,
            languageIds: languageIds,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository()
        )
        
        navigateToToolAndDetermineToolTranslationsToDownload(
            determineToolTranslationsToDownload: determineToolTranslationsToDownload,
            liveShareStream: liveShareStream,
            trainingTipsEnabled: trainingTipsEnabled,
            page: page
        )
    }
    
    private func navigateToToolAndDetermineToolTranslationsToDownload(determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let didDownloadToolTranslationsClosure = { [weak self] (result: Result<ToolTranslationsDomainModel, URLResponseError>) in
                        
            switch result {
            
            case .success(let toolTranslations):
                
                self?.navigateToTool(
                    toolTranslations: toolTranslations,
                    liveShareStream: liveShareStream,
                    trainingTipsEnabled: trainingTipsEnabled,
                    page: page
                )
                
            case .failure(let error):
                
                self?.presentDownloadToolError(downloadToolError: error)
            }
            
            self?.downloadToolTranslationFlow = nil
        }
        
        let downloadToolTranslationFlow = DownloadToolTranslationsFlow(
            presentInFlow: self,
            appDiContainer: appDiContainer,
            determineToolTranslationsToDownload: determineToolTranslationsToDownload,
            didDownloadToolTranslations: didDownloadToolTranslationsClosure
        )
        
        self.downloadToolTranslationFlow = downloadToolTranslationFlow
    }
    
    private func navigateToTool(toolTranslations: ToolTranslationsDomainModel, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let resourceType: ResourceType = toolTranslations.tool.resourceTypeEnum
        
        switch resourceType {
            
        case .article:
            
            articleFlow = ArticleFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                toolTranslations: toolTranslations
            )
            
        case .lesson:
            
            lessonFlow = LessonFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                toolTranslations: toolTranslations,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
            
        case .tract:
            
            tractFlow = TractFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                toolTranslations: toolTranslations,
                liveShareStream: liveShareStream,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
            
        case .chooseYourOwnAdventure:
            
            chooseYourOwnAdventureFlow = ChooseYourOwnAdventureFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                toolTranslations: toolTranslations
            )
            
        case .metaTool:
            // NOTE: Navigation is not needed here because MetaTools are not visible in the app (All Tools).
            break
            
        case .unknown:
            navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Attempted to navigate to a tool with an unknown resource type."))
        }
    }
        
    private func presentDownloadToolError(downloadToolError: URLResponseError) {
        
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        
        let viewModel = AlertMessageViewModel(
            title: nil,
            message: downloadToolError.getErrorMessage(),
            cancelTitle: nil,
            acceptTitle: localizationServices.stringForMainBundle(key: "OK"),
            acceptHandler: nil
        )

        presentAlertMessage(viewModel: viewModel)
    }
    
    private func presentAlertMessage(viewModel: AlertMessageViewModelType) {
        
        let view = AlertMessageView(viewModel: viewModel)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
}
