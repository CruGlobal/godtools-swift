//
//  ToolNavigationFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ToolNavigationFlow: Flow {
    
    var articleFlow: ArticleFlow? { get set }
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow? { get set }
    var lessonFlow: LessonFlow? { get set }
    var tractFlow: TractFlow? { get set }
}

extension ToolNavigationFlow {
    
    // MARK: - Tool Navigation
    
    func navigateToToolFromToolDeepLink(toolDeepLink: ToolDeepLink, didCompleteToolNavigation: ((_ resource: ResourceModel) -> Void)?) {
        
        let determineDeepLinkedToolTranslationsToDownload = DetermineDeepLinkedToolTranslationsToDownload(
            toolDeepLink: toolDeepLink,
            resourcesCache: appDiContainer.initialDataDownloader.resourcesCache,
            dataDownloader: appDiContainer.initialDataDownloader,
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
            resourcesCache: appDiContainer.initialDataDownloader.resourcesCache,
            dataDownloader: appDiContainer.initialDataDownloader
        )
        
        navigateToToolAndDetermineToolTranslationsToDownload(
            determineToolTranslationsToDownload: determineToolTranslationsToDownload,
            liveShareStream: liveShareStream,
            trainingTipsEnabled: trainingTipsEnabled,
            page: page
        )
    }
    
    private func navigateToToolAndDetermineToolTranslationsToDownload(determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let didDownloadToolClosure: ((_ result: Result<DownloadedToolData, DownloadToolError>) -> Void) = { [weak self] (result: Result<DownloadedToolData, DownloadToolError>) in
            
            switch result {
            
            case .success(let downloadedToolData):
                
                self?.navigateToToolWithToolData(toolData: downloadedToolData, liveShareStream: liveShareStream, trainingTipsEnabled: trainingTipsEnabled, page: page)
                self?.leaveDownloadToolView(animated: true, completion: nil)
                
            case .failure(let downloadToolError):
                
                self?.leaveDownloadToolView(animated: true, completion: { [weak self] in
                        
                    self?.presentDownloadToolError(downloadToolError: downloadToolError)
                })
            }
        }
        
        let didCloseClosure: (() -> Void) = { [weak self] in
            
            self?.leaveDownloadToolView(animated: true, completion: nil)
        }
        
        let translationsToDownloadResult: Result<DownloadToolLanguageTranslations, DetermineToolTranslationsToDownloadError> = determineToolTranslationsToDownload.determineToolTranslationsToDownload()
        
        switch translationsToDownloadResult {
            
        case .success(let downloadToolLanguageTranslations):
            
            let getToolTranslationManifests = GetToolTranslationManifestsFromCache(
                dataDownloader: appDiContainer.initialDataDownloader,
                resourcesCache: appDiContainer.initialDataDownloader.resourcesCache,
                translationsFileCache: appDiContainer.translationsFileCache
            )
            
            let getToolTranslationManifestsCacheResult: GetToolTranslationManifestsFromCacheResult = getToolTranslationManifests.getTranslationManifests(
                resource: downloadToolLanguageTranslations.resource,
                languages: downloadToolLanguageTranslations.languages
            )
            
            if getToolTranslationManifestsCacheResult.translationIdsNeededDownloading.isEmpty {
                
                let toolData = DownloadedToolData(resource: downloadToolLanguageTranslations.resource, languageTranslations: getToolTranslationManifestsCacheResult.toolTranslations)
                
                navigateToToolWithToolData(toolData: toolData, liveShareStream: liveShareStream, trainingTipsEnabled: trainingTipsEnabled, page: page)
            }
            else {
                
                navigateToDownloadTool(determineToolTranslationsToDownload: determineToolTranslationsToDownload, didDownloadToolClosure: didDownloadToolClosure, didCloseClosure: didCloseClosure)
            }
                        
        case .failure( _):
            
            navigateToDownloadTool(determineToolTranslationsToDownload: determineToolTranslationsToDownload, didDownloadToolClosure: didDownloadToolClosure, didCloseClosure: didCloseClosure)
        }
    }
    
    private func navigateToToolWithToolData(toolData: DownloadedToolData, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let resource: ResourceModel = toolData.resource
        let toolLanguageTranslations: [ToolTranslationData] = toolData.languageTranslations
        
        let primaryLanguageTranslationData: ToolTranslationData?
        
        if let firstLanguageTranslation = toolLanguageTranslations.first {
            primaryLanguageTranslationData = firstLanguageTranslation
        }
        else {
            primaryLanguageTranslationData = nil
        }
        
        guard let primaryLanguageTranslation = primaryLanguageTranslationData else {
            presentDownloadToolError(downloadToolError: .failedToFetchPrimaryTranslationManifest)
            return
        }
        
        let parallelLanguageTranslation: ToolTranslationData?
        
        if toolLanguageTranslations.count > 1 {
            
            parallelLanguageTranslation = toolLanguageTranslations[1]
        }
        else {
            
            parallelLanguageTranslation = nil
        }
                
        let resourceType: ResourceType = resource.resourceTypeEnum
        
        switch resourceType {
            
        case .article:
            
            articleFlow = ArticleFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                resource: resource,
                translationManifest: primaryLanguageTranslation.translationManifestData
            )
            
        case .lesson:
            
            lessonFlow = LessonFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                resource: resource,
                primaryLanguage: primaryLanguageTranslation.language,
                primaryTranslationManifest: primaryLanguageTranslation.translationManifestData,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
            
        case .tract:
            
            tractFlow = TractFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                resource: resource,
                primaryLanguage: primaryLanguageTranslation.language,
                primaryTranslationManifest: primaryLanguageTranslation.translationManifestData,
                parallelLanguage: parallelLanguageTranslation?.language,
                parallelTranslationManifest: parallelLanguageTranslation?.translationManifestData,
                liveShareStream: liveShareStream,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
            
        case .chooseYourOwnAdventure:
            
            chooseYourOwnAdventureFlow = ChooseYourOwnAdventureFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                resource: resource,
                primaryLanguage: primaryLanguageTranslation.language,
                primaryTranslationManifest: primaryLanguageTranslation.translationManifestData,
                parallelLanguage: parallelLanguageTranslation?.language,
                parallelTranslationManifest: parallelLanguageTranslation?.translationManifestData
            )
            
        case .unknown:
            navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Attempted to navigate to a tool with an unknown resource type."))
        }
    }
    
    // MARK: - Download Tool
    
    private func navigateToDownloadTool(determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, didDownloadToolClosure: @escaping ((_ result: Result<DownloadedToolData, DownloadToolError>) -> Void), didCloseClosure: @escaping (() -> Void)) {
            
        let viewModel = DownloadToolViewModel(
            initialDataDownloader: appDiContainer.initialDataDownloader,
            translationDownloader: appDiContainer.translationDownloader,
            determineTranslationsToDownload: determineToolTranslationsToDownload,
            resourcesCache: appDiContainer.initialDataDownloader.resourcesCache,
            translationsFileCache: appDiContainer.translationsFileCache,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            localizationServices: appDiContainer.localizationServices,
            didDownloadToolClosure: didDownloadToolClosure,
            didCloseClosure: didCloseClosure
        )
        
        let view = DownloadToolView(viewModel: viewModel)
        
        let modal = ModalNavigationController(rootView: view, navBarColor: .white, navBarIsTranslucent: false)
        
        navigationController.present(modal, animated: true, completion: nil)
    }
    
    private func leaveDownloadToolView(animated: Bool, completion: (() -> Void)?) {
        
        navigationController.dismissPresented(animated: animated, completion: completion)
    }
    
    private func presentDownloadToolError(downloadToolError: DownloadToolError) {
        
        let viewModel = DownloadToolErrorViewModel(
            downloadToolError: downloadToolError,
            localizationServices: appDiContainer.localizationServices
        )
        
        let view = AlertMessageView(viewModel: viewModel)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
}
