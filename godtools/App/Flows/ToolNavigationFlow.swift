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
    var lessonFlow: LessonFlow? { get set }
    var tractFlow: TractFlow? { get set }
}

extension ToolNavigationFlow {
    
    func navigateToTool(resource: ResourceModel, trainingTipsEnabled: Bool) {
        
        let fetchTranslationManifestsViewModel: FetchTranslationManifestsViewModel = appDiContainer.fetchTranslationManifestsViewModel
        
        let result: FetchTranslationManifestResult = fetchTranslationManifestsViewModel.getTranslationManifests(resourceId: resource.id)
        
        switch result {
        
        case .failedToGetInitialResourcesFromCache:
            break
        
        case .fetchedTranslationsFromCache(let primaryLanguage, let primaryTranslation, let primaryTranslationManifest, let parallelLanguage, let parallelTranslation, let parallelTranslationManifest):
            
            navigateToToolFromFetchedCachedResources(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslation: primaryTranslation,
                primaryTranslationManifest: primaryTranslationManifest,
                parallelLanguage: parallelLanguage,
                parallelTranslation: parallelTranslation,
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: nil,
                trainingTipsEnabled: trainingTipsEnabled,
                page: 0
            )
        }
    }
    
    func navigateToTool(resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let dataDownloader: InitialDataDownloader = appDiContainer.initialDataDownloader
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
        let primaryTranslation: TranslationModel? = dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) ?? dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en")
        
        let parallelTranslation: TranslationModel?
        
        if let parallelLanguage = parallelLanguage {
            parallelTranslation = dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: parallelLanguage.id)
        }
        else {
            parallelTranslation = nil
        }
        
        let primaryTranslationManifest: TranslationManifestData?
        let parallelTranslationManifest: TranslationManifestData?
        
        if let primaryTranslation = primaryTranslation {
            
            let primaryManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifestOnMainThread(translationId: primaryTranslation.id)
            
            switch primaryManifestResult {
            
            case .success(let translationManifest):
                primaryTranslationManifest = translationManifest
            case .failure(let error):
                primaryTranslationManifest = nil
            }
        }
        else {
            primaryTranslationManifest = nil
        }
        
        if let parallelTranslation = parallelTranslation {
            
            let parallelManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifestOnMainThread(translationId: parallelTranslation.id)
            
            switch parallelManifestResult {
            
            case .success(let translationManifest):
                parallelTranslationManifest = translationManifest
            case .failure(let error):
                parallelTranslationManifest = nil
            }
        }
        else {
            parallelTranslationManifest = nil
        }
        
        if let primaryTranslation = primaryTranslation {
            
            navigateToToolFromFetchedCachedResources(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslation: primaryTranslation,
                primaryTranslationManifest: primaryTranslationManifest,
                parallelLanguage: parallelLanguage,
                parallelTranslation: parallelTranslation,
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: liveShareStream,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
        }
        else {
            
            navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Failed to fetch primary translation for primary language \(primaryLanguage.name)"))
        }
    }
    
    private func navigateToToolFromFetchedCachedResources(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslation: TranslationModel, primaryTranslationManifest: TranslationManifestData?, parallelLanguage: LanguageModel?, parallelTranslation: TranslationModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
        var translationsToDownload: [TranslationModel] = Array()
        
        let shouldDownloadPrimaryTranslation: Bool = primaryTranslationManifest == nil
        let shouldDownloadParallelTranslation: Bool = parallelTranslationManifest == nil && parallelTranslation != nil
        
        if shouldDownloadPrimaryTranslation {
            translationsToDownload.append(primaryTranslation)
        }
        
        if shouldDownloadParallelTranslation, let parallelTranslation = parallelTranslation {
            translationsToDownload.append(parallelTranslation)
        }
        
        if !translationsToDownload.isEmpty {
            
            var downloadedPrimaryTranslation: TranslationManifestData?
            var downloadedParallelTranslation: TranslationManifestData?
            
            let completeHandler: CallbackValueHandler<[DownloadedTranslationResult]> = CallbackValueHandler { [weak self] (downloadedTranslationsResults: [DownloadedTranslationResult]) in
                                               
                for downloadedTranslation in downloadedTranslationsResults {
                    
                    if let downloadError = downloadedTranslation.downloadError {
                        self?.handleDownloadTranslationErrorFromLoadingToolView(downloadError: downloadError)
                        return
                    }
                    else {
                        
                        let result: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifestOnMainThread(translationId: downloadedTranslation.translationId)
                        
                        switch result {
                        case .success(let translationManifestData):
                            if downloadedTranslation.translationId == primaryTranslation.id {
                                downloadedPrimaryTranslation = translationManifestData
                            }
                            else if (downloadedTranslation.translationId == parallelTranslation?.id) {
                                downloadedParallelTranslation = translationManifestData
                            }
                        case .failure(let translationDownloaderError):
                            break
                        }
                    }
                }
                
                guard let resourceTranslationPrimaryManifest = primaryTranslationManifest ?? downloadedPrimaryTranslation else {
                    self?.navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Missing primary translation."))
                    return
                }
                
                self?.leaveLoadingToolView(
                    animated: true,
                    completion: nil
                )
                
                self?.navigateToTool(
                    resource: resource,
                    primaryLanguage: primaryLanguage,
                    primaryTranslationManifest: resourceTranslationPrimaryManifest,
                    parallelLanguage: parallelLanguage,
                    parallelTranslationManifest: parallelTranslationManifest ?? downloadedParallelTranslation,
                    liveShareStream: liveShareStream,
                    trainingTipsEnabled: trainingTipsEnabled,
                    page: page
                )
                
            }// loading tool completed
            
            navigateToLoadingToolView(
                resource: resource,
                translationsToDownload: translationsToDownload,
                completeHandler: completeHandler
            )
        }
        else if let primaryTranslationManifest = primaryTranslationManifest {
            
            navigateToTool(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslationManifest: primaryTranslationManifest,
                parallelLanguage: parallelLanguage,
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: liveShareStream,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
        }
    }
    
    private func navigateToTool(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let resourceType: ResourceType = resource.resourceTypeEnum
        
        switch resourceType {
            
        case .article:
            navigateToArticleToolFlow(
                resource: resource,
                translationManifest: primaryTranslationManifest
            )
            
        case .lesson:
            navigateToLessonFlow(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslationManifest: primaryTranslationManifest,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
            
        case .tract:
            navigateToTractFlow(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslationManifest: primaryTranslationManifest,
                parallelLanguage: parallelLanguage,
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: liveShareStream,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
            
        case .unknown:
            navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Attempted to navigate to a tool with an unknown resource type."))
        }
    }
    
    private func navigateToArticleToolFlow(resource: ResourceModel, translationManifest: TranslationManifestData) {
        
        let articleFlow = ArticleFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            resource: resource,
            translationManifest: translationManifest
        )
        
        self.articleFlow = articleFlow
    }
    
    private func navigateToLessonFlow(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, trainingTipsEnabled: Bool, page: Int?) {
        
        let lessonFlow = LessonFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            resource: resource,
            primaryLanguage: primaryLanguage,
            primaryTranslationManifest: primaryTranslationManifest,
            trainingTipsEnabled: trainingTipsEnabled,
            page: page
        )
        
        self.lessonFlow = lessonFlow
    }
    
    private func navigateToTractFlow(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
           
        let tractFlow = TractFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            resource: resource,
            primaryLanguage: primaryLanguage,
            primaryTranslationManifest: primaryTranslationManifest,
            parallelLanguage: parallelLanguage,
            parallelTranslationManifest: parallelTranslationManifest,
            liveShareStream: liveShareStream,
            trainingTipsEnabled: trainingTipsEnabled,
            page: page
        )
        
        self.tractFlow = tractFlow
    }
    
    // MARK: -
    
    private func navigateToLoadingToolView(resource: ResourceModel, translationsToDownload: [TranslationModel], completeHandler: CallbackValueHandler<[DownloadedTranslationResult]>) {
        
        let closeHandler: CallbackHandler = CallbackHandler { [weak self] in
            self?.leaveLoadingToolView(animated: true, completion: nil)
        }
        
        let viewModel = LoadingToolViewModel(
            resource: resource,
            translationsToDownload: translationsToDownload,
            translationDownloader: appDiContainer.translationDownloader,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            localizationServices: appDiContainer.localizationServices,
            completeHandler: completeHandler,
            closeHandler: closeHandler
        )
        
        let view = LoadingToolView(viewModel: viewModel)
        
        let modal = ModalNavigationController(rootView: view)
        
        navigationController.present(modal, animated: true, completion: nil)
    }
    
    private func leaveLoadingToolView(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(
            animated: animated,
            completion: completion
        )
    }
    
    private func handleDownloadTranslationErrorFromLoadingToolView(downloadError: TranslationDownloaderError) {
        
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        
        leaveLoadingToolView(animated: true, completion: { [weak self] in
            if !downloadError.cancelled {
                let downloadTranslationAlert = TranslationDownloaderErrorViewModel(
                    localizationServices: localizationServices,
                    translationDownloaderError: downloadError
                )
                self?.navigationController.presentAlertMessage(alertMessage: downloadTranslationAlert)
            }
        })
    }
}
