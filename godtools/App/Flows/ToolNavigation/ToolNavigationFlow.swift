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
        
    func navigateToToolFromToolDeepLink(appLanguage: AppLanguageDomainModel, toolDeepLink: ToolDeepLink, didCompleteToolNavigation: ((_ resource: ResourceModel) -> Void)?) {
        
        let determineDeepLinkedToolTranslationsToDownload = DetermineDeepLinkedToolTranslationsToDownload(
            toolDeepLink: toolDeepLink,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: appDiContainer.dataLayer.getLanguagesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            userAppLanguageRepository: appDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository()
        )
        
        navigateToToolAndDetermineToolTranslationsToDownload(
            appLanguage: appLanguage,
            determineToolTranslationsToDownload: determineDeepLinkedToolTranslationsToDownload,
            liveShareStream: toolDeepLink.liveShareStream,
            selectedLanguageIndex: toolDeepLink.selectedLanguageIndex,
            trainingTipsEnabled: false,
            initialPage: toolDeepLink.mobileContentPage
        )
    }
    
    func navigateToTool(appLanguage: AppLanguageDomainModel, resourceId: String, languageIds: [String], liveShareStream: String?, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?) {
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: resourceId,
            languageIds: languageIds,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository()
        )
        
        navigateToToolAndDetermineToolTranslationsToDownload(
            appLanguage: appLanguage,
            determineToolTranslationsToDownload: determineToolTranslationsToDownload,
            liveShareStream: liveShareStream,
            selectedLanguageIndex: selectedLanguageIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            initialPage: initialPage
        )
    }
    
    private func navigateToToolAndDetermineToolTranslationsToDownload(appLanguage: AppLanguageDomainModel, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, liveShareStream: String?, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?) {
        
        let didDownloadToolTranslationsClosure = { [weak self] (result: Result<ToolTranslationsDomainModel, Error>) in
                        
            switch result {
            
            case .success(let toolTranslations):
                
                self?.navigateToTool(
                    appLanguage: appLanguage,
                    toolTranslations: toolTranslations,
                    liveShareStream: liveShareStream,
                    selectedLanguageIndex: selectedLanguageIndex,
                    trainingTipsEnabled: trainingTipsEnabled,
                    initialPage: initialPage
                )
                
            case .failure(let responseError):
                self?.presentNetworkError(appLanguage: appLanguage, responseError: responseError)
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
    
    private func navigateToTool(appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel, liveShareStream: String?, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?) {
        
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
                appLanguage: appLanguage,
                toolTranslations: toolTranslations,
                trainingTipsEnabled: trainingTipsEnabled,
                initialPage: initialPage
            )
            
        case .tract:
            
            tractFlow = TractFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                appLanguage: appLanguage,
                toolTranslations: toolTranslations,
                liveShareStream: liveShareStream,
                selectedLanguageIndex: selectedLanguageIndex,
                trainingTipsEnabled: trainingTipsEnabled,
                initialPage: initialPage
            )
            
        case .chooseYourOwnAdventure:
            
            chooseYourOwnAdventureFlow = ChooseYourOwnAdventureFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                appLanguage: appLanguage,
                toolTranslations: toolTranslations,
                initialPage: initialPage,
                selectedLanguageIndex: selectedLanguageIndex
            )
            
        case .metaTool:
            // NOTE: Navigation is not needed here because MetaTools are not visible in the app (All Tools).
            break
            
        case .unknown:
            
            let viewModel = AlertMessageViewModel(
                title: "Internal Error",
                message: "Attempted to navigate to a tool with an unknown resource type.",
                cancelTitle: nil,
                acceptTitle: "OK",
                acceptHandler: nil
            )
            let view = AlertMessageView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        }
    }
}
